import 'package:flutter/foundation.dart';

import '../../climbing_routes/domain/climbing_route.dart';
import 'climbing_rock.dart';

/// A sector of an area. Routes may hang off individual [rocks] or sit
/// directly in [routes] — both shapes are valid and may be combined.
@immutable
class ClimbingSector {
  const ClimbingSector({
    required this.id,
    required this.name,
    this.description,
    this.accessNote,
    this.warnings = const [],
    this.rocks = const [],
    this.routes = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? accessNote;
  final List<String> warnings;
  final List<ClimbingRock> rocks;

  /// Routes assigned directly to the sector (no specific rock).
  final List<ClimbingRoute> routes;

  /// Every route in the sector, whether on a rock or direct.
  List<ClimbingRoute> get allRoutes => [
    for (final rock in rocks) ...rock.routes,
    ...routes,
  ];

  int get routeCount => allRoutes.length;
}
