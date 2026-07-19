import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';
import 'package:lezec_app/features/diary/data/drift_diary_repository.dart';
import 'package:lezec_app/features/diary/domain/ascent.dart';
import 'package:lezec_app/features/projects/data/drift_user_route_state_repository.dart';
import 'package:lezec_app/features/sync/data/drift_sync_store.dart';
import 'package:lezec_app/features/sync/data/sync_service.dart';
import 'package:lezec_app/features/sync/domain/sync_records.dart';

/// In-memory stand-in for the Supabase backend shared by the simulated
/// devices.
class FakeSyncBackend implements SyncBackend {
  final ascents = <String, AscentRecord>{};
  final flags = <String, RouteFlagRecord>{};
  final views = <String, AreaViewRecord>{};

  @override
  Future<List<AscentRecord>> fetchAscents() async => ascents.values.toList();

  @override
  Future<void> upsertAscents(List<AscentRecord> records) async {
    for (final record in records) {
      ascents[record.id] = record;
    }
  }

  @override
  Future<List<RouteFlagRecord>> fetchRouteFlags() async =>
      flags.values.toList();

  @override
  Future<void> upsertRouteFlags(List<RouteFlagRecord> records) async {
    for (final record in records) {
      flags[record.routeId] = record;
    }
  }

  @override
  Future<List<AreaViewRecord>> fetchAreaViews() async => views.values.toList();

  @override
  Future<void> upsertAreaViews(List<AreaViewRecord> records) async {
    for (final record in records) {
      views[record.areaId] = record;
    }
  }
}

Ascent ascent(String id, {String note = ''}) => Ascent(
  id: id,
  routeId: 'route-1',
  routeName: 'Testová cesta',
  grade: const RouteGrade(system: GradingSystem.french, value: '6a'),
  areaId: 'area-1',
  areaName: 'Oblast',
  sectorName: 'Sektor',
  style: AscentStyle.redpoint,
  date: DateTime(2026, 7, 1),
  createdAt: DateTime(2026, 7, 1, 18),
  note: note.isEmpty ? null : note,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CruxDatabase deviceA;
  late CruxDatabase deviceB;
  late FakeSyncBackend backend;
  late SyncService syncA;
  late SyncService syncB;

  setUp(() {
    deviceA = CruxDatabase(NativeDatabase.memory());
    deviceB = CruxDatabase(NativeDatabase.memory());
    backend = FakeSyncBackend();
    syncA = SyncService(store: DriftSyncStore(deviceA), backend: backend);
    syncB = SyncService(store: DriftSyncStore(deviceB), backend: backend);
  });

  tearDown(() async {
    await deviceA.close();
    await deviceB.close();
  });

  test('an ascent logged on one device appears on the other', () async {
    await DriftDiaryRepository(deviceA).addAscent(ascent('a1', note: 'super'));

    await syncA.sync();
    await syncB.sync();

    final onB = await DriftDiaryRepository(deviceB).getAscents();
    expect(onB.single.id, 'a1');
    expect(onB.single.note, 'super');
    expect(onB.single.routeName, 'Testová cesta');
  });

  test('a deletion propagates as a tombstone', () async {
    final diaryA = DriftDiaryRepository(deviceA);
    final diaryB = DriftDiaryRepository(deviceB);
    await diaryA.addAscent(ascent('a1'));
    await syncA.sync();
    await syncB.sync();
    expect(await diaryB.getAscents(), hasLength(1));

    await diaryA.deleteAscent('a1');
    await syncA.sync();
    await syncB.sync();

    expect(await diaryB.getAscents(), isEmpty);
    // The tombstone row still exists for future devices.
    expect(backend.ascents['a1']!.deletedAt, isNotNull);
  });

  test('newer edit wins regardless of sync order', () async {
    final diaryA = DriftDiaryRepository(deviceA);
    final diaryB = DriftDiaryRepository(deviceB);
    await diaryA.addAscent(ascent('a1', note: 'původní'));
    await syncA.sync();
    await syncB.sync();

    // B edits later than A.
    await diaryA.updateAscent(ascent('a1', note: 'z áčka'));
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await diaryB.updateAscent(ascent('a1', note: 'z béčka'));

    await syncA.sync();
    await syncB.sync();
    await syncA.sync();

    expect((await diaryA.getAscents()).single.note, 'z béčka');
    expect((await diaryB.getAscents()).single.note, 'z béčka');
  });

  test('favorites and projects sync including removals', () async {
    final flagsA = DriftUserRouteStateRepository(deviceA);
    final flagsB = DriftUserRouteStateRepository(deviceB);
    await flagsA.setFavorite('route-1', true);
    await flagsA.setProject('route-2', true);

    await syncA.sync();
    await syncB.sync();
    expect(await flagsB.getFavoriteRouteIds(), {'route-1'});
    expect(await flagsB.getProjectRouteIds(), {'route-2'});

    // Removal on B wins over the earlier set on A.
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await flagsB.setFavorite('route-1', false);
    await syncB.sync();
    await syncA.sync();

    expect(await flagsA.getFavoriteRouteIds(), isEmpty);
    expect(await flagsA.getProjectRouteIds(), {'route-2'});
  });

  test('sync is idempotent', () async {
    await DriftDiaryRepository(deviceA).addAscent(ascent('a1'));
    await syncA.sync();
    final snapshot = backend.ascents['a1'];

    await syncA.sync();
    await syncA.sync();

    expect(backend.ascents['a1'], same(snapshot));
    expect(await DriftDiaryRepository(deviceA).getAscents(), hasLength(1));
  });
}
