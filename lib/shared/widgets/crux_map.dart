import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mapy.com (Seznam) REST API key, passed at build time:
///
/// ```bash
/// flutter run --dart-define=MAPY_API_KEY=<key>
/// ```
///
/// With a key the app uses the Mapy.com "outdoor" tile set (Czech tourist
/// map with hiking trails — ideal for crag approaches); without one it
/// falls back to standard OpenStreetMap tiles. Keys are free at
/// https://developer.mapy.com.
const _mapyApiKey = String.fromEnvironment('MAPY_API_KEY');

/// A map tile style: URL template plus the legally required attribution.
@immutable
class MapTileSource {
  const MapTileSource({required this.urlTemplate, required this.attribution});

  final String urlTemplate;
  final String attribution;
}

/// The tile style used by every map in the app.
final mapTileSourceProvider = Provider<MapTileSource>((ref) {
  if (_mapyApiKey.isNotEmpty) {
    return const MapTileSource(
      urlTemplate:
          'https://api.mapy.com/v1/maptiles/outdoor/256/{z}/{x}/{y}?apikey=$_mapyApiKey',
      attribution: '© Seznam.cz, a.s. a další | © OpenStreetMap',
    );
  }
  return const MapTileSource(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap',
  );
});

/// Builds the tile provider used by every map in the app. Tests override
/// this with an offline provider so widget tests never touch the network.
final mapTileProviderFactoryProvider = Provider<TileProvider Function()>(
  (ref) => NetworkTileProvider.new,
);

/// Shared map widget with the app-wide tile source and mandatory
/// attribution. Callers supply [options] (camera) and layers via
/// [markers]; everything else is configured here so all maps in the app
/// look and behave the same.
class CruxMap extends ConsumerWidget {
  const CruxMap({
    super.key,
    required this.options,
    this.markers = const [],
    this.controller,
  });

  final MapOptions options;
  final List<Marker> markers;
  final MapController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(mapTileSourceProvider);
    return FlutterMap(
      mapController: controller,
      options: options,
      children: [
        TileLayer(
          urlTemplate: source.urlTemplate,
          userAgentPackageName: 'cz.cruxcz.app',
          tileProvider: ref.watch(mapTileProviderFactoryProvider)(),
        ),
        MarkerLayer(markers: markers),
        SimpleAttributionWidget(
          // Proper-noun attribution required by the tile providers' terms;
          // not a translatable UI string.
          source: Text(source.attribution),
        ),
      ],
    );
  }
}
