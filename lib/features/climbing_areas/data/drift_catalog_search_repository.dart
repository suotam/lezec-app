import 'package:drift/drift.dart';

import '../../../core/database/crux_database.dart';
import '../../../core/utilities/text_normalization.dart';
import '../../climbing_routes/domain/route_grade.dart';
import '../domain/catalog_search.dart';
import 'drift_catalog_store.dart';

/// [CatalogSearchRepository] over the search-index table written during
/// catalog import. Matching is a SQL LIKE per query word, so the full
/// route list never leaves the database.
class DriftCatalogSearchRepository implements CatalogSearchRepository {
  DriftCatalogSearchRepository(this._db, this._store);

  final CruxDatabase _db;
  final DriftCatalogStore _store;

  @override
  Future<CatalogSearchResults> search(
    String query, {
    int limitPerType = 20,
  }) async {
    final words = normalizedSearchWords(query);
    if (words.isEmpty) return CatalogSearchResults.empty;
    await _store.ensureSeeded();

    Future<List<CatalogSearchResult>> forType(CatalogSearchResultType type) {
      final select = _db.select(_db.catalogSearchEntries)
        ..where((t) {
          var predicate = t.entityType.equals(type.name);
          for (final word in words) {
            predicate = predicate & t.normalizedName.like('%$word%');
          }
          return predicate;
        })
        // Prefix matches on the first word are almost always what the user
        // is after; within each half sort alphabetically.
        ..orderBy([
          (t) => OrderingTerm(
            expression: t.normalizedName.like('${words.first}%'),
            mode: OrderingMode.desc,
          ),
          (t) => OrderingTerm(expression: t.normalizedName),
        ])
        ..limit(limitPerType);
      return select.get().then(
        (rows) => [for (final row in rows) _toResult(type, row)],
      );
    }

    final (sectors, rocks, routes) = await (
      forType(CatalogSearchResultType.sector),
      forType(CatalogSearchResultType.rock),
      forType(CatalogSearchResultType.route),
    ).wait;
    return CatalogSearchResults(sectors: sectors, rocks: rocks, routes: routes);
  }

  CatalogSearchResult _toResult(
    CatalogSearchResultType type,
    CatalogSearchEntry row,
  ) {
    RouteGrade? grade;
    if (row.gradeValue != null && row.gradeSystem != null) {
      for (final system in GradingSystem.values) {
        if (system.name == row.gradeSystem) {
          grade = RouteGrade(system: system, value: row.gradeValue!);
          break;
        }
      }
    }
    return CatalogSearchResult(
      type: type,
      id: row.entityId,
      name: row.name,
      areaId: row.areaId,
      areaName: row.areaName,
      sectorId: row.sectorId,
      sectorName: row.sectorName,
      grade: grade,
    );
  }
}
