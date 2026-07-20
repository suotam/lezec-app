import 'package:drift/drift.dart';

import '../../../core/database/crux_database.dart';
import '../domain/sync_records.dart';

/// Local side of the sync: reads and writes the user-data tables as
/// [SyncBackend]-shaped records, including tombstones (rows the normal
/// repositories filter out).
class DriftSyncStore {
  DriftSyncStore(this._db);

  final CruxDatabase _db;

  DateTime _fromMicros(int micros) =>
      DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);

  // --- ascents -------------------------------------------------------

  Future<List<AscentRecord>> readAscents() async {
    final rows = await _db.select(_db.ascents).get();
    return [
      for (final row in rows)
        (
          id: row.id,
          tripId: row.tripId,
          routeId: row.routeId,
          routeName: row.routeName,
          gradeValue: row.gradeValue,
          gradeSystem: row.gradeSystem,
          areaId: row.areaId,
          areaName: row.areaName,
          sectorName: row.sectorName,
          style: row.style,
          climbedOn: row.climbedOn,
          note: row.note,
          createdAt: _fromMicros(row.createdAtMicros),
          updatedAt: _fromMicros(row.updatedAtMicros),
          deletedAt: row.deletedAtMicros == null
              ? null
              : _fromMicros(row.deletedAtMicros!),
        ),
    ];
  }

  Future<void> applyAscents(List<AscentRecord> records) async {
    if (records.isEmpty) return;
    await _db.batch((batch) {
      for (final record in records) {
        batch.insert(
          _db.ascents,
          AscentsCompanion.insert(
            id: record.id,
            tripId: Value(record.tripId),
            routeId: record.routeId,
            routeName: record.routeName,
            gradeValue: record.gradeValue,
            gradeSystem: record.gradeSystem,
            areaId: record.areaId,
            areaName: record.areaName,
            sectorName: record.sectorName,
            style: record.style,
            climbedOn: record.climbedOn,
            note: Value(record.note),
            createdAtMicros: record.createdAt.microsecondsSinceEpoch,
            updatedAtMicros: Value(record.updatedAt.microsecondsSinceEpoch),
            deletedAtMicros: Value(record.deletedAt?.microsecondsSinceEpoch),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // --- trips ---------------------------------------------------------

  Future<List<TripRecord>> readTrips() async {
    final rows = await _db.select(_db.trips).get();
    return [
      for (final row in rows)
        (
          id: row.id,
          areaId: row.areaId,
          areaName: row.areaName,
          tripDate: row.tripDate,
          note: row.note,
          createdAt: _fromMicros(row.createdAtMicros),
          updatedAt: _fromMicros(row.updatedAtMicros),
          deletedAt: row.deletedAtMicros == null
              ? null
              : _fromMicros(row.deletedAtMicros!),
        ),
    ];
  }

  Future<void> applyTrips(List<TripRecord> records) async {
    if (records.isEmpty) return;
    await _db.batch((batch) {
      for (final record in records) {
        batch.insert(
          _db.trips,
          TripsCompanion.insert(
            id: record.id,
            areaId: record.areaId,
            areaName: record.areaName,
            tripDate: record.tripDate,
            note: Value(record.note),
            createdAtMicros: record.createdAt.microsecondsSinceEpoch,
            updatedAtMicros: Value(record.updatedAt.microsecondsSinceEpoch),
            deletedAtMicros: Value(record.deletedAt?.microsecondsSinceEpoch),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // --- favorites / projects -----------------------------------------

  Future<List<RouteFlagRecord>> readRouteFlags() async {
    final rows = await _db.select(_db.userRouteFlags).get();
    return [
      for (final row in rows)
        (
          routeId: row.routeId,
          isFavorite: row.isFavorite,
          isProject: row.isProject,
          updatedAt: _fromMicros(row.updatedAtMicros),
        ),
    ];
  }

  Future<void> applyRouteFlags(List<RouteFlagRecord> records) async {
    if (records.isEmpty) return;
    await _db.batch((batch) {
      for (final record in records) {
        batch.insert(
          _db.userRouteFlags,
          UserRouteFlagsCompanion.insert(
            routeId: record.routeId,
            isFavorite: Value(record.isFavorite),
            isProject: Value(record.isProject),
            updatedAtMicros: Value(record.updatedAt.microsecondsSinceEpoch),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // --- recently viewed areas ----------------------------------------

  Future<List<AreaViewRecord>> readAreaViews() async {
    final rows = await _db.select(_db.recentAreaViews).get();
    return [
      for (final row in rows)
        (areaId: row.areaId, viewedAt: _fromMicros(row.viewedAtMicros)),
    ];
  }

  Future<void> applyAreaViews(List<AreaViewRecord> records) async {
    if (records.isEmpty) return;
    await _db.batch((batch) {
      for (final record in records) {
        batch.insert(
          _db.recentAreaViews,
          RecentAreaViewsCompanion.insert(
            areaId: record.areaId,
            viewedAtMicros: record.viewedAt.microsecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
