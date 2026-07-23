import 'dart:math' as math;

import '../../../core/utilities/map_tile_cache.dart';
import '../domain/climbing_area.dart';
import '../domain/geo_point.dart';

/// Zoom levels worth having under the crag: overview down to wall level.
const offlineZoomLevels = [12, 13, 14, 15, 16];

/// Padding around the area's points, in degrees (~2 km of latitude).
const _paddingDegrees = 0.02;

/// Slippy-map tile coordinates for [point] at [zoom].
({int x, int y}) tileForPoint(GeoPoint point, int zoom) {
  final n = 1 << zoom;
  final x = ((point.longitude + 180) / 360 * n).floor().clamp(0, n - 1);
  final latRad = point.latitude * math.pi / 180;
  final y =
      ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
              2 *
              n)
          .floor()
          .clamp(0, n - 1);
  return (x: x, y: y);
}

/// Every tile URL needed to browse [area] offline: the bounding box of
/// the crag and its parking spots (padded) across [offlineZoomLevels],
/// instantiated from [urlTemplate] (`{z}`, `{x}`, `{y}`).
List<String> tileUrlsForArea(ClimbingArea area, String urlTemplate) {
  final points = [area.location, for (final p in area.parking) p.location];
  final minLat =
      points.map((p) => p.latitude).reduce(math.min) - _paddingDegrees;
  final maxLat =
      points.map((p) => p.latitude).reduce(math.max) + _paddingDegrees;
  final minLng =
      points.map((p) => p.longitude).reduce(math.min) - _paddingDegrees;
  final maxLng =
      points.map((p) => p.longitude).reduce(math.max) + _paddingDegrees;

  final urls = <String>[];
  for (final zoom in offlineZoomLevels) {
    final topLeft = tileForPoint(
      GeoPoint(latitude: maxLat, longitude: minLng),
      zoom,
    );
    final bottomRight = tileForPoint(
      GeoPoint(latitude: minLat, longitude: maxLng),
      zoom,
    );
    for (var x = topLeft.x; x <= bottomRight.x; x++) {
      for (var y = topLeft.y; y <= bottomRight.y; y++) {
        urls.add(
          urlTemplate
              .replaceAll('{z}', '$zoom')
              .replaceAll('{x}', '$x')
              .replaceAll('{y}', '$y'),
        );
      }
    }
  }
  return urls;
}

/// Prefetches map tiles and sector topo photos of an area into the disk
/// cache. Catalog data is always offline already, so this makes the whole
/// area usable without a connection.
class AreaDownloadService {
  AreaDownloadService(this._cache);

  static const _concurrency = 4;

  final MapTileCache _cache;

  /// Returns the number of URLs that failed to download. [onProgress]
  /// reports completed/total.
  Future<int> download({
    required List<String> urls,
    void Function(int done, int total)? onProgress,
  }) async {
    var done = 0;
    var failed = 0;
    for (var i = 0; i < urls.length; i += _concurrency) {
      final chunk = urls.skip(i).take(_concurrency);
      final results = await Future.wait([
        for (final url in chunk) _cache.ensureCached(url),
      ]);
      done += results.length;
      failed += results.where((ok) => !ok).length;
      onProgress?.call(done, urls.length);
    }
    return failed;
  }
}
