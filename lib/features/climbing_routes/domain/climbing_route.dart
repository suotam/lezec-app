import 'package:flutter/foundation.dart';

import 'climbing_type.dart';
import 'route_grade.dart';

/// A single climbing route or boulder problem.
@immutable
class ClimbingRoute {
  const ClimbingRoute({
    required this.id,
    required this.name,
    required this.grade,
    required this.type,
    this.lengthMeters,
    this.description,
    this.protection,
    this.firstAscent,
    this.warnings = const [],
  });

  final String id;
  final String name;
  final RouteGrade grade;
  final ClimbingType type;
  final int? lengthMeters;
  final String? description;
  final String? protection;
  final String? firstAscent;
  final List<String> warnings;
}
