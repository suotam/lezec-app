import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/utilities/map_tile_cache.dart';
import 'package:lezec_app/features/climbing_areas/data/area_download_service.dart';
import 'package:lezec_app/features/climbing_areas/domain/geo_point.dart';

import '../helpers/test_helpers.dart';

void main() {
  test('tileForPoint matches the slippy-map reference values', () {
    // Prague-ish coordinates; values from an independent implementation
    // of the OSM slippy-map formula.
    const point = GeoPoint(latitude: 50.0755, longitude: 14.4378);
    expect(tileForPoint(point, 10), (x: 553, y: 346));
    expect(tileForPoint(point, 16), (x: 35396, y: 22204));
  });

  test('tile URLs cover all offline zooms and substitute the template', () {
    final area = buildArea();
    final urls = tileUrlsForArea(area, 'https://tiles.test/{z}/{x}/{y}.png');

    expect(urls, isNotEmpty);
    expect(urls.every((url) => url.startsWith('https://tiles.test/')), isTrue);
    expect(urls.any((url) => url.contains('/12/')), isTrue);
    expect(urls.any((url) => url.contains('/16/')), isTrue);
    // No template placeholders left behind.
    expect(urls.any((url) => url.contains('{')), isFalse);
    // The padded box at z16 stays a sane size for one area.
    expect(urls.length, lessThan(500));
  });

  test('download reports progress and succeeds from a warm cache', () async {
    final tempDir = Directory.systemTemp.createTempSync('crux_download');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final cache = MapTileCache(tempDir);
    final urls = [
      'https://tiles.test/1.png',
      'https://tiles.test/2.png',
      'https://tiles.test/3.png',
    ];
    // Warm the cache so no network is needed.
    for (final url in urls) {
      cache.fileForUrl(url).writeAsBytesSync([1, 2, 3]);
    }

    final progress = <(int, int)>[];
    final failed = await AreaDownloadService(cache).download(
      urls: urls,
      onProgress: (done, total) => progress.add((done, total)),
    );

    expect(failed, 0);
    expect(progress.last, (3, 3));
  });
}
