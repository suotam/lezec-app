import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the on-disk map tile cache (size inspection and clearing for
/// the profile screen). Overridden in `bootstrap()` with the real cache
/// directory.
final mapTileCacheProvider = Provider<MapTileCache>(
  (ref) => throw UnimplementedError(
    'mapTileCacheProvider must be overridden in bootstrap()',
  ),
);

class MapTileCache {
  MapTileCache(this.directory);

  final Directory directory;

  // Synchronous on purpose: the cache holds at most a few thousand small
  // files, and sync IO also completes under the fake-async test clock.
  int sizeInBytes() {
    if (!directory.existsSync()) return 0;
    var total = 0;
    for (final entry in directory.listSync()) {
      if (entry is File) total += entry.lengthSync();
    }
    return total;
  }

  void clear() {
    if (!directory.existsSync()) return;
    for (final entry in directory.listSync()) {
      entry.deleteSync(recursive: true);
    }
  }

  /// The cache file for [url] (map tile, topo photo, …).
  File fileForUrl(String url) => File('${directory.path}/${fnv1a(url)}.bin');

  /// Returns cached bytes for [url], fetching and storing them when the
  /// file does not exist yet. A failed disk write still returns the
  /// downloaded bytes.
  Future<Uint8List> readOrFetch(
    String url, {
    Map<String, String> headers = const {},
  }) async {
    final file = fileForUrl(url);
    if (await file.exists()) {
      return file.readAsBytes();
    }
    final bytes = await _download(url, headers);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
    } on FileSystemException {
      // Cache directory unavailable; serve from memory.
    }
    return bytes;
  }

  /// Prefetch variant of [readOrFetch]: skips the download when the file
  /// is already cached, returns false when the fetch failed.
  Future<bool> ensureCached(
    String url, {
    Map<String, String> headers = const {},
  }) async {
    if (fileForUrl(url).existsSync()) return true;
    try {
      await readOrFetch(url, headers: headers);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List> _download(
    String url,
    Map<String, String> headers,
  ) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      headers.forEach(request.headers.set);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${response.statusCode} for $url');
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

  /// Stable 64-bit FNV-1a hash — file names must survive app restarts,
  /// so [String.hashCode] (not guaranteed stable) is not an option.
  static String fnv1a(String input) {
    var hash = 0xcbf29ce484222325;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}

/// Bytes of a remote image, served through the disk cache so once-seen
/// photos (sector topos) keep working offline. Tests override this to
/// avoid the network.
final cachedImageBytesProvider = FutureProvider.family<Uint8List, String>(
  (ref, url) => ref.watch(mapTileCacheProvider).readOrFetch(url),
);

/// Tile provider that keeps every fetched tile on disk, so maps the user
/// has already viewed keep rendering without a connection (passive
/// offline; bulk area downloads stay a future feature). There is no
/// eviction — the OS may clear the cache directory, and the profile
/// screen offers manual clearing.
class DiskCachingTileProvider extends TileProvider {
  DiskCachingTileProvider(this.cache);

  final MapTileCache cache;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return _DiskCachedTileImage(url: url, cache: cache, headers: headers);
  }
}

@immutable
class _DiskCachedTileImage extends ImageProvider<_DiskCachedTileImage> {
  const _DiskCachedTileImage({
    required this.url,
    required this.cache,
    required this.headers,
  });

  final String url;
  final MapTileCache cache;
  final Map<String, String> headers;

  @override
  Future<_DiskCachedTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _DiskCachedTileImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadCodec(decode),
      scale: 1,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _loadCodec(ImageDecoderCallback decode) async {
    final bytes = await cache.readOrFetch(url, headers: headers);
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is _DiskCachedTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
