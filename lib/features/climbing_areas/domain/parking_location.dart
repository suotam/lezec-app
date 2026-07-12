import 'package:flutter/foundation.dart';

import 'geo_point.dart';

/// A recommended parking spot for an area.
@immutable
class ParkingLocation {
  const ParkingLocation({
    required this.id,
    required this.name,
    required this.location,
    this.note,
  });

  final String id;
  final String name;
  final GeoPoint location;
  final String? note;
}
