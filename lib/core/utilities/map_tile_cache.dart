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
}

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
    return _DiskCachedTileImage(
      url: url,
      file: File('${cache.directory.path}/${_fnv1a(url)}.tile'),
      headers: headers,
    );
  }

  /// Stable 64-bit FNV-1a hash — file names must survive app restarts,
  /// so [String.hashCode] (not guaranteed stable) is not an option.
  static String _fnv1a(String input) {
    var hash = 0xcbf29ce484222325;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}

@immutable
class _DiskCachedTileImage extends ImageProvider<_DiskCachedTileImage> {
  const _DiskCachedTileImage({
    required this.url,
    required this.file,
    required this.headers,
  });

  final String url;
  final File file;
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
    final bytes = await _loadBytes();
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  Future<Uint8List> _loadBytes() async {
    if (await file.exists()) {
      return file.readAsBytes();
    }
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
      final bytes = builder.takeBytes();
      // Best effort: a failed write must not break rendering the tile.
      try {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes, flush: true);
      } on FileSystemException {
        // Cache directory unavailable; serve the tile from memory.
      }
      return bytes;
    } finally {
      client.close();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is _DiskCachedTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
