import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/errors/demo_data_format_exception.dart';
import 'drift_catalog_store.dart';

/// What a catalog update check concluded.
enum CatalogUpdateOutcome { upToDate, updated }

typedef CatalogUpdateResult = ({CatalogUpdateOutcome outcome, int version});

typedef BytesFetcher = Future<Uint8List> Function(Uri uri);

/// Checks the public `catalog` Storage bucket for a newer catalog and
/// imports it into the local database.
///
/// Bucket layout (uploaded by the project owner after an importer run):
///
/// ```text
/// catalog/latest.json                  {"version": 5, "object": "climbing_catalog-v5.json.gz"}
/// catalog/climbing_catalog-v5.json.gz  the catalog itself (gzip or plain)
/// ```
///
/// The version comparison happens twice: here (to avoid downloading an
/// old catalog) and again inside [DriftCatalogStore.importOta] (so a
/// mis-published older file can never overwrite newer local data).
class CatalogUpdateService {
  CatalogUpdateService({
    required this._store,
    required this._baseUri,
    BytesFetcher? fetcher,
  }) : _fetch = fetcher ?? _fetchBytes;

  final DriftCatalogStore _store;
  final Uri _baseUri;
  final BytesFetcher _fetch;

  static Future<Uint8List> _fetchBytes(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${response.statusCode} for $uri', uri: uri);
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
      }
      return builder.takeBytes();
    } finally {
      client.close();
    }
  }

  Uri _resolve(String name) => _baseUri.replace(path: '${_baseUri.path}/$name');

  Future<CatalogUpdateResult> checkAndApply() async {
    final manifest = json.decode(
      utf8.decode(await _fetch(_resolve('latest.json'))),
    );
    if (manifest is! Map<String, Object?>) {
      throw const DemoDataFormatException('latest.json must be an object');
    }
    final version = manifest['version'];
    final object = manifest['object'];
    if (version is! int || object is! String || object.isEmpty) {
      throw const DemoDataFormatException(
        'latest.json must contain "version" (int) and "object" (string)',
      );
    }

    final current = await _store.currentVersion() ?? 0;
    if (version <= current) {
      return (outcome: CatalogUpdateOutcome.upToDate, version: current);
    }

    final bytes = await _fetch(_resolve(object));
    final gzipped = bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    final raw = utf8.decode(gzipped ? gzip.decode(bytes) : bytes);
    final imported = await _store.importOta(raw);
    return imported
        ? (outcome: CatalogUpdateOutcome.updated, version: version)
        : (outcome: CatalogUpdateOutcome.upToDate, version: current);
  }
}
