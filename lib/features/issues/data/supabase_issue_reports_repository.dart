import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/issue_report.dart';

class SupabaseIssueReportsRepository implements IssueReportsRepository {
  SupabaseIssueReportsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> fileReport({
    required String areaId,
    required String areaName,
    required String description,
  }) async {
    await _client.from('issue_reports').insert({
      'area_id': areaId,
      'area_name': areaName,
      'description': description,
    });
  }

  @override
  Future<List<IssueReport>> visibleReports() async {
    final rows = await _client
        .from('issue_reports')
        .select()
        .order('created_at', ascending: false);
    return [
      for (final row in rows)
        IssueReport(
          id: row['id'] as String,
          userId: row['user_id'] as String,
          areaId: row['area_id'] as String,
          areaName: (row['area_name'] as String?) ?? '',
          description: row['description'] as String,
          status:
              IssueStatus.values.asNameMap()[row['status'] as String? ?? ''] ??
              IssueStatus.open,
          createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        ),
    ];
  }

  @override
  Future<void> setStatus(String reportId, IssueStatus status) async {
    await _client
        .from('issue_reports')
        .update({'status': status.name})
        .eq('id', reportId);
  }
}
