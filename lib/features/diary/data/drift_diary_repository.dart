import 'package:drift/drift.dart';

import '../../../core/database/crux_database.dart';
import '../../climbing_routes/domain/route_grade.dart';
import '../domain/ascent.dart' as domain;
import '../domain/diary_repository.dart';
import '../domain/trip.dart';

/// Drift-backed climbing diary.
class DriftDiaryRepository implements DiaryRepository {
  DriftDiaryRepository(this._db);

  final CruxDatabase _db;

  @override
  Future<List<domain.Ascent>> getAscents() async {
    final query = _db.select(_db.ascents)
      ..where((t) => t.deletedAtMicros.isNull())
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
        tripId: Value(ascent.tripId),
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
        updatedAtMicros: Value(DateTime.now().toUtc().microsecondsSinceEpoch),
      );

  /// Soft delete: the tombstone stays so sync propagates the removal to
  /// other devices; [getAscents] filters it out.
  @override
  Future<void> deleteAscent(String id) {
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    return (_db.update(_db.ascents)..where((t) => t.id.equals(id))).write(
      AscentsCompanion(
        deletedAtMicros: Value(now),
        updatedAtMicros: Value(now),
      ),
    );
  }

  domain.Ascent _toDomain(AscentRow row) => domain.Ascent(
    id: row.id,
    tripId: row.tripId,
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

  // --- trips ---------------------------------------------------------

  @override
  Future<List<Trip>> getTrips() async {
    final query = _db.select(_db.trips)
      ..where((t) => t.deletedAtMicros.isNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.tripDate),
        (t) => OrderingTerm.desc(t.createdAtMicros),
      ]);
    return [
      for (final row in await query.get())
        Trip(
          id: row.id,
          areaId: row.areaId,
          areaName: row.areaName,
          date: row.tripDate,
          createdAt: DateTime.fromMicrosecondsSinceEpoch(row.createdAtMicros),
          note: row.note,
        ),
    ];
  }

  @override
  Future<void> addTrip(Trip trip) => _db
      .into(_db.trips)
      .insert(
        TripsCompanion.insert(
          id: trip.id,
          areaId: trip.areaId,
          areaName: trip.areaName,
          tripDate: trip.date,
          note: Value(trip.note),
          createdAtMicros: trip.createdAt.microsecondsSinceEpoch,
          updatedAtMicros: Value(DateTime.now().toUtc().microsecondsSinceEpoch),
        ),
      );

  /// Tombstones the trip and every ascent logged under it, so the whole
  /// zápis disappears on other devices too.
  @override
  Future<void> deleteTrip(String id) async {
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(_db.trips)..where((t) => t.id.equals(id))).write(
        TripsCompanion(
          deletedAtMicros: Value(now),
          updatedAtMicros: Value(now),
        ),
      );
      await (_db.update(_db.ascents)..where((t) => t.tripId.equals(id))).write(
        AscentsCompanion(
          deletedAtMicros: Value(now),
          updatedAtMicros: Value(now),
        ),
      );
    });
  }
}
