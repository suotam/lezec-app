import 'package:flutter/foundation.dart';

/// How to get from parking to the rock.
@immutable
class AccessInformation {
  const AccessInformation({required this.description, this.approachMinutes});

  final String description;
  final int? approachMinutes;
}
