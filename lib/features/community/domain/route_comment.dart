import 'package:flutter/foundation.dart';

/// One community comment under a route.
@immutable
class RouteComment {
  const RouteComment({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String routeId;
  final String userId;
  final String authorName;
  final String body;
  final DateTime createdAt;
}

/// Community comments. Reading works without an account; writing and
/// removing require one (removal of others' comments is admin-only,
/// enforced by RLS).
abstract interface class CommentsRepository {
  /// Comments for [routeId], newest first.
  Future<List<RouteComment>> forRoute(String routeId);

  Future<void> add({
    required String routeId,
    required String body,
    required String authorName,
  });

  /// Soft-deletes a comment.
  Future<void> remove(String commentId);
}
