import 'dart:convert';

import '../../../core/database/crux_database.dart';
import '../../../core/errors/demo_data_format_exception.dart';
import 'demo_catalog_data_source.dart';
import 'demo_catalog_parser.dart';

/// Imports the bundled catalog into the local database and keeps it there.
///
/// The catalog is stored as one JSON document per area plus a summary
/// document (area without its sector tree, with precomputed counts), a
/// route-id index and metadata. Areas are parsed and written one at a
/// time so the whole domain model is never materialized at once — with a
/// full-country catalog that would be hundreds of MB.
///
/// Reseed triggers, cheapest first: if the asset's byte length matches
/// the imported one, nothing is decoded at all; otherwise the document's
/// `version` decides whether to reimport.
class DriftCatalogStore {
  DriftCatalogStore(this._db, this._dataSource);

  static const _versionKey = 'catalogVersion';
  static const _importedAtKey = 'catalogImportedAt';
  static const _fingerprintKey = 'catalogAssetFingerprint';

  /// How many area rows go into one batch insert.
  static const _batchSize = 200;

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
    final bytes = await _dataSource.loadRawBytes();
    final fingerprint = '${bytes.length}';
    if (await _readMeta(_fingerprintKey) == fingerprint &&
        await _readMeta(_versionKey) != null) {
      return;
    }

    final raw = _dataSource.decodeRawBytes(bytes);
    final Object? decoded;
    try {
      decoded = json.decode(raw);
    } on FormatException catch (e) {
      throw DemoDataFormatException('Document is not valid JSON: ${e.message}');
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

    if (await _readMeta(_versionKey) == '$version') {
      // Asset bytes changed but the content version did not (e.g. a
      // re-encoded file): keep the imported data, just remember the new
      // fingerprint for the fast path.
      await _writeMeta(_fingerprintKey, fingerprint);
      return;
    }

    final regionDocs = decoded['regions'];
    final areaDocs = decoded['areas'];
    if (regionDocs is! List || areaDocs is! List) {
      throw const DemoDataFormatException(
        'root.regions and root.areas must be lists',
      );
    }

    final regionRows = <CatalogRegionsCompanion>[];
    final regionNamesById = <String, String>{};
    for (final (i, entry) in regionDocs.indexed) {
      final region = parseCatalogRegion(entry, 'regions[$i]');
      regionNamesById[region.id] = region.name;
      regionRows.add(
        CatalogRegionsCompanion.insert(
          id: region.id,
          name: region.name,
          country: region.country,
        ),
      );
    }

    await _db.transaction(() async {
      await _db.delete(_db.catalogRouteIndex).go();
      await _db.delete(_db.catalogAreas).go();
      await _db.delete(_db.catalogRegions).go();

      await _db.batch((batch) {
        batch.insertAll(_db.catalogRegions, regionRows);
      });

      // One area at a time: validate, derive the summary document, write.
      final routeIds = <String>{};
      var areaRows = <CatalogAreasCompanion>[];
      var indexRows = <CatalogRouteIndexCompanion>[];
      Future<void> flushRows() async {
        final areas = areaRows;
        final index = indexRows;
        areaRows = [];
        indexRows = [];
        await _db.batch((batch) {
          batch
            ..insertAll(_db.catalogAreas, areas)
            ..insertAll(_db.catalogRouteIndex, index);
        });
      }

      for (final (i, entry) in areaDocs.indexed) {
        final context = 'areas[$i]';
        final area = parseCatalogArea(entry, context, regionNamesById);
        final routes = area.allRoutes;
        for (final route in routes) {
          if (!routeIds.add(route.id)) {
            throw DemoDataFormatException('Duplicate route id "${route.id}"');
          }
          indexRows.add(
            CatalogRouteIndexCompanion.insert(
              routeId: route.id,
              areaId: area.id,
            ),
          );
        }

        final areaMap = entry as Map<String, Object?>;
        final summaryMap = Map<String, Object?>.from(areaMap)
          ..remove('sectors')
          ..['sectorCount'] = area.sectors.length
          ..['routeCount'] = routes.length;

        areaRows.add(
          CatalogAreasCompanion.insert(
            id: area.id,
            regionId: area.regionId,
            document: json.encode(areaMap),
            summaryDocument: json.encode(summaryMap),
          ),
        );
        if (areaRows.length >= _batchSize) await flushRows();
      }
      await flushRows();

      await _writeMeta(_versionKey, '$version');
      await _writeMeta(_importedAtKey, DateTime.now().toIso8601String());
      await _writeMeta(_fingerprintKey, fingerprint);
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
