import '../../../core/database/crux_database.dart';
import '../../climbing_areas/data/drift_catalog_store.dart';
import '../../climbing_areas/domain/climbing_area_repository.dart';
import '../domain/climbing_route_repository.dart';
import '../domain/route_context.dart';

/// [ClimbingRouteRepository] backed by the local catalog store. The route
/// index maps the id to its area, so only that area's document is parsed.
class DriftClimbingRouteRepository implements ClimbingRouteRepository {
  DriftClimbingRouteRepository(this._db, this._store, this._areaRepository);

  final CruxDatabase _db;
  final DriftCatalogStore _store;
  final ClimbingAreaRepository _areaRepository;

  @override
  Future<RouteContext?> getRouteById(String id) async {
    await _store.ensureSeeded();
    final indexRow = await (_db.select(
      _db.catalogRouteIndex,
    )..where((t) => t.routeId.equals(id))).getSingleOrNull();
    if (indexRow == null) return null;

    final area = await _areaRepository.getAreaById(indexRow.areaId);
    if (area == null) return null;

    for (final sector in area.sectors) {
      for (final rock in sector.rocks) {
        for (final route in rock.routes) {
          if (route.id == id) {
            return RouteContext(
              route: route,
              area: area,
              sector: sector,
              rock: rock,
            );
          }
        }
      }
      for (final route in sector.routes) {
        if (route.id == id) {
          return RouteContext(route: route, area: area, sector: sector);
        }
      }
    }
    return null;
  }
}
