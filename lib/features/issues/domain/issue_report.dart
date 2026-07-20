import 'package:flutter/foundation.dart';

enum IssueStatus { open, resolved, dismissed }

/// A maintenance issue (worn bolt, loose block, access problem…) reported
/// for an area. Area/route names are denormalized at filing time.
@immutable
class IssueReport {
  const IssueReport({
    required this.id,
    required this.userId,
    required this.areaId,
    required this.areaName,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String areaId;
  final String areaName;
  final String description;
  final IssueStatus status;
  final DateTime createdAt;
}

/// Issue reports. RLS decides visibility: reporters see their own,
/// admins and the area's managers see everything for their scope.
abstract interface class IssueReportsRepository {
  Future<void> fileReport({
    required String areaId,
    required String areaName,
    required String description,
  });

  /// Every report the signed-in user may see, newest first.
  Future<List<IssueReport>> visibleReports();

  /// Admins/area managers only (enforced server-side).
  Future<void> setStatus(String reportId, IssueStatus status);
}
