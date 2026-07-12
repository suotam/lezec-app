import 'package:flutter/foundation.dart';

import '../../climbing_routes/domain/climbing_route.dart';
import '../../climbing_routes/domain/climbing_type.dart';
import 'access_information.dart';
import 'climbing_restriction.dart';
import 'climbing_sector.dart';
import 'geo_point.dart';
import 'parking_location.dart';
import 'rock_type.dart';

/// A climbing area — the unit users browse, search and navigate to.
@immutable
class ClimbingArea {
  const ClimbingArea({
    required this.id,
    required this.regionId,
    required this.regionName,
    required this.name,
    required this.summary,
    required this.description,
    required this.climbingTypes,
    required this.rockType,
    required this.location,
    this.parking = const [],
    this.access,
    this.restrictions = const [],
    this.sectors = const [],
  });

  final String id;
  final String regionId;

  /// Denormalized region name so list items don't need a region lookup.
  final String regionName;
  final String name;
  final String summary;
  final String description;
  final Set<ClimbingType> climbingTypes;
  final RockType rockType;
  final GeoPoint location;
  final List<ParkingLocation> parking;
  final AccessInformation? access;
  final List<ClimbingRestriction> restrictions;
  final List<ClimbingSector> sectors;

  int get sectorCount => sectors.length;

  List<ClimbingRoute> get allRoutes => [
    for (final sector in sectors) ...sector.allRoutes,
  ];

  int get routeCount => allRoutes.length;

  bool get hasRestrictions => restrictions.isNotEmpty;

  /// The most severe restriction, used for badge coloring.
  ClimbingRestriction? get topRestriction {
    if (restrictions.isEmpty) return null;
    return restrictions.reduce(
      (a, b) => a.severity.index >= b.severity.index ? a : b,
    );
  }
}
