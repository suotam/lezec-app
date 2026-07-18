import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter/services.dart';

import 'demo_catalog_parser.dart';

/// Loads the bundled catalog asset.
///
/// The full-database catalog ships gzip-compressed
/// ([compressedAssetPath]); a plain JSON asset ([assetPath]) is supported
/// as a fallback so tests can feed fixture documents through a fake
/// bundle. Decompression is decided by the gzip magic bytes, not the
/// path, so either asset may contain either format.
class DemoCatalogDataSource {
  DemoCatalogDataSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/demo_data/climbing_catalog.json';
  static const compressedAssetPath =
      'assets/demo_data/climbing_catalog.json.gz';

  final AssetBundle _bundle;
  Future<DemoCatalog>? _catalog;

  Future<DemoCatalog> load() => _catalog ??= _loadAndParse();

  /// The catalog asset exactly as bundled. The byte length doubles as a
  /// cheap fingerprint: the catalog store skips all decoding when it
  /// matches the previously imported asset.
  Future<Uint8List> loadRawBytes() async {
    ByteData data;
    try {
      data = await _bundle.load(compressedAssetPath);
    } catch (_) {
      data = await _bundle.load(assetPath);
    }
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  /// Decodes [bytes] from [loadRawBytes] into the catalog JSON string.
  String decodeRawBytes(Uint8List bytes) {
    final gzipped = bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    return utf8.decode(gzipped ? gzip.decode(bytes) : bytes);
  }

  /// The raw catalog document as a JSON string.
  Future<String> loadRawJson() async => decodeRawBytes(await loadRawBytes());

  Future<DemoCatalog> _loadAndParse() async {
    try {
      final raw = await loadRawJson();
      return parseDemoCatalog(raw);
    } catch (_) {
      // Drop the cached future so a retry re-reads the asset instead of
      // replaying the failure forever.
      _catalog = null;
      rethrow;
    }
  }
}
