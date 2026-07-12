import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../climbing_areas/presentation/climbing_areas_providers.dart';
import '../data/drift_climbing_route_repository.dart';
import '../domain/climbing_route_repository.dart';
import '../domain/route_context.dart';

final climbingRouteRepositoryProvider = Provider<ClimbingRouteRepository>(
  (ref) => DriftClimbingRouteRepository(
    ref.watch(databaseProvider),
    ref.watch(driftCatalogStoreProvider),
    ref.watch(climbingAreaRepositoryProvider),
  ),
);

final routeContextProvider = FutureProvider.family<RouteContext?, String>(
  (ref, id) => ref.watch(climbingRouteRepositoryProvider).getRouteById(id),
);
