import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../../auth/presentation/auth_providers.dart';
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
