/// Transforms raw ČHS models into the Crux CZ catalog exchange format
/// (docs/CATALOG_FORMAT.md).
///
/// Level mapping (ČHS → catalog): region → region, sektor → area,
/// skála → sector (routes directly on the sector), cesta → route. The
/// ČHS "oblast" grouping level has no catalog counterpart; its name is
/// kept in the area summary so nothing is lost for readers.
library;

import 'raw_models.dart';

class NormalizationResult {
  NormalizationResult({required this.catalog, required this.warnings});

  /// Catalog document ready to be JSON-encoded.
  final Map<String, Object?> catalog;

  /// Human-readable notes for the manual review step (unknown grades,
  /// missing GPS, fallback decisions…). Warnings never abort the import.
  final List<String> warnings;
}

/// Maps ČHS grade-system labels (from the histogram tooltip) to catalog
/// `gradingSystem` values.
const _gradeSystems = <String, String>{
  'UIAA': 'uiaa',
  'Pískovec Sasko': 'czechSandstone',
  'Sasko': 'czechSandstone',
  'Francouzská': 'french',
  'Francie': 'french',
  'Fontainebleau': 'fontainebleau',
  'V-scale': 'vScale',
  'YDS': 'yds',
  'UK': 'british',
};

const _rockTypes = <String, String>{
  'pískovec': 'sandstone',
  'vápenec': 'limestone',
  'žula': 'granite',
  'granit': 'granite',
  'rula': 'gneiss',
  'čedič': 'basalt',
  'bazalt': 'basalt',
};

NormalizationResult normalizeCatalog({
  required List<RawChsSektor> sektory,
  required List<RawChsSkala> skaly,
  required int version,
}) {
  final warnings = <String>[];
  final skalyBySektor = <int, List<RawChsSkala>>{};
  for (final skala in skaly) {
    final sektorId = skala.breadcrumb.sektorId;
    if (sektorId == null) {
      warnings.add(
        'skala-${skala.id} (${skala.name}): breadcrumb has no sektor — '
        'skipped',
      );
      continue;
    }
    skalyBySektor.putIfAbsent(sektorId, () => []).add(skala);
  }

  final regions = <String, Map<String, Object?>>{};
  final areas = <Map<String, Object?>>[];

  for (final sektor in sektory) {
    final regionId = sektor.breadcrumb.regionId;
    final regionName = sektor.breadcrumb.regionName;
    if (regionId == null || regionName == null) {
      warnings.add(
        'sektor-${sektor.id} (${sektor.name}): breadcrumb has no region — '
        'skipped',
      );
      continue;
    }
    regions.putIfAbsent(
      'chs-region-$regionId',
      () => {
        'id': 'chs-region-$regionId',
        'name': regionName,
        'country': 'CZ',
      },
    );

    if (sektor.latitude == null || sektor.longitude == null) {
      warnings.add(
        'sektor-${sektor.id} (${sektor.name}): no GPS from map-code — '
        'skipped (location is required by the catalog format)',
      );
      continue;
    }

    final sectors = <Map<String, Object?>>[];
    for (final skala in skalyBySektor[sektor.id] ?? const <RawChsSkala>[]) {
      sectors.add(_sector(skala, sektor, warnings));
    }
    if (sectors.isEmpty) {
      warnings.add(
        'sektor-${sektor.id} (${sektor.name}): no skála pages in the '
        'snapshot — area exported without sectors',
      );
    }

    areas.add(_area(sektor, regionId, sectors, warnings));
  }

  final sortedRegions = regions.values.toList()
    ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

  return NormalizationResult(
    catalog: {
      'version': version,
      'regions': sortedRegions,
      'areas': areas,
    },
    warnings: warnings,
  );
}

Map<String, Object?> _area(
  RawChsSektor sektor,
  int regionId,
  List<Map<String, Object?>> sectors,
  List<String> warnings,
) {
  final routeCount = sectors.fold<int>(
    0,
    (sum, s) => sum + (s['routes'] as List).length,
  );

  final oblastName = sektor.breadcrumb.oblastName;
  final summaryParts = [
    if (oblastName != null) 'Skupina $oblastName.',
    if (sektor.rockText != null) 'Hornina: ${sektor.rockText}.',
    '$routeCount cest v databázi ČHS.',
  ];

  final description = sektor.descriptionParagraphs.join('\n\n');

  return {
    'id': 'chs-sektor-${sektor.id}',
    'regionId': 'chs-region-$regionId',
    'name': sektor.name,
    'summary': summaryParts.join(' '),
    'description': description.isEmpty
        ? 'Bez popisu v databázi ČHS.'
        : description,
    'climbingTypes': _climbingTypes(sektor.iconFlags),
    'rockType': _rockType(sektor, warnings),
    'location': {
      'latitude': sektor.latitude,
      'longitude': sektor.longitude,
    },
    'access': ?_access(sektor.accessText),
    'restrictions': _restrictions(sektor),
    'sectors': sectors,
    'meta': {
      'sourceUrl': sektor.sourceUrl,
      'fetchedAt': sektor.fetchedAt.toIso8601String(),
      'chsOblast': ?oblastName,
    },
  };
}

