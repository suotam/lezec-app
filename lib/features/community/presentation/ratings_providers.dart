import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../climbing_routes/domain/route_context.dart';
import '../../climbing_routes/presentation/climbing_routes_providers.dart';
import '../data/supabase_route_ratings_repository.dart';
import '../domain/route_rating.dart';

final routeRatingsRepositoryProvider = Provider<RouteRatingsRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseRouteRatingsRepository(client);
});

/// A route's community rating; null without a backend. Re-fetches when the
/// signed-in user changes (so "my stars" is correct after sign-in).
final routeRatingProvider = FutureProvider.family<RouteRatingSummary?, String>((
  ref,
  routeId,
) async {
  final repository = ref.watch(routeRatingsRepositoryProvider);
  if (repository == null) return null;
  ref.watch(currentUserProvider);
  return repository.forRoute(routeId);
});

/// A top-rated route resolved against the local catalog for display.
typedef TopRatedRoute = ({RouteContext context, double average, int count});

/// Best-rated routes for the discover screen; null without a backend,
/// empty until the community has rated anything. Backend gives the ids
/// and averages; names/grades/area come from the offline catalog.
final topRatedRoutesProvider = FutureProvider<List<TopRatedRoute>?>((
  ref,
) async {
  final repository = ref.watch(routeRatingsRepositoryProvider);
  if (repository == null) return null;
  final rated = await repository.topRated(limit: 10);
  final routeRepository = ref.watch(climbingRouteRepositoryProvider);
  final results = <TopRatedRoute>[];
  for (final entry in rated) {
    final context = await routeRepository.getRouteById(entry.routeId);
    // Skip ratings for routes absent from the current catalog version.
    if (context == null) continue;
    results.add((context: context, average: entry.average, count: entry.count));
  }
  return results;
});
