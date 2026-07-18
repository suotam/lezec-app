import 'dart:math';

import 'package:flutter/foundation.dart';

/// WGS84 coordinate.
@immutable
class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  /// Great-circle distance to [other] in kilometers (haversine formula).
  /// Plenty accurate for sorting areas by distance.
  double distanceInKmTo(GeoPoint other) {
    const earthRadiusKm = 6371.0;
    double radians(double degrees) => degrees * pi / 180;
    final dLat = radians(other.latitude - latitude);
    final dLng = radians(other.longitude - longitude);
    final a = pow(sin(dLat / 2), 2) +
        cos(radians(latitude)) *
            cos(radians(other.latitude)) *
            pow(sin(dLng / 2), 2);
    return 2 * earthRadiusKm * asin(sqrt(a.toDouble()));
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => '$latitude, $longitude';
}
