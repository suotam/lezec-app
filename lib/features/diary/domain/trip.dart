import 'package:flutter/foundation.dart';

/// One diary trip log: a day at an area with an optional note. The routes
/// climbed during the trip are ordinary [Ascent]s carrying this trip's id,
/// so stats and filters keep working unchanged.
@immutable
class Trip {
  const Trip({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.date,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String areaId;
  final String areaName;

  /// Day of the trip; time of day is not tracked.
  final DateTime date;

  final DateTime createdAt;
  final String? note;
}
