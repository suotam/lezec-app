import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart' show TableInfo, Value, countAll;

import '../../../core/database/crux_database.dart';
import '../../../core/errors/demo_data_format_exception.dart';
import '../../../core/utilities/text_normalization.dart';
import '../../climbing_routes/domain/climbing_route.dart';
import '../../climbing_routes/domain/grade_conversion.dart';
import '../domain/catalog_search.dart';
import '../domain/climbing_area.dart';
import 'demo_catalog_data_source.dart';
import 'demo_catalog_parser.dart';

/// Summary of the imported catalog shown on the profile screen.
typedef CatalogInfo = ({
  String? version,
  DateTime? importedAt,
  int regionCount,
  int areaCount,
  int routeCount,
});

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

    final (decoded, version) = _decodeDocument(
      _dataSource.decodeRawBytes(bytes),
    );
    final stored = await currentVersion();
    if (stored != null && stored >= version) {
      // Same version re-encoded, or the database already holds a newer
      // catalog from an over-the-air update. Keep the imported data and
      // just remember the asset fingerprint for the fast path.
      await _writeMeta(_fingerprintKey, fingerprint);
      return;
    }

    await _import(decoded, version);
    await _writeMeta(_fingerprintKey, fingerprint);
  }

  /// Imports a catalog document delivered over the air. Returns false
  /// (without touching the database) when [raw] is not newer than what
  /// the database already holds.
  Future<bool> importOta(String raw) async {
    final (decoded, version) = _decodeDocument(raw);
    final stored = await currentVersion();
    if (stored != null && stored >= version) return false;
    await _import(decoded, version);
    return true;
  }

  /// The catalog version currently held by the database, if any.
  Future<int?> currentVersion() async =>
      int.tryParse(await _readMeta(_versionKey) ?? '');

  (Map<String, Object?>, int) _decodeDocument(String raw) {
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
    return (decoded, version);
  }

  Future<void> _import(Map<String, Object?> decoded, int version) async {
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
      await _db.delete(_db.catalogSearchEntries).go();
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
      var searchRows = <CatalogSearchEntriesCompanion>[];
      Future<void> flushRows() async {
        final areas = areaRows;
        final index = indexRows;
        final search = searchRows;
        areaRows = [];
        indexRows = [];
        searchRows = [];
        await _db.batch((batch) {
          batch
            ..insertAll(_db.catalogAreas, areas)
            ..insertAll(_db.catalogRouteIndex, index)
            ..insertAll(_db.catalogSearchEntries, search);
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
        searchRows.addAll(_searchRowsForArea(area));

        final areaMap = entry as Map<String, Object?>;
        final summaryMap = Map<String, Object?>.from(areaMap)
          ..remove('sectors')
          ..['sectorCount'] = area.sectors.length
          ..['routeCount'] = routes.length
          ..addAll(_gradeBandsForRoutes(routes));

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
    });
  }

  /// Precomputed route/boulder difficulty-band coverage of [routes] for
  /// the area summary, so smart search can filter by grade without the
  /// sector tree. Absent keys mean "no parseable grades in that
  /// category".
  Map<String, Object?> _gradeBandsForRoutes(List<ClimbingRoute> routes) {
    int? routeMin, routeMax, boulderMin, boulderMax;
    for (final route in routes) {
      final routeBand = routeGradeBand(route.grade);
      if (routeBand != null) {
        routeMin = routeMin == null ? routeBand : math.min(routeMin, routeBand);
        routeMax = routeMax == null ? routeBand : math.max(routeMax, routeBand);
      }
      final boulderBand = boulderGradeBand(route.grade);
      if (boulderBand != null) {
        boulderMin = boulderMin == null
            ? boulderBand
            : math.min(boulderMin, boulderBand);
        boulderMax = boulderMax == null
            ? boulderBand
            : math.max(boulderMax, boulderBand);
      }
    }
    return {
      'routeGradeMinBand': ?routeMin,
      'routeGradeMaxBand': ?routeMax,
      'boulderGradeMinBand': ?boulderMin,
      'boulderGradeMaxBand': ?boulderMax,
    };
  }

  /// One search-index row per sector, rock and route of [area]. Names are
  /// normalized here so queries can be a plain SQL LIKE.
  List<CatalogSearchEntriesCompanion> _searchRowsForArea(ClimbingArea area) {
    final rows = <CatalogSearchEntriesCompanion>[];
    CatalogSearchEntriesCompanion entry({
      required CatalogSearchResultType type,
      required String id,
      required String name,
      required String sectorId,
      String? sectorName,
      String? gradeValue,
      String? gradeSystem,
    }) {
      return CatalogSearchEntriesCompanion.insert(
        entityType: type.name,
        entityId: id,
        name: name,
        normalizedName: normalizeSearchText(name),
        areaId: area.id,
        areaName: area.name,
        sectorId: sectorId,
        sectorName: Value(sectorName),
        gradeValue: Value(gradeValue),
        gradeSystem: Value(gradeSystem),
      );
    }

    for (final sector in area.sectors) {
      rows.add(
        entry(
          type: CatalogSearchResultType.sector,
          id: sector.id,
          name: sector.name,
          sectorId: sector.id,
        ),
      );
      for (final rock in sector.rocks) {
        rows.add(
          entry(
            type: CatalogSearchResultType.rock,
            id: rock.id,
            name: rock.name,
            sectorId: sector.id,
            sectorName: sector.name,
          ),
        );
      }
      for (final route in sector.allRoutes) {
        rows.add(
          entry(
            type: CatalogSearchResultType.route,
            id: route.id,
            name: route.name,
            sectorId: sector.id,
            sectorName: sector.name,
            gradeValue: route.grade.value,
            gradeSystem: route.grade.system.name,
          ),
        );
      }
    }
    return rows;
  }

  /// Summary of the imported catalog for the profile/about screen.
  /// Nullable fields cover a corrupted meta table; the UI shows a dash.
  Future<CatalogInfo> info() async {
    await ensureSeeded();
    final importedAtRaw = await _readMeta(_importedAtKey);
    return (
      version: await _readMeta(_versionKey),
      importedAt: importedAtRaw == null
          ? null
          : DateTime.tryParse(importedAtRaw),
      regionCount: await _count(_db.catalogRegions),
      areaCount: await _count(_db.catalogAreas),
      routeCount: await _count(_db.catalogRouteIndex),
    );
  }

  Future<int> _count(TableInfo table) async {
    final count = countAll();
    final query = _db.selectOnly(table)..addColumns([count]);
    return (await query.getSingle()).read(count)!;
  }

  Future<String?> _readMeta(String key) async {
    final row = await (_db.select(
      _db.catalogMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeMeta(String key, String value) => _db
      .into(_db.catalogMeta)
      .insertOnConflictUpdate(
        CatalogMetaCompanion.insert(key: key, value: value),
      );
}
