import 'package:flutter/foundation.dart';

import '../../climbing_routes/domain/climbing_type.dart';
import 'climbing_area.dart';
import 'geo_point.dart';

/// Route climbing or bouldering — picks which grade scale and area types
/// smart search works with.
enum SmartDiscipline { routes, boulders }

/// A named starting point for a distance search (the user's position or a
/// preset town).
@immutable
class SmartOrigin {
  const SmartOrigin({required this.label, required this.point});

  final String label;
  final GeoPoint point;

  @override
  bool operator ==(Object other) =>
      other is SmartOrigin && other.label == label && other.point == point;

  @override
  int get hashCode => Object.hash(label, point);
}

/// Preset Czech towns as distance origins, so "sport near Pardubice"
/// works offline without geocoding. Coordinates are town centers.
const smartSearchTownPresets = <SmartOrigin>[
  SmartOrigin(
    label: 'Praha',
    point: GeoPoint(latitude: 50.083, longitude: 14.421),
  ),
  SmartOrigin(
    label: 'Brno',
    point: GeoPoint(latitude: 49.195, longitude: 16.608),
  ),
  SmartOrigin(
    label: 'Ostrava',
    point: GeoPoint(latitude: 49.835, longitude: 18.292),
  ),
  SmartOrigin(
    label: 'Plzeň',
    point: GeoPoint(latitude: 49.748, longitude: 13.377),
  ),
  SmartOrigin(
    label: 'Liberec',
    point: GeoPoint(latitude: 50.767, longitude: 15.056),
  ),
  SmartOrigin(
    label: 'Olomouc',
    point: GeoPoint(latitude: 49.594, longitude: 17.251),
  ),
  SmartOrigin(
    label: 'Hradec Králové',
    point: GeoPoint(latitude: 50.209, longitude: 15.832),
  ),
  SmartOrigin(
    label: 'Pardubice',
    point: GeoPoint(latitude: 50.038, longitude: 15.779),
  ),
  SmartOrigin(
    label: 'Ústí nad Labem',
    point: GeoPoint(latitude: 50.661, longitude: 14.032),
  ),
  SmartOrigin(
    label: 'České Budějovice',
    point: GeoPoint(latitude: 48.975, longitude: 14.480),
  ),
  SmartOrigin(
    label: 'Zlín',
    point: GeoPoint(latitude: 49.224, longitude: 17.663),
  ),
  SmartOrigin(
    label: 'Jihlava',
    point: GeoPoint(latitude: 49.397, longitude: 15.591),
  ),
  SmartOrigin(
    label: 'Karlovy Vary',
    point: GeoPoint(latitude: 50.232, longitude: 12.871),
  ),
  SmartOrigin(
    label: 'Trutnov',
    point: GeoPoint(latitude: 50.561, longitude: 15.913),
  ),
  SmartOrigin(
    label: 'Turnov',
    point: GeoPoint(latitude: 50.587, longitude: 15.158),
  ),
  SmartOrigin(
    label: 'Děčín',
    point: GeoPoint(latitude: 50.774, longitude: 14.213),
  ),
];

/// A smart-search request over the whole catalog.
@immutable
class SmartSearchQuery {
  const SmartSearchQuery({
    this.discipline = SmartDiscipline.routes,
    this.routeTypes = const {},
    this.minBand,
    this.maxBand,
    this.origin,
    this.radiusKm = 50,
  });

  final SmartDiscipline discipline;

  /// Which route disciplines to require (subset of {sport, trad}); empty
  /// means either. Ignored when [discipline] is boulders.
  final Set<ClimbingType> routeTypes;

  /// Inclusive difficulty-band bounds on the discipline's scale; null
  /// means unbounded on that side (and, when both are null, no grade
  /// filter at all, so areas with unknown grades still match).
  final int? minBand;
  final int? maxBand;

  /// Distance origin; null means no distance filter (results ranked by
  /// route count instead).
  final SmartOrigin? origin;
  final double radiusKm;

  bool get hasGradeFilter => minBand != null || maxBand != null;

  SmartSearchQuery copyWith({
    SmartDiscipline? discipline,
    Set<ClimbingType>? routeTypes,
    int? Function()? minBand,
    int? Function()? maxBand,
    SmartOrigin? Function()? origin,
    double? radiusKm,
  }) {
    return SmartSearchQuery(
      discipline: discipline ?? this.discipline,
      routeTypes: routeTypes ?? this.routeTypes,
      minBand: minBand != null ? minBand() : this.minBand,
      maxBand: maxBand != null ? maxBand() : this.maxBand,
      origin: origin != null ? origin() : this.origin,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}

/// A matched area with its distance from the query origin (null when the
/// query has no origin).
typedef SmartSearchResult = ({ClimbingArea area, double? distanceKm});

/// Runs [query] over [areas]. Pure and catalog-summary-only (no sector
/// trees), so it filters the whole catalog cheaply and is unit testable.
List<SmartSearchResult> smartSearchAreas(
  List<ClimbingArea> areas,
  SmartSearchQuery query,
) {
  final results = <SmartSearchResult>[];
  for (final area in areas) {
    if (!_matchesDiscipline(area, query)) continue;

    double? distanceKm;
    if (query.origin case final origin?) {
      distanceKm = origin.point.distanceInKmTo(area.location);
      if (distanceKm > query.radiusKm) continue;
    }
    results.add((area: area, distanceKm: distanceKm));
  }

  results.sort((a, b) {
    final da = a.distanceKm;
    final db = b.distanceKm;
    if (da != null && db != null) return da.compareTo(db);
    // No origin: biggest areas first.
    return b.area.routeCount.compareTo(a.area.routeCount);
  });
  return results;
}

bool _matchesDiscipline(ClimbingArea area, SmartSearchQuery query) {
  switch (query.discipline) {
    case SmartDiscipline.routes:
      final wanted = query.routeTypes.isEmpty
          ? const {ClimbingType.sport, ClimbingType.trad}
          : query.routeTypes;
      if (!area.climbingTypes.any(wanted.contains)) return false;
      return _bandOverlaps(area.routeGradeRange, query);
    case SmartDiscipline.boulders:
      if (!area.climbingTypes.contains(ClimbingType.boulder)) return false;
      return _bandOverlaps(area.boulderGradeRange, query);
  }
}

bool _bandOverlaps((int, int)? areaRange, SmartSearchQuery query) {
  if (!query.hasGradeFilter) return true;
  if (areaRange == null) return false;
  final (areaMin, areaMax) = areaRange;
  if (query.minBand != null && areaMax < query.minBand!) return false;
  if (query.maxBand != null && areaMin > query.maxBand!) return false;
  return true;
}
