import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';
import 'package:lezec_app/features/diary/data/drift_diary_repository.dart';
import 'package:lezec_app/features/diary/domain/ascent.dart';

void main() {
  late CruxDatabase db;
  late DriftDiaryRepository repository;

  setUp(() {
    db = CruxDatabase(NativeDatabase.memory());
    repository = DriftDiaryRepository(db);
  });
  tearDown(() => db.close());

  Ascent buildAscent({
    required String id,
    DateTime? date,
    DateTime? createdAt,
    AscentStyle style = AscentStyle.redpoint,
    String? note,
  }) {
    return Ascent(
      id: id,
      routeId: 'route-hrana',
      routeName: 'Testová hrana',
      grade: const RouteGrade(system: GradingSystem.french, value: '6b+'),
      areaId: 'area-lom',
      areaName: 'Testový lom',
      sectorName: 'Stěna',
      style: style,
      date: date ?? DateTime(2026, 7, 10),
      createdAt: createdAt ?? DateTime(2026, 7, 10, 18, 30),
      note: note,
    );
  }

  test('round-trips every field', () async {
    await repository.addAscent(
      buildAscent(id: 'a1', style: AscentStyle.onsight, note: 'Super den.'),
    );

    final ascent = (await repository.getAscents()).single;
    expect(ascent.id, 'a1');
    expect(ascent.routeId, 'route-hrana');
    expect(ascent.routeName, 'Testová hrana');
    expect(ascent.grade.value, '6b+');
    expect(ascent.grade.system, GradingSystem.french);
    expect(ascent.areaName, 'Testový lom');
    expect(ascent.sectorName, 'Stěna');
    expect(ascent.style, AscentStyle.onsight);
    expect(ascent.date, DateTime(2026, 7, 10));
    expect(ascent.note, 'Super den.');
  });

  test('a missing note stays null', () async {
    await repository.addAscent(buildAscent(id: 'a1'));

    expect((await repository.getAscents()).single.note, isNull);
  });

  test('orders newest climb first, ties broken by logging time', () async {
    await repository.addAscent(
      buildAscent(
        id: 'older-climb',
        date: DateTime(2026, 7, 1),
        createdAt: DateTime(2026, 7, 10, 12),
      ),
    );
    await repository.addAscent(
      buildAscent(
        id: 'same-day-logged-later',
        date: DateTime(2026, 7, 10),
        createdAt: DateTime(2026, 7, 10, 20),
      ),
    );
    await repository.addAscent(
      buildAscent(
        id: 'same-day-logged-earlier',
        date: DateTime(2026, 7, 10),
        createdAt: DateTime(2026, 7, 10, 10),
      ),
    );

    final ids = [for (final a in await repository.getAscents()) a.id];
    expect(ids, [
      'same-day-logged-later',
      'same-day-logged-earlier',
      'older-climb',
    ]);
  });

  test('updateAscent replaces the stored entry', () async {
    await repository.addAscent(buildAscent(id: 'a1', note: 'původní'));

    await repository.updateAscent(
      buildAscent(id: 'a1', style: AscentStyle.topRope, note: null),
    );

    final ascent = (await repository.getAscents()).single;
    expect(ascent.style, AscentStyle.topRope);
    expect(ascent.note, isNull);
  });

  test('deletes an entry', () async {
    await repository.addAscent(buildAscent(id: 'a1'));
    await repository.addAscent(buildAscent(id: 'a2'));

    await repository.deleteAscent('a1');

    final ids = [for (final a in await repository.getAscents()) a.id];
    expect(ids, ['a2']);
  });
}
