import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/backend/supabase_config.dart';
import '../../core/database/crux_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/legacy_preferences_migration.dart';
import '../../core/utilities/map_tile_cache.dart';
import '../../shared/widgets/crux_map.dart';
import '../app.dart';

/// Initializes app-wide services and runs the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = CruxDatabase(driftDatabase(name: 'crux'));

  // Users of the SharedPreferences stage keep their favorites, projects
  // and history; no-op on fresh installs.
  final prefs = await SharedPreferences.getInstance();
  await migrateLegacyPreferences(database, prefs);

  // Map tiles persist in the OS cache directory so already-viewed maps
  // keep working offline.
  final tileCache = MapTileCache(
    Directory('${(await getApplicationCacheDirectory()).path}/map_tiles'),
  );

  // Backend (accounts + sync). The app is fully functional without it.
  SupabaseClient? supabaseClient;
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
    supabaseClient = Supabase.instance.client;
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        mapTileCacheProvider.overrideWithValue(tileCache),
        mapTileProviderFactoryProvider.overrideWithValue(
          () => DiskCachingTileProvider(tileCache),
        ),
        supabaseClientProvider.overrideWithValue(supabaseClient),
      ],
      child: const CruxApp(),
    ),
  );
}
