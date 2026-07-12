import 'package:flutter/foundation.dart';

/// Severity of a restriction, ordered from least to most serious so lists
/// can be sorted by urgency.
enum RestrictionSeverity { info, warning, closure }

/// A restriction or warning attached to an area (nesting closures, wet-rock
/// rules, rockfall zones, …).
@immutable
class ClimbingRestriction {
  const ClimbingRestriction({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.seasonalNote,
  });

  final String id;
  final String title;
  final String description;
  final RestrictionSeverity severity;

  /// Human-readable validity, e.g. `1. 3. – 30. 6.`.
  final String? seasonalNote;
}
