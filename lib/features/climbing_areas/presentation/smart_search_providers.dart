import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utilities/location_service.dart';
import '../../climbing_routes/domain/climbing_type.dart';
import '../domain/smart_search.dart';
import 'climbing_areas_providers.dart';

/// The current smart-search request. Widgets mutate it only through these
/// methods.
class SmartSearchController extends Notifier<SmartSearchQuery> {
  @override
  SmartSearchQuery build() => const SmartSearchQuery();

  void setDiscipline(SmartDiscipline discipline) {
    // Switching scale invalidates the old band bounds and route types.
    state = SmartSearchQuery(
      discipline: discipline,
      origin: state.origin,
      radiusKm: state.radiusKm,
    );
  }

  void toggleRouteType(ClimbingType type) {
    final types = {...state.routeTypes};
    if (!types.remove(type)) types.add(type);
    state = state.copyWith(routeTypes: types);
  }

  /// [min]/[max] are band indices; pass nulls to clear the grade filter.
  void setBands(int? min, int? max) {
    state = state.copyWith(minBand: () => min, maxBand: () => max);
  }

  void setRadiusKm(double km) => state = state.copyWith(radiusKm: km);

  void setTownOrigin(SmartOrigin? origin) =>
      state = state.copyWith(origin: () => origin);

  void clearOrigin() => state = state.copyWith(origin: () => null);

  /// Uses the device position as origin; returns false (leaving the
  /// origin unchanged) when no position is available.
  Future<bool> useMyLocation(String label) async {
    final point = await ref.read(locationServiceProvider).getCurrentPosition();
    if (point == null) return false;
    state = state.copyWith(
      origin: () => SmartOrigin(label: label, point: point),
    );
    return true;
  }
}

final smartSearchQueryProvider =
    NotifierProvider<SmartSearchController, SmartSearchQuery>(
      SmartSearchController.new,
    );

/// Areas matching the current smart-search request. Stays an [AsyncValue]
/// so the screen shows the catalog's load/error states.
final smartSearchResultsProvider =
    Provider<AsyncValue<List<SmartSearchResult>>>((ref) {
      final query = ref.watch(smartSearchQueryProvider);
      return ref
          .watch(areasProvider)
          .whenData((areas) => smartSearchAreas(areas, query));
    });