Map<String, Object?>? _access(String? text) =>
    text == null ? null : {'description': text};

Map<String, Object?> _sector(
  RawChsSkala skala,
  RawChsSektor sektor,
  List<String> warnings,
) {
  final systemLabel = skala.gradeSystemLabel ?? sektor.gradeSystemLabel;
  return {
    'id': 'chs-skala-${skala.id}',
    'name': skala.name,
    'description': ?skala.description,
    'rocks': const <Object?>[],
    'routes': [
      for (final cesta in skala.routes)
        _route(cesta, skala, systemLabel, warnings),
    ],
  };
}

Map<String, Object?> _route(
  RawChsCesta cesta,
  RawChsSkala skala,
  String? systemLabel,
  List<String> warnings,
) {
  var system = systemLabel == null ? null : _gradeSystems[systemLabel];
  if (system == null) {
    warnings.add(
      'cesta-${cesta.id} (${cesta.name}): unknown grade system '
      '"${systemLabel ?? 'none'}" — defaulting to uiaa',
    );
    system = 'uiaa';
  }

  var gradeText = cesta.gradeText;
  if (gradeText == null || gradeText.isEmpty) {
    warnings.add(
      'cesta-${cesta.id} (${cesta.name}): missing grade — exported as "?"',
    );
    gradeText = '?';
  }

  return {
    'id': 'chs-cesta-${cesta.id}',
    'name': cesta.name,
    'grade': {'system': system, 'value': gradeText},
    'type': _routeType(cesta.iconFlags, system),
    'description': ?cesta.description,
    'protection': ?_protection(cesta.iconFlags),
    'firstAscent': ?cesta.firstAscent,
    'warnings': [
      if (cesta.iconFlags.containsKey('nebezpeci'))
        cesta.iconFlags['nebezpeci']!,
      if (cesta.iconFlags.containsKey('poskozena'))
        cesta.iconFlags['poskozena']!,
    ],
  };
}

/// ČHS discipline icons → catalog climbing types. The generic "skalní
/// lezení" flag is ignored when a specific discipline is present; if it is
/// the only flag, the area is treated as trad (typical for old Czech
/// crags with mixed protection).
List<String> _climbingTypes(IconFlags flags) {
  final types = <String>[
    if (flags.containsKey('sportovni')) 'sport',
    if (flags.containsKey('tradicni_lezeni') ||
        flags.containsKey('trad-piskovcove'))
      'trad',
    if (flags.containsKey('bouldering')) 'boulder',
  ];
  if (types.isEmpty && flags.containsKey('skalni_lezeni')) types.add('trad');
  return types;
}

String _routeType(IconFlags flags, String gradeSystem) {
  if (flags.containsKey('bouldering')) return 'boulder';
  if (flags.containsKey('sportovni')) return 'sport';
  if (flags.containsKey('tradicni_lezeni') ||
      flags.containsKey('trad-piskovcove')) {
    return 'trad';
  }
  // No explicit discipline: sandstone grading implies trad ethics, the
  // generic "skalní lezení" flag likewise; otherwise assume sport.
  if (gradeSystem == 'czechSandstone' || flags.containsKey('skalni_lezeni')) {
    return 'trad';
  }
  return 'sport';
}

String? _protection(IconFlags flags) {
  final parts = [
    if (flags.containsKey('zajis_nyty'))
      'fixní jištění (kruhy, nýty, borháky)',
    if (flags.containsKey('zajis_vklinenec')) 'vklíněnce',
    if (flags.containsKey('zajis_smycky')) 'textilní jištění (smyčky)',
  ];
  if (parts.isEmpty) return null;
  final joined = parts.join(', ');
  return joined[0].toUpperCase() + joined.substring(1);
}

String _rockType(RawChsSektor sektor, List<String> warnings) {
  final rockText = sektor.rockText?.toLowerCase() ?? '';
  for (final entry in _rockTypes.entries) {
    if (rockText.contains(entry.key)) return entry.value;
  }
  if (rockText.isNotEmpty) {
    warnings.add(
      'sektor-${sektor.id} (${sektor.name}): unmapped rock '
      '"${sektor.rockText}" — exported as "other"',
    );
  } else {
    warnings.add(
      'sektor-${sektor.id} (${sektor.name}): missing rock type — '
      'exported as "other"',
    );
  }
  return 'other';
}

/// Closure/warning icons (`zakaz*`) become catalog restrictions so the
/// app can surface them; details must still be reviewed manually.
List<Map<String, Object?>> _restrictions(RawChsSektor sektor) {
  final restrictions = <Map<String, Object?>>[];
  var index = 1;
  for (final entry in sektor.iconFlags.entries) {
    if (!entry.key.startsWith('zakaz')) continue;
    restrictions.add({
      'id': 'chs-sektor-${sektor.id}-restriction-${index++}',
      'title': entry.value,
      'description':
          '${entry.value} podle databáze ČHS. Podrobnosti ověřte na '
          '${sektor.sourceUrl}.',
      'severity': entry.key.contains('cast') ? 'warning' : 'closure',
    });
  }
  return restrictions;
}
