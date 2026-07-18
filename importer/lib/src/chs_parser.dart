/// Parsers for the ČHS rock database pages (www.horosvaz.cz).
///
/// Selectors are based on recorded page snapshots; every extraction is
/// defensive — a missing element yields `null`/empty instead of throwing,
/// and the validator reports the gaps afterwards.
library;

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;

import 'raw_models.dart';

final _idInHref = RegExp(r'/skaly-(region|oblast|sektor|skala|cesta)-(\d+)/');
final _iconFlag = RegExp(r'icons-[a-z]+-([a-z_]+?)_(ano|ne)\d+');
final _gradeSystem = RegExp(r'Klasifikace \(([^)]+)\)');
final _mapPin = RegExp(r'\{"lat":([0-9.]+),"lng":([0-9.]+),"title":"([^"]*)"');

int? _idFromHref(String? href, String kind) {
  if (href == null) return null;
  final match = _idInHref.firstMatch(href);
  if (match == null || match.group(1) != kind) return null;
  return int.parse(match.group(2)!);
}

String _cleanText(String text) =>
    text.replaceAll(' ', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

/// All `/skaly-sektor-N/` ids linked from a page (used on oblast pages,
/// whose sidebar tree lists the sektory of the active oblast).
List<int> parseSektorIds(String pageHtml) => _linkedIds(pageHtml, 'sektor');

/// All `/skaly-oblast-N/` ids linked from a region or index page.
List<int> parseOblastIds(String pageHtml) => _linkedIds(pageHtml, 'oblast');

/// All `/skaly-region-N/` ids linked from the database index page.
List<int> parseRegionIds(String pageHtml) => _linkedIds(pageHtml, 'region');

List<int> _linkedIds(String pageHtml, String kind) {
  final document = html.parse(pageHtml);
  final ids = <int>{};
  for (final anchor in document.querySelectorAll('a[href]')) {
    final id = _idFromHref(anchor.attributes['href'], kind);
    if (id != null) ids.add(id);
  }
  return ids.toList();
}

RawChsBreadcrumb _parseBreadcrumb(Document document) {
  int? regionId, oblastId, sektorId;
  String? regionName, oblastName, sektorName;
  for (final anchor in document.querySelectorAll('.breadcrumb a[href]')) {
    final href = anchor.attributes['href'];
    final name = _cleanText(anchor.text);
    if (_idFromHref(href, 'region') case final id?) {
      regionId = id;
      regionName = name;
    } else if (_idFromHref(href, 'oblast') case final id?) {
      oblastId = id;
      oblastName = name;
    } else if (_idFromHref(href, 'sektor') case final id?) {
      sektorId = id;
      sektorName = name;
    }
  }
  return RawChsBreadcrumb(
    regionId: regionId,
    regionName: regionName,
    oblastId: oblastId,
    oblastName: oblastName,
    sektorId: sektorId,
    sektorName: sektorName,
  );
}

/// Enabled (`_ano`) icon flags with their human-readable titles.
IconFlags _parseIconFlags(Element? scope) {
  final flags = <String, String>{};
  if (scope == null) return flags;
  for (final span in scope.querySelectorAll('span[class*=icons-]')) {
    final match = _iconFlag.firstMatch(span.attributes['class'] ?? '');
    if (match == null || match.group(2) != 'ano') continue;
    flags[match.group(1)!] = span.attributes['title'] ?? match.group(1)!;
  }
  return flags;
}

String? _parseGradeSystem(Document document) {
  final title = document.querySelector('.sgraph')?.attributes['title'];
  if (title == null) return null;
  return _gradeSystem.firstMatch(title)?.group(1)?.trim();
}

RawChsSektor parseSektorPage(
  String pageHtml, {
  required int id,
  required String sourceUrl,
  required DateTime fetchedAt,
}) {
  final document = html.parse(pageHtml);
  final name = _cleanText(document.querySelector('h1.menu5')?.text ?? '');

  // Description paragraphs; the "Přístup:" paragraph becomes access info
  // and "Online zdroj" link paragraphs are dropped.
  final paragraphs = <String>[];
  String? accessText;
  for (final p in document.querySelectorAll('.mountains-text p')) {
    final text = _cleanText(p.text);
    if (text.isEmpty || text.startsWith('Online zdroj')) continue;
    if (text.startsWith('Přístup')) {
      final stripped = _cleanText(
        text.replaceFirst(RegExp(r'^Přístup\s*:?\s*'), ''),
      );
      if (stripped.isNotEmpty) accessText = stripped;
    } else {
      paragraphs.add(text);
    }
  }

  final skalaIds = <int>{};
  for (final anchor in document.querySelectorAll('#main-list a[href]')) {
    final skalaId = _idFromHref(anchor.attributes['href'], 'skala');
    if (skalaId != null) skalaIds.add(skalaId);
  }

  return RawChsSektor(
    id: id,
    name: name,
    sourceUrl: sourceUrl,
    fetchedAt: fetchedAt,
    breadcrumb: _parseBreadcrumb(document),
    descriptionParagraphs: paragraphs,
    accessText: accessText,
    rockText: _text(document, '.top-info .info-part'),
    heightText: _text(document, '.top-info .height'),
    gradeSystemLabel: _parseGradeSystem(document),
    iconFlags: _parseIconFlags(document.querySelector('.top-icon-list')),
    skalaIds: skalaIds.toList(),
  );
}

String? _text(Document document, String selector) {
  final text = document.querySelector(selector)?.text;
  if (text == null) return null;
  final cleaned = _cleanText(text);
  return cleaned.isEmpty ? null : cleaned;
}

/// GPS of the page's own pin from the `?action=map-code` response.
///
/// The response lists several pins (the sektor plus its skály); the one
/// whose title ends with `(sektor)` is the sektor itself.
({double latitude, double longitude})? parseMapCode(String body) {
  ({double latitude, double longitude})? first;
  for (final match in _mapPin.allMatches(body)) {
    final pin = (
      latitude: double.parse(match.group(1)!),
      longitude: double.parse(match.group(2)!),
    );
    first ??= pin;
    if (match.group(3)!.contains('(sektor)')) return pin;
  }
  return first;
}

RawChsSkala parseSkalaPage(
  String pageHtml, {
  required int id,
  required String sourceUrl,
  required DateTime fetchedAt,
}) {
  final document = html.parse(pageHtml);

  final routes = <RawChsCesta>[];
  final mainList = document.querySelector('#main-list');
  final items = mainList == null
      ? const <Element>[]
      : mainList.children.where((e) => e.localName == 'li');
  for (final item in items) {
    final anchor = item.querySelector('a[href*=skaly-cesta]');
    final cestaId = _idFromHref(anchor?.attributes['href'], 'cesta');
    if (anchor == null || cestaId == null) continue;

    // `.info-roads` reads like ", V", ", ***, III" or ", 8/8+, 9m".
    // After removing the star-rating span, a trailing "<n>m" token is the
    // route length and the last remaining token is the grade.
    String? gradeText;
    int? lengthMeters;
    final infoRoads = item.querySelector('.info-roads');
    if (infoRoads != null) {
      infoRoads.querySelectorAll('.stars').forEach((e) => e.remove());
      final tokens = infoRoads.text
          .split(',')
          .map(_cleanText)
          .where((t) => t.isNotEmpty)
          .toList();
      final lengthMatch = tokens.isEmpty
          ? null
          : RegExp(r'^(\d+)\s*m$').firstMatch(tokens.last);
      if (lengthMatch != null) {
        lengthMeters = int.parse(lengthMatch.group(1)!);
        tokens.removeLast();
      }
      if (tokens.isNotEmpty) gradeText = tokens.last;
    }

    // The nested list under each route holds [description, first ascent].
    final detailItems = [
      for (final child in item.children)
        if (child.localName == 'ul')
          for (final li in child.children)
            if (li.localName == 'li' && _cleanText(li.text).isNotEmpty)
              _cleanText(li.text),
    ];

    // Route names containing quotes break the title attribute (the HTML
    // parser sees an empty title), so fall back to the anchor text.
    final titleName = _cleanText(anchor.attributes['title'] ?? '');
    routes.add(
      RawChsCesta(
        id: cestaId,
        name: titleName.isNotEmpty ? titleName : _cleanText(anchor.text),
        gradeText: gradeText,
        lengthMeters: lengthMeters,
        iconFlags: _parseIconFlags(item.querySelector('.info-icons')),
        description: detailItems.isNotEmpty ? detailItems.first : null,
        firstAscent: detailItems.length > 1 ? detailItems[1] : null,
      ),
    );
  }

  final descriptionText = document
      .querySelectorAll('.mountains-text p')
      .map((p) => _cleanText(p.text))
      .where((t) => t.isNotEmpty && !t.startsWith('Online zdroj'))
      .join('\n\n');

  return RawChsSkala(
    id: id,
    name: _cleanText(document.querySelector('h1.menu5')?.text ?? ''),
    sourceUrl: sourceUrl,
    fetchedAt: fetchedAt,
    breadcrumb: _parseBreadcrumb(document),
    description: descriptionText.isEmpty ? null : descriptionText,
    gradeSystemLabel: _parseGradeSystem(document),
    routes: routes,
  );
}
