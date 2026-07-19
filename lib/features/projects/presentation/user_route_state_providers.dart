import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../sync/presentation/sync_providers.dart';
import '../data/drift_user_route_state_repository.dart';
import '../domain/user_route_state_repository.dart';

final userRouteStateRepositoryProvider = Provider<UserRouteStateRepository>(
  (ref) => DriftUserRouteStateRepository(ref.watch(databaseProvider)),
);

/// The user's favorite and project route IDs.
@immutable
class UserRouteState {
  const UserRouteState({required this.favoriteIds, required this.projectIds});

  final Set<String> favoriteIds;
  final Set<String> projectIds;

  bool isFavorite(String routeId) => favoriteIds.contains(routeId);

  bool isProject(String routeId) => projectIds.contains(routeId);
}

/// Loads the persisted flags once and keeps them in sync as the user
/// toggles routes. All writes go through the repository so nothing lives
/// only in memory.
class UserRouteStateNotifier extends AsyncNotifier<UserRouteState> {
  UserRouteStateRepository get _repository =>
      ref.read(userRouteStateRepositoryProvider);

  @override
  Future<UserRouteState> build() async {
    final repository = ref.watch(userRouteStateRepositoryProvider);
    return UserRouteState(
      favoriteIds: await repository.getFavoriteRouteIds(),
      projectIds: await repository.getProjectRouteIds(),
    );
  }

  Future<void> toggleFavorite(String routeId) async {
    final current = await future;
    final isFavorite = !current.isFavorite(routeId);
    await _repository.setFavorite(routeId, isFavorite);
    state = AsyncData(
      UserRouteState(
        favoriteIds: await _repository.getFavoriteRouteIds(),
        projectIds: current.projectIds,
      ),
    );
    ref.read(syncControllerProvider.notifier).requestSync();
  }

  Future<void> toggleProject(String routeId) async {
    final current = await future;
    final isProject = !current.isProject(routeId);
    await _repository.setProject(routeId, isProject);
    state = AsyncData(
      UserRouteState(
        favoriteIds: current.favoriteIds,
        projectIds: await _repository.getProjectRouteIds(),
      ),
    );
    ref.read(syncControllerProvider.notifier).requestSync();
  }
}

final userRouteStateProvider =
    AsyncNotifierProvider<UserRouteStateNotifier, UserRouteState>(
      UserRouteStateNotifier.new,
    );
