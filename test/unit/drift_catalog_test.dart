import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/features/climbing_areas/data/demo_catalog_data_source.dart';
import 'package:lezec_app/features/climbing_areas/data/drift_catalog_store.dart';
import 'package:lezec_app/features/climbing_areas/data/drift_climbing_area_repository.dart';
import 'package:lezec_app/features/climbing_routes/data/drift_climbing_route_repository.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CruxDatabase db;

  setUp(() => db = CruxDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ({
    DriftClimbingAreaRepository areas,
    DriftClimbingRouteRepository routes,
  })
  buildRepositories({String? catalogJson}) {
    final store = DriftCatalogStore(
      db,
      DemoCatalogDataSource(
        bundle: FakeAssetBundle(catalogJson ?? testCatalogJson),
      ),
    );
    final areaRepository = DriftClimbingAreaRepository(db, store);
    return (
      areas: areaRepository,
      routes: DriftClimbingRouteRepository(db, store, areaRepository),
    );
  }

  test('seeds the catalog and reads regions and area summaries', () async {
    final repos = buildRepositories();

    final regions = await repos.areas.getRegions();
    expect(regions.map((r) => r.id), ['region-a', 'region-b']);

    // getAreas returns summary projections: counts without sector trees.
    final areas = await repos.areas.getAreas();
    expect(areas.map((a) => a.name), ['Testové věže', 'Testový lom']);
    expect(areas.first.regionName, 'Testový region A');
    expect(areas.first.sectors, isEmpty);
    expect(areas.first.sectorCount, 1);
    expect(areas.first.routeCount, 1);
    expect(areas.last.routeCount, 2);
    expect(areas.first.restrictions, isNotEmpty,
        reason: 'restrictions must survive in the summary projection');
  });

  test('getAreaById parses a single stored document', () async {
    final repos = buildRepositories();

    final area = await repos.areas.getAreaById('area-lom');
    expect(area?.name, 'Testový lom');
    expect(area?.sectors.single.routes, hasLength(2));

    expect(await repos.areas.getAreaById('missing'), isNull);
  });

  test('getRouteById resolves rock and sector-direct routes', () async {
    final repos = buildRepositories();

    final rockRoute = await repos.routes.getRouteById('route-spara');
    expect(rockRoute?.route.name, 'Testová spára');
    expect(rockRoute?.area.id, 'area-piskovce');
    expect(rockRoute?.sector.id, 'sector-veze');
    expect(rockRoute?.rock?.id, 'rock-vez');

    final sectorRoute = await repos.routes.getRouteById('route-hrana');
    expect(sectorRoute?.route.name, 'Testová hrana');
    expect(sectorRoute?.rock, isNull);

    expect(await repos.routes.getRouteById('missing'), isNull);
  });

  test('reseeds when the catalog version changes', () async {
    await buildRepositories().areas.getAreas();

    final updatedJson = testCatalogJson
        .replaceFirst('"version": 1', '"version": 2')
        .replaceFirst('Testový lom', 'Nový lom');
    final updated = buildRepositories(catalogJson: updatedJson);

    final names = (await updated.areas.getAreas()).map((a) => a.name);
    expect(names, contains('Nový lom'));
    expect(names, isNot(contains('Testový lom')));
  });

  test('keeps the imported catalog while the version is unchanged', () async {
    await buildRepositories().areas.getAreas();

    final changedContentSameVersion = testCatalogJson.replaceFirst(
      'Testový lom',
      'Nový lom',
    );
    final updated = buildRepositories(catalogJson: changedContentSameVersion);

    final names = (await updated.areas.getAreas()).map((a) => a.name);
    expect(names, contains('Testový lom'));
    expect(names, isNot(contains('Nový lom')));
  });
}
