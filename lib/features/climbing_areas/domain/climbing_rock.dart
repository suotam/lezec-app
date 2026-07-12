import 'package:flutter/foundation.dart';

import '../../climbing_routes/domain/climbing_route.dart';

/// A single rock, tower, wall or boulder inside a sector.
@immutable
class ClimbingRock {
  const ClimbingRock({
    required this.id,
    required this.name,
    this.description,
    this.routes = const [],
  });

  final String id;
  final String name;
  final String? description;
  final List<ClimbingRoute> routes;
}
