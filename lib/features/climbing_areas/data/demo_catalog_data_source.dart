import 'package:flutter/services.dart';

import 'demo_catalog_parser.dart';

/// Loads and caches the bundled demo catalog.
///
/// The [AssetBundle] is injectable so tests can feed fixture documents
/// without touching the real asset pipeline.
class DemoCatalogDataSource {
  DemoCatalogDataSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/demo_data/climbing_catalog.json';

  final AssetBundle _bundle;
  Future<DemoCatalog>? _catalog;

  Future<DemoCatalog> load() => _catalog ??= _loadAndParse();

  /// The raw catalog document as shipped in the asset bundle. Used by the
  /// local catalog store, which slices it into per-area documents.
  Future<String> loadRawJson() => _bundle.loadString(assetPath);

  Future<DemoCatalog> _loadAndParse() async {
    try {
      final raw = await _bundle.loadString(assetPath);
      return parseDemoCatalog(raw);
    } catch (_) {
      // Drop the cached future so a retry re-reads the asset instead of
      // replaying the failure forever.
      _catalog = null;
      rethrow;
    }
  }
}
