import 'dart:convert';

import '../../../core/database/crux_database.dart';
import '../../../core/errors/demo_data_format_exception.dart';
import 'demo_catalog_data_source.dart';
import 'demo_catalog_parser.dart';

/// Imports the bundled catalog into the local database and keeps it there.
///
/// The catalog is stored as one JSON document per area plus a route-id
/// index, so browsing an area or opening a route parses only that area's
/// document instead of the whole catalog. Reseeding happens only when the
/// bundled document carries a different `version` than the imported one.
class DriftCatalogStore {
  DriftCatalogStore(this._db, this._dataSource);

  static const _versionKey = 'catalogVersion';
  static const _importedAtKey = 'catalogImportedAt';

  final CruxDatabase _db;
  final DemoCatalogDataSource _dataSource;
  Future<void>? _seeding;

  /// Guarantees the catalog tables match the bundled document. Memoized so
  /// concurrent readers trigger a single import; a failure clears the memo
  /// so a retry re-reads the asset.
  Future<void> ensureSeeded() => _seeding ??= _seedGuarded();

  Future<void> _seedGuarded() async {
    try {
      await _seed();
    } catch (_) {
      _seeding = null;
      rethrow;
    }
  }

  Future<void> _seed() async {
    final raw = await _dataSource.loadRawJson();

    final Object? decoded;
    try {
      decoded = json.decode(raw);
    } on FormatException catch (e) {
      throw DemoDataFormatException(
        'Document is not valid JSON: ${e.message}',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw const DemoDataFormatException('root must be an object');
    }
    final version = decoded['version'];
    if (version is! int || version < 1) {
      throw const DemoDataFormatException(
        'root.version must be a positive integer',
      );
    }

    final storedVersion = await _readMeta(_versionKey);
    if (storedVersion == '$version') return;

    // Full validation only when an import is actually needed.
    final catalog = parseDemoCatalog(raw);
    final areaDocuments = (decoded['areas'] as List).cast<Object?>();

    await _db.transaction(() async {
      await _db.delete(_db.catalogRouteIndex).go();
      await _db.delete(_db.catalogAreas).go();
      await _db.delete(_db.catalogRegions).go();

      for (final region in catalog.regions) {
        await _db
            .into(_db.catalogRegions)
            .insert(
              CatalogRegionsCompanion.insert(
                id: region.id,
                name: region.name,
                country: region.country,
              ),
            );
      }

      for (final (index, area) in catalog.areas.indexed) {
        await _db
            .into(_db.catalogAreas)
            .insert(
              CatalogAreasCompanion.insert(
                id: area.id,
                regionId: area.regionId,
                document: json.encode(areaDocuments[index]),
              ),
            );
        for (final route in area.allRoutes) {
          await _db
              .into(_db.catalogRouteIndex)
              .insert(
                CatalogRouteIndexCompanion.insert(
                  routeId: route.id,
                  areaId: area.id,
                ),
              );
        }
      }

      await _writeMeta(_versionKey, '$version');
      await _writeMeta(_importedAtKey, DateTime.now().toIso8601String());
    });
  }

  Future<String?> _readMeta(String key) async {
    final row = await (_db.select(
      _db.catalogMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeMeta(String key, String value) => _db
      .into(_db.catalogMeta)
      .insertOnConflictUpdate(CatalogMetaCompanion.insert(key: key, value: value));
}
