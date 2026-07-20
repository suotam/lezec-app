import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/supabase_issue_reports_repository.dart';
import '../domain/issue_report.dart';

final issueReportsRepositoryProvider = Provider<IssueReportsRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseIssueReportsRepository(client);
});

/// Reports visible to the signed-in user (own ones; admins and managers
/// see their scope thanks to RLS). Null when signed out or no backend.
final visibleIssueReportsProvider = FutureProvider<List<IssueReport>?>((
  ref,
) async {
  final repository = ref.watch(issueReportsRepositoryProvider);
  final user = ref.watch(currentUserProvider).value;
  if (repository == null || user == null) return null;
  return repository.visibleReports();
});
