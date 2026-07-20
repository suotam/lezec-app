import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../data/supabase_comments_repository.dart';
import '../domain/route_comment.dart';

final commentsRepositoryProvider = Provider<CommentsRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseCommentsRepository(client);
});

/// Comments of one route, newest first; null when no backend is
/// configured (the section hides itself).
final routeCommentsProvider =
    FutureProvider.family<List<RouteComment>?, String>((ref, routeId) async {
      final repository = ref.watch(commentsRepositoryProvider);
      if (repository == null) return null;
      return repository.forRoute(routeId);
    });
