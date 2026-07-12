import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../features/climbing_areas/domain/geo_point.dart';

typedef UrlLauncher = Future<bool> Function(Uri uri);

/// Opens the given coordinates in an external map application.
///
/// Tries a platform-native URI first (geo: on Android, Apple Maps on iOS)
/// and falls back to a universal Google Maps URL. Returns `false` when no
/// handler could be launched so the UI can inform the user.
class ExternalNavigationService {
  ExternalNavigationService({UrlLauncher? launcher})
    : _launcher = launcher ?? _launchExternal;

  final UrlLauncher _launcher;

  static Future<bool> _launchExternal(Uri uri) => url_launcher.launchUrl(
    uri,
    mode: url_launcher.LaunchMode.externalApplication,
  );

  Future<bool> navigateTo(GeoPoint point, {String? label}) async {
    final query = '${point.latitude},${point.longitude}';
    final candidates = <Uri>[
      if (defaultTargetPlatform == TargetPlatform.android)
        Uri.parse(
          'geo:$query?q=$query${label != null ? '(${Uri.encodeComponent(label)})' : ''}',
        ),
      if (defaultTargetPlatform == TargetPlatform.iOS)
        Uri.https('maps.apple.com', '/', {'ll': query, 'q': ?label}),
      Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': query,
      }),
    ];

    for (final uri in candidates) {
      try {
        if (await _launcher(uri)) return true;
      } on Exception {
        // Try the next candidate; report failure only when all fail.
      }
    }
    return false;
  }
}

final externalNavigationServiceProvider = Provider<ExternalNavigationService>(
  (ref) => ExternalNavigationService(),
);
