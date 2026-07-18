import 'dart:io';

import 'package:chs_importer/chs_importer.dart';
import 'package:test/test.dart';

String fixture(String name) =>
    File('test/fixtures/$name').readAsStringSync();

void main() {
  final fetchedAt = DateTime.utc(2026, 7, 12);

  test('parseSektorIds finds sektory linked from an oblast page', () {
    expect(parseSektorIds(fixture('oblast-300.html')), [9001]);
  });

  test('parseRegionIds and parseOblastIds find linked ids', () {
    final page = fixture('sektor-9001.html');
    expect(parseRegionIds(page), [5]);
    expect(parseOblastIds(page), [300]);
  });

  group('parseSektorPage', () {
    late RawChsSektor sektor;

    setUpAll(() {
      sektor = parseSektorPage(
        fixture('sektor-9001.html'),
        id: 9001,
        sourceUrl: 'https://www.horosvaz.cz/skaly-sektor-9001/',
        fetchedAt: fetchedAt,
      );
    });

    test('reads name and breadcrumb', () {
      expect(sektor.name, 'Zkušební skály');
      expect(sektor.breadcrumb.regionId, 5);
      expect(sektor.breadcrumb.regionName, 'Testový kraj');
      expect(sektor.breadcrumb.oblastId, 300);
      expect(sektor.breadcrumb.oblastName, 'Testová skupina');
    });

    test('separates description, access and drops the online source', () {
      expect(sektor.descriptionParagraphs, hasLength(2));
      expect(sektor.descriptionParagraphs.first, contains('žulové stěny'));
      expect(sektor.accessText, startsWith('Od parkoviště u mostu'));
      expect(
        sektor.descriptionParagraphs.join(),
        isNot(contains('example.com')),
      );
    });

    test('reads rock, height, grade system and icon flags', () {
      expect(sektor.rockText, 'žula');
      expect(sektor.heightText, '25m');
      expect(sektor.gradeSystemLabel, 'UIAA');
      expect(
        sektor.iconFlags.keys,
        containsAll(['sportovni', 'tradicni_lezeni', 'zakaz_hnizdeni']),
      );
      expect(sektor.iconFlags.containsKey('bouldering'), isFalse);
    });

    test('lists child skala ids', () {
      expect(sektor.skalaIds, unorderedEquals([8001, 8002]));
    });
  });

  test('parseMapCode prefers the sektor pin', () {
    final pin = parseMapCode(fixture('sektor-map-9001.txt'));
    expect(pin?.latitude, 49.9003444);
    expect(pin?.longitude, 15.5005650);
  });

  group('parseSkalaPage', () {
    late RawChsSkala skala;

    setUpAll(() {
      skala = parseSkalaPage(
        fixture('skala-8001.html'),
        id: 8001,
        sourceUrl: 'https://www.horosvaz.cz/skaly-skala-8001/',
        fetchedAt: fetchedAt,
      );
    });

    test('reads name, sektor breadcrumb and grade system', () {
      expect(skala.name, 'Velká stěna');
      expect(skala.breadcrumb.sektorId, 9001);
      expect(skala.gradeSystemLabel, 'UIAA');
      expect(skala.description, contains('výrazným pilířem'));
    });

    test('parses routes with grade, icons, description and FA', () {
      expect(skala.routes, hasLength(2));

      final pilir = skala.routes.first;
      expect(pilir.id, 70001);
      expect(pilir.name, 'Zkušební pilíř');
      expect(pilir.gradeText, 'VI',
          reason: 'trailing length token must not be read as the grade');
      expect(pilir.lengthMeters, 12);
      expect(pilir.iconFlags.keys, containsAll(['sportovni', 'zajis_nyty']));
      expect(pilir.iconFlags.containsKey('zajis_vklinenec'), isFalse);
      expect(pilir.description, contains('Středem pilíře'));
      expect(pilir.firstAscent, 'J. Novák, P. Svoboda, 14.5.1998');

      final spara = skala.routes.last;
      expect(spara.gradeText, 'III', reason: 'stars must not leak into grade');
      expect(spara.lengthMeters, isNull);
      expect(spara.iconFlags.keys, contains('tradicni_lezeni'));
      expect(spara.firstAscent, 'Autoři neznámí');
    });
  });
}
