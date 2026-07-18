import 'package:flutter/foundation.dart';

import '../../climbing_routes/domain/route_grade.dart';

/// What kind of catalog entity a search result points at. Areas are not
/// listed here — the area list is small and searched in memory with richer
/// matching (summary and description text) by `filterAreas`.
enum CatalogSearchResultType { sector, rock, route }

/// One match from the catalog-wide name search, carrying enough context to
/// render a result tile and navigate to it without further lookups.
@immutable
class CatalogSearchResult {
  const CatalogSearchResult({
    required this.type,
    required this.id,
    required this.name,
    required this.areaId,
    required this.areaName,
    required this.sectorId,
    this.sectorName,
    this.grade,
  });

  final CatalogSearchResultType type;
  final String id;
  final String name;
  final String areaId;
  final String areaName;

  /// The sector to open for sector and rock results; the containing sector
  /// for route results. Equals [id] for sector results.
  final String sectorId;

  /// Null for sector results.
  final String? sectorName;

  /// Set for route results whose grade survived the import.
  final RouteGrade? grade;
}

/// Search matches grouped by entity type, each list capped by the query's
/// per-type limit (check `hasMore*` to show a "more results" hint).
@immutable
class CatalogSearchResults {
  const CatalogSearchResults({
    this.sectors = const [],
    this.rocks = const [],
    this.routes = const [],
  });

  static const empty = CatalogSearchResults();

  final List<CatalogSearchResult> sectors;
  final List<CatalogSearchResult> rocks;
  final List<CatalogSearchResult> routes;

  bool get isEmpty => sectors.isEmpty && rocks.isEmpty && routes.isEmpty;
}

/// Name search across every sector, rock and route in the catalog.
abstract interface class CatalogSearchRepository {
  /// Matches entities whose name contains every word of [query]
  /// (case- and diacritics-insensitive). Returns [CatalogSearchResults.empty]
  /// for a blank query. Each group holds at most [limitPerType] rows,
  /// best matches (name prefix, then alphabetical) first.
  Future<CatalogSearchResults> search(String query, {int limitPerType});
}
