import 'package:flutter/foundation.dart';

/// A geographic climbing region grouping several areas.
@immutable
class ClimbingRegion {
  const ClimbingRegion({
    required this.id,
    required this.name,
    required this.country,
  });

  final String id;
  final String name;

  /// ISO 3166-1 alpha-2 country code, e.g. `CZ`.
  final String country;
}
