import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/route_rating.dart';

class SupabaseRouteRatingsRepository implements RouteRatingsRepository {
  SupabaseRouteRatingsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<RouteRatingSummary> forRoute(String routeId) async {
    // Aggregate in one call; fetch the user's own stars separately.
    final aggregate = await _client.rpc(
      'route_rating_summary',
      params: {'route': routeId},
    );
    final row = (aggregate as List).isEmpty
        ? null
        : aggregate.first as Map<String, Object?>;
    final average = (row?['average'] as num?)?.toDouble() ?? 0;
    final count = (row?['rating_count'] as num?)?.toInt() ?? 0;

    int? myStars;
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      final mine = await _client
          .from('route_ratings')
          .select('stars')
          .eq('route_id', routeId)
          .eq('user_id', userId)
          .maybeSingle();
      myStars = (mine?['stars'] as num?)?.toInt();
    }
    return RouteRatingSummary(average: average, count: count, myStars: myStars);
  }

  @override
  Future<void> setMyRating(String routeId, int stars) async {
    await _client.from('route_ratings').upsert({
      'route_id': routeId,
      'stars': stars,
    });
  }

  @override
  Future<void> clearMyRating(String routeId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('route_ratings')
        .delete()
        .eq('route_id', routeId)
        .eq('user_id', userId);
  }
}
