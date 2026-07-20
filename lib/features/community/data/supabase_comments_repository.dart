import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/route_comment.dart';

class SupabaseCommentsRepository implements CommentsRepository {
  SupabaseCommentsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<RouteComment>> forRoute(String routeId) async {
    final rows = await _client
        .from('route_comments')
        .select()
        .eq('route_id', routeId)
        .order('created_at', ascending: false);
    return [
      for (final row in rows)
        RouteComment(
          id: row['id'] as String,
          routeId: row['route_id'] as String,
          userId: row['user_id'] as String,
          authorName: (row['author_name'] as String?) ?? '',
          body: row['body'] as String,
          createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        ),
    ];
  }

  @override
  Future<void> add({
    required String routeId,
    required String body,
    required String authorName,
  }) async {
    await _client.from('route_comments').insert({
      'route_id': routeId,
      'body': body,
      'author_name': authorName,
    });
  }

  @override
  Future<void> remove(String commentId) async {
    await _client
        .from('route_comments')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', commentId);
  }
}
