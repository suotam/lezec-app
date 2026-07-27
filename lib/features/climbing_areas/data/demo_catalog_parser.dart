import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/errors/demo_data_format_exception.dart';
import '../../climbing_routes/domain/climbing_route.dart';
import '../../climbing_routes/domain/climbing_type.dart';
import '../../climbing_routes/domain/route_grade.dart';
import '../domain/access_information.dart';
import '../domain/climbing_area.dart';
import '../domain/climbing_region.dart';
import '../domain/climbing_restriction.dart';
import '../domain/climbing_rock.dart';
import '../domain/climbing_sector.dart';
import '../domain/geo_point.dart';
import '../domain/parking_location.dart';
import '../domain/rock_type.dart';

/// Parsed catalog dataset.
@immutable
class DemoCatalog {
  const DemoCatalog({
    required this.version,
    required this.regions,
    required this.areas,
  });

  /// Format version of the source document, used to decide whether an
  /// already-imported catalog must be reseeded.
  final int version;

  final List<ClimbingRegion> regions;
  final List<ClimbingArea> areas;
}

/// Parses the bundled demo catalog JSON into domain models.
///
/// Every access is validated; malformed documents raise
/// [DemoDataFormatException] with a path-like context (e.g.
/// `areas[0].sectors[1].routes[2].grade`) instead of crashing with a cast
/// error deep inside the UI.
DemoCatalog parseDemoCatalog(String jsonString) {
  final Object? decoded;
  try {
    decoded = json.decode(jsonString);
  } on FormatException catch (e) {
    throw DemoDataFormatException('Document is not valid JSON: ${e.message}');
  }
  final root = _asMap(decoded, 'root');

  final version = root['version'];
  if (version is! int || version < 1) {
    throw const DemoDataFormatException(
      'root.version must be a positive integer',
    );
  }

  final regions = [
    for (final (i, entry) in _mapList(root, 'regions').indexed)
      _parseRegion(entry, 'regions[$i]'),
  ];
  final regionNamesById = {for (final r in regions) r.id: r.name};

  final areas = [
    for (final (i, entry) in _mapList(root, 'areas').indexed)
      _parseArea(entry, 'areas[$i]', regionNamesById),
  ];

  final routeIds = <String>{};
  for (final area in areas) {
    for (final route in area.allRoutes) {
      if (!routeIds.add(route.id)) {
        throw DemoDataFormatException('Duplicate route id "${route.id}"');
      }
    }
  }

  return DemoCatalog(version: version, regions: regions, areas: areas);
}

/// Parses a single area document (the same shape as one entry of the
/// catalog's `areas` list). Used by the local catalog store, which keeps
/// one JSON document per area so detail screens never parse the whole
/// catalog.
ClimbingArea parseCatalogArea(
  Object? document,
  String context,
  Map<String, String> regionNamesById,
) {
  return _parseArea(_asMap(document, context), context, regionNamesById);
}

/// Parses one entry of the catalog's `regions` list. Used by the catalog
/// store's incremental import, which never materializes the whole catalog
/// at once.
ClimbingRegion parseCatalogRegion(Object? document, String context) {
  return _parseRegion(_asMap(document, context), context);
}

ClimbingRegion _parseRegion(Map<String, Object?> map, String context) {
  return ClimbingRegion(
    id: _string(map, 'id', context),
    name: _string(map, 'name', context),
    country: _string(map, 'country', context),
  );
}

ClimbingArea _parseArea(
  Map<String, Object?> map,
  String context,
  Map<String, String> regionNamesById,
) {
  final regionId = _string(map, 'regionId', context);
  final regionName = regionNamesById[regionId];
  if (regionName == null) {
    throw DemoDataFormatException(
      '$context references unknown region "$regionId"',
    );
  }
  return ClimbingArea(
    id: _string(map, 'id', context),
    regionId: regionId,
    regionName: regionName,
    name: _string(map, 'name', context),
    summary: _string(map, 'summary', context),
    description: _string(map, 'description', context),
    climbingTypes: {
      for (final (i, name) in _stringList(
        map,
        'climbingTypes',
        context,
      ).indexed)
        _enumByName(ClimbingType.values, name, '$context.climbingTypes[$i]'),
    },
    rockType: _enumByName(
      RockType.values,
      _string(map, 'rockType', context),
      '$context.rockType',
    ),
    location: _parseGeoPoint(_asMap(map['location'], '$context.location')),
    parking: [
      for (final (i, entry) in _mapList(map, 'parking').indexed)
        _parseParking(entry, '$context.parking[$i]'),
    ],
    access: map['access'] == null
        ? null
        : _parseAccess(_asMap(map['access'], '$context.access')),
    restrictions: [
      for (final (i, entry) in _mapList(map, 'restrictions').indexed)
        _parseRestriction(entry, '$context.restrictions[$i]'),
    ],
    sectors: [
      for (final (i, entry) in _mapList(map, 'sectors').indexed)
        _parseSector(entry, '$context.sectors[$i]'),
    ],
    // Present only in summary documents (area without its sector tree),
    // which the catalog store derives at import time for fast lists.
    sectorCount: _optInt(map, 'sectorCount', context),
    routeCount: _optInt(map, 'routeCount', context),
    routeGradeMinBand: _optInt(map, 'routeGradeMinBand', context),
    routeGradeMaxBand: _optInt(map, 'routeGradeMaxBand', context),
    boulderGradeMinBand: _optInt(map, 'boulderGradeMinBand', context),
    boulderGradeMaxBand: _optInt(map, 'boulderGradeMaxBand', context),
  );
}

