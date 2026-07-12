import 'package:flutter/foundation.dart';

import '../../climbing_areas/domain/climbing_area.dart';
import '../../climbing_areas/domain/climbing_rock.dart';
import '../../climbing_areas/domain/climbing_sector.dart';
import 'climbing_route.dart';

/// A route together with where it lives, for the route detail screen.
/// [rock] is null for routes assigned directly to a sector.
@immutable
class RouteContext {
  const RouteContext({
    required this.route,
    required this.area,
    required this.sector,
    this.rock,
  });

  final ClimbingRoute route;
  final ClimbingArea area;
  final ClimbingSector sector;
  final ClimbingRock? rock;
}
