import 'dart:convert';

import '../../../core/database/crux_database.dart';
import '../domain/climbing_area.dart';
import '../domain/climbing_area_repository.dart';
import '../domain/climbing_region.dart';
import 'demo_catalog_parser.dart';
import 'drift_catalog_store.dart';

/// [ClimbingAreaRepository] backed by the local catalog store. Every read
/// first makes sure the bundled catalog has been imported.
class DriftClimbingAreaRepository implements ClimbingAreaRepository {
  DriftClimbingAreaRepository(this._db, this._store);

  final CruxDatabase _db;
  final DriftCatalogStore _store;

  @override
  Future<List<ClimbingRegion>> getRegions() async {
    await _store.ensureSeeded();
    return [
      for (final row in await _db.select(_db.catalogRegions).get())
        ClimbingRegion(id: row.id, name: row.name, country: row.country),
    ];
  }

  @override
  Future<List<ClimbingArea>> getAreas() async {
    await _store.ensureSeeded();
    final regionNames = await _regionNamesById();
    final rows = await _db.select(_db.catalogAreas).get();
    return [for (final row in rows) _parseRow(row, regionNames)];
  }

  @override
  Future<ClimbingArea?> getAreaById(String id) async {
    await _store.ensureSeeded();
    final row = await (_db.select(
      _db.catalogAreas,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _parseRow(row, await _regionNamesById());
  }

  Future<Map<String, String>> _regionNamesById() async {
    final rows = await _db.select(_db.catalogRegions).get();
    return {for (final row in rows) row.id: row.name};
  }

  ClimbingArea _parseRow(CatalogArea row, Map<String, String> regionNames) =>
      parseCatalogArea(
        json.decode(row.document),
        'areas[${row.id}]',
        regionNames,
      );
}
