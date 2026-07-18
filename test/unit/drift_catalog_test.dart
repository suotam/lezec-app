import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/features/climbing_areas/data/demo_catalog_data_source.dart';
import 'package:lezec_app/features/climbing_areas/data/drift_catalog_search_repository.dart';
import 'package:lezec_app/features/climbing_areas/data/drift_catalog_store.dart';
import 'package:lezec_app/features/climbing_areas/data/drift_climbing_area_repository.dart';
import 'package:lezec_app/features/climbing_areas/domain/catalog_search.dart';
import 'package:lezec_app/features/climbing_routes/data/drift_climbing_route_repository.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CruxDatabase db;

  setUp(() => db = CruxDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ({
    DriftClimbingAreaRepository areas,
    DriftClimbingRouteRepository routes,
    DriftCatalogSearchRepository search,
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
      search: DriftCatalogSearchRepository(db, store),
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
    expect(
      areas.first.restrictions,
      isNotEmpty,
      reason: 'restrictions must survive in the summary projection',
    );
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

  group('catalog search', () {
    test('finds a route with its navigation context and grade', () async {
      final results = await buildRepositories().search.search('hrana');

      expect(results.sectors, isEmpty);
      expect(results.rocks, isEmpty);
      final route = results.routes.single;
      expect(route.type, CatalogSearchResultType.route);
      expect(route.name, 'Testová hrana');
      expect(route.areaId, 'area-lom');
      expect(route.areaName, 'Testový lom');
      expect(route.sectorId, 'sector-stena');
      expect(route.sectorName, 'Stěna');
      expect(
        route.grade,
        const RouteGrade(system: GradingSystem.french, value: '6b+'),
      );
    });

    test('finds sectors and rocks, diacritics-insensitively', () async {
      final results = await buildRepositories().search.search('vez');

      final sector = results.sectors.single;
      expect(sector.type, CatalogSearchResultType.sector);
      expect(sector.name, 'Věže');
      expect(sector.sectorId, sector.id);
      expect(sector.sectorName, isNull);

      final rock = results.rocks.single;
      expect(rock.type, CatalogSearchResultType.rock);
      expect(rock.name, 'Hlavní věž');
      expect(rock.sectorId, 'sector-veze');
      expect(rock.sectorName, 'Věže');
      expect(rock.areaId, 'area-piskovce');

      expect(results.routes, isEmpty);
    });

    test('requires every query word to match', () async {
      final search = buildRepositories().search;

      final both = await search.search('testova hrana');
      expect(both.routes.map((r) => r.name), ['Testová hrana']);

      expect((await search.search('hrana veze')).isEmpty, isTrue);
    });

    test(
      'returns nothing for a blank query without touching the store',
      () async {
        final results = await buildRepositories().search.search('   ');
        expect(results.isEmpty, isTrue);
      },
    );

    test('caps each group at limitPerType, prefix matches first', () async {
      final results = await buildRepositories().search.search(
        'testova',
        limitPerType: 2,
      );
      expect(results.routes, hasLength(2));
      expect(results.routes.first.name, 'Testová hrana');
    });

    test('reseeding replaces the search index', () async {
      await buildRepositories().search.search('hrana');

      final updatedJson = testCatalogJson
          .replaceFirst('"version": 1', '"version": 2')
          .replaceFirst('Testová hrana', 'Přejmenovaný kout');
      final updated = buildRepositories(catalogJson: updatedJson);

      expect((await updated.search.search('hrana')).isEmpty, isTrue);
      final renamed = await updated.search.search('prejmenovany');
      expect(renamed.routes.single.name, 'Přejmenovaný kout');
    });
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
