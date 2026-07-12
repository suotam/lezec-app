/// Builds a catalog from a snapshot directory: parse every recorded page,
/// normalize to the exchange format and validate.
library;

import 'raw_models.dart';
import 'chs_parser.dart';
import 'normalizer.dart';
import 'snapshot.dart';
import 'validator.dart';

class BuildResult {
  BuildResult({
    required this.catalog,
    required this.warnings,
    required this.validation,
  });

  final Map<String, Object?> catalog;
  final List<String> warnings;
  final ValidationResult validation;
}

Future<BuildResult> buildCatalogFromSnapshot(
  Snapshot snapshot, {
  required int version,
}) async {
  final sektory = <RawChsSektor>[];
  final skaly = <RawChsSkala>[];

  for (final entry in snapshot.entries) {
    switch (entry.kind) {
      case 'sektor':
        final sektor = parseSektorPage(
          await snapshot.readEntry(entry),
          id: entry.id,
          sourceUrl: entry.url,
          fetchedAt: entry.fetchedAt,
        );
        final mapEntry = snapshot.find('sektor-map', entry.id);
        if (mapEntry != null) {
          final pin = parseMapCode(await snapshot.readEntry(mapEntry));
          sektor
            ..latitude = pin?.latitude
            ..longitude = pin?.longitude;
        }
        sektory.add(sektor);
      case 'skala':
        skaly.add(
          parseSkalaPage(
            await snapshot.readEntry(entry),
            id: entry.id,
            sourceUrl: entry.url,
            fetchedAt: entry.fetchedAt,
          ),
        );
      default:
        // oblast pages only enumerate sektory during fetch; sektor-map is
        // consumed above.
        break;
    }
  }

  final result = normalizeCatalog(
    sektory: sektory,
    skaly: skaly,
    version: version,
  );
  return BuildResult(
    catalog: result.catalog,
    warnings: result.warnings,
    validation: validateCatalog(result.catalog),
  );
}

/// Plain-text report for the manual review step required by the roadmap.
String buildReport(BuildResult result) {
  final catalog = result.catalog;
  final areas = catalog['areas'] as List;
  var routeCount = 0;
  for (final area in areas.cast<Map<String, Object?>>()) {
    for (final sector
        in (area['sectors'] as List).cast<Map<String, Object?>>()) {
      routeCount += (sector['routes'] as List).length;
    }
  }

  final buffer = StringBuffer()
    ..writeln('ČHS import report — ${DateTime.now().toIso8601String()}')
    ..writeln('catalog version: ${catalog['version']}')
    ..writeln('regions: ${(catalog['regions'] as List).length}, '
        'areas: ${areas.length}, routes: $routeCount')
    ..writeln()
    ..writeln('validation: '
        '${result.validation.isValid ? 'PASSED' : 'FAILED'} '
        '(${result.validation.errors.length} errors, '
        '${result.validation.warnings.length} warnings)');
  for (final error in result.validation.errors) {
    buffer.writeln('  ERROR: $error');
  }
  for (final warning in result.validation.warnings) {
    buffer.writeln('  WARN:  $warning');
  }
  buffer
    ..writeln()
    ..writeln('normalization notes (${result.warnings.length}):');
  for (final warning in result.warnings) {
    buffer.writeln('  NOTE:  $warning');
  }
  return buffer.toString();
}