ClimbingSector _parseSector(Map<String, Object?> map, String context) {
  return ClimbingSector(
    id: _string(map, 'id', context),
    name: _string(map, 'name', context),
    description: _optString(map, 'description', context),
    accessNote: _optString(map, 'accessNote', context),
    warnings: _stringList(map, 'warnings', context),
    rocks: [
      for (final (i, entry) in _mapList(map, 'rocks').indexed)
        _parseRock(entry, '$context.rocks[$i]'),
    ],
    routes: [
      for (final (i, entry) in _mapList(map, 'routes').indexed)
        _parseRoute(entry, '$context.routes[$i]'),
    ],
  );
}

ClimbingRock _parseRock(Map<String, Object?> map, String context) {
  return ClimbingRock(
    id: _string(map, 'id', context),
    name: _string(map, 'name', context),
    description: _optString(map, 'description', context),
    routes: [
      for (final (i, entry) in _mapList(map, 'routes').indexed)
        _parseRoute(entry, '$context.routes[$i]'),
    ],
  );
}

ClimbingRoute _parseRoute(Map<String, Object?> map, String context) {
  final gradeMap = _asMap(map['grade'], '$context.grade');
  return ClimbingRoute(
    id: _string(map, 'id', context),
    name: _string(map, 'name', context),
    grade: RouteGrade(
      system: _enumByName(
        GradingSystem.values,
        _string(gradeMap, 'system', '$context.grade'),
        '$context.grade.system',
      ),
      value: _string(gradeMap, 'value', '$context.grade'),
    ),
    type: _enumByName(
      ClimbingType.values,
      _string(map, 'type', context),
      '$context.type',
    ),
    lengthMeters: _optInt(map, 'lengthMeters', context),
    description: _optString(map, 'description', context),
    protection: _optString(map, 'protection', context),
    firstAscent: _optString(map, 'firstAscent', context),
    warnings: _stringList(map, 'warnings', context),
  );
}

ParkingLocation _parseParking(Map<String, Object?> map, String context) {
  return ParkingLocation(
    id: _string(map, 'id', context),
    name: _string(map, 'name', context),
    location: _parseGeoPoint(_asMap(map['location'], '$context.location')),
    note: _optString(map, 'note', context),
  );
}

AccessInformation _parseAccess(Map<String, Object?> map) {
  return AccessInformation(
    description: _string(map, 'description', 'access'),
    approachMinutes: _optInt(map, 'approachMinutes', 'access'),
  );
}

ClimbingRestriction _parseRestriction(
  Map<String, Object?> map,
  String context,
) {
  return ClimbingRestriction(
    id: _string(map, 'id', context),
    title: _string(map, 'title', context),
    description: _string(map, 'description', context),
    severity: _enumByName(
      RestrictionSeverity.values,
      _string(map, 'severity', context),
      '$context.severity',
    ),
    seasonalNote: _optString(map, 'seasonalNote', context),
  );
}

GeoPoint _parseGeoPoint(Map<String, Object?> map) {
  final lat = map['latitude'];
  final lng = map['longitude'];
  if (lat is! num || lng is! num) {
    throw const DemoDataFormatException(
      'Geo point must contain numeric "latitude" and "longitude"',
    );
  }
  return GeoPoint(latitude: lat.toDouble(), longitude: lng.toDouble());
}

// --- validated accessors ---------------------------------------------------

Map<String, Object?> _asMap(Object? value, String context) {
  if (value is Map<String, Object?>) return value;
  throw DemoDataFormatException('$context must be an object');
}

String _string(Map<String, Object?> map, String key, String context) {
  final value = map[key];
  if (value is String && value.trim().isNotEmpty) return value;
  throw DemoDataFormatException('$context.$key must be a non-empty string');
}

String? _optString(Map<String, Object?> map, String key, String context) {
  final value = map[key];
  if (value == null) return null;
  if (value is String) return value;
  throw DemoDataFormatException('$context.$key must be a string');
}

int? _optInt(Map<String, Object?> map, String key, String context) {
  final value = map[key];
  if (value == null) return null;
  if (value is int) return value;
  throw DemoDataFormatException('$context.$key must be an integer');
}

List<Map<String, Object?>> _mapList(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) return const [];
  if (value is List) {
    return [for (final (i, entry) in value.indexed) _asMap(entry, '$key[$i]')];
  }
  throw DemoDataFormatException('$key must be a list');
}

List<String> _stringList(Map<String, Object?> map, String key, String context) {
  final value = map[key];
  if (value == null) return const [];
  if (value is List && value.every((e) => e is String)) {
    return value.cast<String>();
  }
  throw DemoDataFormatException('$context.$key must be a list of strings');
}

T _enumByName<T extends Enum>(List<T> values, String name, String context) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw DemoDataFormatException(
    '$context has unknown value "$name" (allowed: ${values.map((v) => v.name).join(', ')})',
  );
}
