import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/climbing_areas/domain/geo_point.dart';

/// Abstraction over device positioning so widgets and tests never touch
/// the geolocator plugin directly.
abstract interface class LocationService {
  /// The current position, or null when location services are off or the
  /// user denied permission. Never throws.
  Future<GeoPoint?> getCurrentPosition();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<GeoPoint?> getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on Exception {
      // Sorting by distance is optional sugar; any failure means "no
      // position", never a crash.
      return null;
    }
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => GeolocatorLocationService(),
);
