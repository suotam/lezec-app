import 'package:flutter/foundation.dart';

import '../../climbing_routes/domain/route_grade.dart';

/// Style of an ascent, following the abbreviations Czech climbers use.
enum AscentStyle {
  onsight,
  flash,
  redpoint,
  pinkpoint,
  allFree,
  topRope,
  solo,
  attempt,
}

/// One diary entry: a route climbed (or attempted) on a given day.
///
/// Route and location display fields are captured at logging time so the
/// entry stays readable even after the catalog is replaced by a newer
/// import that renames or removes the route.
@immutable
class Ascent {
  const Ascent({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.grade,
    required this.areaId,
    required this.areaName,
    required this.sectorName,
    required this.style,
    required this.date,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String routeId;
  final String routeName;
  final RouteGrade grade;
  final String areaId;
  final String areaName;
  final String sectorName;
  final AscentStyle style;

  /// Day the route was climbed; time of day is not tracked.
  final DateTime date;

  final DateTime createdAt;
  final String? note;
}
