import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utilities/location_service.dart';
import '../../climbing_routes/domain/climbing_type.dart';
import '../data/catalog_update_service.dart';
import '../data/demo_catalog_data_source.dart';
import '../data/drift_catalog_search_repository.dart';
import '../data/drift_catalog_store.dart';
import '../data/drift_climbing_area_repository.dart';
import '../data/drift_recently_viewed_repository.dart';
import '../domain/area_filter.dart';
import '../domain/catalog_search.dart';
import '../domain/climbing_area.dart';
import '../domain/climbing_area_repository.dart';
import '../domain/climbing_region.dart';
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

final regionsProvider = FutureProvider<List<ClimbingRegion>>(
  (ref) => ref.watch(climbingAreaRepositoryProvider).getRegions(),
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

  void toggleRegion(String regionId) {
    state = state.copyWith(regionIds: _toggled(state.regionIds, regionId));
  }

  void setSort(AreaSort sort) {
    assert(sort != AreaSort.distance, 'use sortByDistance()');
    state = state.copyWith(sort: sort);
  }

  /// Switches to distance sorting; returns false (and keeps the current
  /// sort) when no position is available.
  Future<bool> sortByDistance() async {
    final origin = await ref.read(locationServiceProvider).getCurrentPosition();
    if (origin == null) return false;
    state = state.copyWith(sort: AreaSort.distance, origin: origin);
    return true;
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

final catalogSearchRepositoryProvider = Provider<CatalogSearchRepository>(
  (ref) => DriftCatalogSearchRepository(
    ref.watch(databaseProvider),
    ref.watch(driftCatalogStoreProvider),
  ),
);

/// The current query must have at least this many characters before the
/// catalog-wide search kicks in; shorter queries only filter the area list.
const catalogSearchMinQueryLength = 2;

/// How many rows each result group (sectors/rocks/routes) holds at most.
const catalogSearchResultsPerType = 20;

/// Sectors, rocks and routes matching the current search query. Watches
/// only the query, so toggling area filter chips does not re-query.
final catalogSearchResultsProvider = FutureProvider<CatalogSearchResults>((
  ref,
) async {
  final query = ref.watch(areaFilterProvider.select((f) => f.query)).trim();
  if (query.length < catalogSearchMinQueryLength) {
    return CatalogSearchResults.empty;
  }
  return ref
      .watch(catalogSearchRepositoryProvider)
      .search(query, limitPerType: catalogSearchResultsPerType);
});

/// Null without a configured backend (e.g. in tests, which override
/// [supabaseClientProvider] to null).
final catalogUpdateServiceProvider = Provider<CatalogUpdateService?>((ref) {
  if (ref.watch(supabaseClientProvider) == null) return null;
  return CatalogUpdateService(
    store: ref.watch(driftCatalogStoreProvider),
    baseUri: Uri.parse(
      '${SupabaseConfig.url}/storage/v1/object/public/catalog',
    ),
  );
});

/// One catalog update check per session (re-run via invalidate from the
/// profile screen). Null when no backend is configured; errors surface
/// as [AsyncError] and are treated as "no update" by the UI.
final catalogUpdateProvider = FutureProvider<CatalogUpdateResult?>((ref) async {
  final service = ref.watch(catalogUpdateServiceProvider);
  if (service == null) return null;
  final result = await service.checkAndApply();
  if (result.outcome == CatalogUpdateOutcome.updated) {
    ref.invalidate(areasProvider);
    ref.invalidate(regionsProvider);
    ref.invalidate(areaByIdProvider);
  }
  return result;
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
