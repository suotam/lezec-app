import 'package:drift/drift.dart';

import '../../../core/database/crux_database.dart';
import '../../climbing_routes/domain/route_grade.dart';
import '../domain/ascent.dart' as domain;
import '../domain/diary_repository.dart';

/// Drift-backed climbing diary.
class DriftDiaryRepository implements DiaryRepository {
  DriftDiaryRepository(this._db);

  final CruxDatabase _db;

  @override
  Future<List<domain.Ascent>> getAscents() async {
    final query = _db.select(_db.ascents)
      ..orderBy([
        (t) => OrderingTerm.desc(t.climbedOn),
        (t) => OrderingTerm.desc(t.createdAtMicros),
      ]);
    return [for (final row in await query.get()) _toDomain(row)];
  }

  @override
  Future<void> addAscent(domain.Ascent ascent) =>
      _db.into(_db.ascents).insert(_toCompanion(ascent));

  @override
  Future<void> updateAscent(domain.Ascent ascent) =>
      _db.into(_db.ascents).insertOnConflictUpdate(_toCompanion(ascent));

  AscentsCompanion _toCompanion(domain.Ascent ascent) =>
      AscentsCompanion.insert(
        id: ascent.id,
        routeId: ascent.routeId,
        routeName: ascent.routeName,
        gradeValue: ascent.grade.value,
        gradeSystem: ascent.grade.system.name,
        areaId: ascent.areaId,
        areaName: ascent.areaName,
        sectorName: ascent.sectorName,
        style: ascent.style.name,
        climbedOn: ascent.date,
        note: Value(ascent.note),
        createdAtMicros: ascent.createdAt.microsecondsSinceEpoch,
      );

  @override
  Future<void> deleteAscent(String id) =>
      (_db.delete(_db.ascents)..where((t) => t.id.equals(id))).go();

  domain.Ascent _toDomain(AscentRow row) => domain.Ascent(
    id: row.id,
    routeId: row.routeId,
    routeName: row.routeName,
    grade: RouteGrade(
      system: _enumOrFirst(GradingSystem.values, row.gradeSystem),
      value: row.gradeValue,
    ),
    areaId: row.areaId,
    areaName: row.areaName,
    sectorName: row.sectorName,
    style: _enumOrFirst(domain.AscentStyle.values, row.style),
    date: row.climbedOn,
    createdAt: DateTime.fromMicrosecondsSinceEpoch(row.createdAtMicros),
    note: row.note,
  );

  /// Rows are only ever written by this repository, so an unknown enum name
  /// means a corrupted row; degrade to the first value instead of crashing
  /// the whole diary.
  T _enumOrFirst<T extends Enum>(List<T> values, String name) =>
      values.asNameMap()[name] ?? values.first;
}
