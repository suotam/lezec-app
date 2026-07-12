import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../climbing_routes/domain/climbing_type.dart';
import '../data/demo_catalog_data_source.dart';
import '../data/drift_catalog_store.dart';
import '../data/drift_climbing_area_repository.dart';
import '../data/drift_recently_viewed_repository.dart';
import '../domain/area_filter.dart';
import '../domain/climbing_area.dart';
import '../domain/climbing_area_repository.dart';
import '../domain/climbing_sector.dart';
import '../domain/recently_viewed_areas_repository.dart';
import '../domain/rock_type.dart';

final demoCatalogDataSourceProvider = Provider<DemoCatalogDataSource>(
  (ref) => DemoCatalogDataSource(),
);

/// Imports the bundled catalog into the local database (once per catalog
/// version) and hands out per-area documents.
final driftCatalogStoreProvider = Provider<DriftCatalogStore>(
  (ref) => DriftCatalogStore(
    ref.watch(databaseProvider),
    ref.watch(demoCatalogDataSourceProvider),
  ),
);

final climbingAreaRepositoryProvider = Provider<ClimbingAreaRepository>(
  (ref) => DriftClimbingAreaRepository(
    ref.watch(databaseProvider),
    ref.watch(driftCatalogStoreProvider),
  ),
);

final areasProvider = FutureProvider<List<ClimbingArea>>(
  (ref) => ref.watch(climbingAreaRepositoryProvider).getAreas(),
);

final areaByIdProvider = FutureProvider.family<ClimbingArea?, String>(
  (ref, id) => ref.watch(climbingAreaRepositoryProvider).getAreaById(id),
);

final sectorProvider =
    FutureProvider.family<ClimbingSector?, ({String areaId, String sectorId})>((
      ref,
      ids,
    ) async {
      final area = await ref.watch(areaByIdProvider(ids.areaId).future);
      if (area == null) return null;
      for (final sector in area.sectors) {
        if (sector.id == ids.sectorId) return sector;
      }
      return null;
    });

/// Current search query and filters of the areas screen. Widgets mutate the
/// filter only through these methods, never by building [AreaFilter]s.
class AreaFilterController extends Notifier<AreaFilter> {
  @override
  AreaFilter build() => const AreaFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void toggleClimbingType(ClimbingType type) {
    state = state.copyWith(climbingTypes: _toggled(state.climbingTypes, type));
  }

  void toggleRockType(RockType type) {
    state = state.copyWith(rockTypes: _toggled(state.rockTypes, type));
  }

  void clear() => state = const AreaFilter();

  Set<T> _toggled<T>(Set<T> set, T value) {
    final result = {...set};
    if (!result.remove(value)) result.add(value);
    return result;
  }
}

final areaFilterProvider = NotifierProvider<AreaFilterController, AreaFilter>(
  AreaFilterController.new,
);

/// Areas matching the current filter. Stays an [AsyncValue] so the screen
/// can show load/error states from the underlying catalog.
final filteredAreasProvider = Provider<AsyncValue<List<ClimbingArea>>>((ref) {
  final filter = ref.watch(areaFilterProvider);
  return ref
      .watch(areasProvider)
      .whenData((areas) => filterAreas(areas, filter));
});

final recentlyViewedRepositoryProvider =
    Provider<RecentlyViewedAreasRepository>(
      (ref) => DriftRecentlyViewedRepository(ref.watch(databaseProvider)),
    );

/// Recently opened areas, newest first, resolved to full models.
class RecentlyViewedAreasNotifier extends AsyncNotifier<List<ClimbingArea>> {
  @override
  Future<List<ClimbingArea>> build() async {
    final ids = await ref
        .watch(recentlyViewedRepositoryProvider)
        .getRecentlyViewedAreaIds();
    final areas = await ref.watch(areasProvider.future);
    final areasById = {for (final area in areas) area.id: area};
    return [for (final id in ids) ?areasById[id]];
  }

  Future<void> recordView(String areaId) async {
    await ref.read(recentlyViewedRepositoryProvider).recordAreaView(areaId);
    ref.invalidateSelf();
  }
}

final recentlyViewedAreasProvider =
    AsyncNotifierProvider<RecentlyViewedAreasNotifier, List<ClimbingArea>>(
      RecentlyViewedAreasNotifier.new,
    );
