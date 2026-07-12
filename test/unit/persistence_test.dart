import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/core/database/legacy_preferences_migration.dart';
import 'package:lezec_app/features/climbing_areas/data/drift_recently_viewed_repository.dart';
import 'package:lezec_app/features/projects/data/drift_user_route_state_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CruxDatabase db;

  setUp(() => db = CruxDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('DriftUserRouteStateRepository', () {
    test('starts empty', () async {
      final repository = DriftUserRouteStateRepository(db);

      expect(await repository.getFavoriteRouteIds(), isEmpty);
      expect(await repository.getProjectRouteIds(), isEmpty);
    });

    test('persists favorites independently of projects', () async {
      final repository = DriftUserRouteStateRepository(db);

      await repository.setFavorite('route-1', true);
      await repository.setProject('route-2', true);

      expect(await repository.getFavoriteRouteIds(), {'route-1'});
      expect(await repository.getProjectRouteIds(), {'route-2'});
    });

    test('a route can be favorite and project at once', () async {
      final repository = DriftUserRouteStateRepository(db);

      await repository.setFavorite('route-1', true);
      await repository.setProject('route-1', true);
      await repository.setFavorite('route-1', false);

      expect(await repository.getFavoriteRouteIds(), isEmpty);
      expect(await repository.getProjectRouteIds(), {'route-1'});
    });

    test('survives a new repository instance (app restart)', () async {
      await DriftUserRouteStateRepository(db).setFavorite('route-1', true);

      final restarted = DriftUserRouteStateRepository(db);
      expect(await restarted.getFavoriteRouteIds(), {'route-1'});
    });

    test('unsetting removes the id', () async {
      final repository = DriftUserRouteStateRepository(db);

      await repository.setFavorite('route-1', true);
      await repository.setFavorite('route-1', false);

      expect(await repository.getFavoriteRouteIds(), isEmpty);
    });

    test('setting the same value twice is idempotent', () async {
      final repository = DriftUserRouteStateRepository(db);

      await repository.setFavorite('route-1', true);
      await repository.setFavorite('route-1', true);

      expect(await repository.getFavoriteRouteIds(), {'route-1'});
    });
  });

  group('DriftRecentlyViewedRepository', () {
    /// Deterministic strictly-increasing clock so rapid successive views
    /// never share a timestamp.
    DriftRecentlyViewedRepository buildRepository() {
      var tick = 0;
      return DriftRecentlyViewedRepository(
        db,
        clock: () => DateTime.fromMicrosecondsSinceEpoch(++tick),
      );
    }

    test('records newest first and deduplicates', () async {
      final repository = buildRepository();

      await repository.recordAreaView('a1');
      await repository.recordAreaView('a2');
      await repository.recordAreaView('a1');

      expect(await repository.getRecentlyViewedAreaIds(), ['a1', 'a2']);
    });

    test('caps the history length', () async {
      final repository = buildRepository();

      for (var i = 0; i < 15; i++) {
        await repository.recordAreaView('area-$i');
      }

      final ids = await repository.getRecentlyViewedAreaIds();
      expect(ids, hasLength(10));
      expect(ids.first, 'area-14');
    });
  });

  group('migrateLegacyPreferences', () {
    test('imports flags and history, then removes the legacy keys', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_route_ids': ['route-1', 'route-2'],
        'project_route_ids': ['route-2', 'route-3'],
        'recently_viewed_area_ids': ['area-b', 'area-a'],
      });
      final prefs = await SharedPreferences.getInstance();

      await migrateLegacyPreferences(db, prefs);

      final routeState = DriftUserRouteStateRepository(db);
      expect(await routeState.getFavoriteRouteIds(), {'route-1', 'route-2'});
      expect(await routeState.getProjectRouteIds(), {'route-2', 'route-3'});
      expect(
        await DriftRecentlyViewedRepository(db).getRecentlyViewedAreaIds(),
        ['area-b', 'area-a'],
      );
      expect(prefs.getStringList('favorite_route_ids'), isNull);
      expect(prefs.getStringList('project_route_ids'), isNull);
      expect(prefs.getStringList('recently_viewed_area_ids'), isNull);
    });

    test('is a no-op without legacy data', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await migrateLegacyPreferences(db, prefs);

      expect(
        await DriftUserRouteStateRepository(db).getFavoriteRouteIds(),
        isEmpty,
      );
    });
  });
}
