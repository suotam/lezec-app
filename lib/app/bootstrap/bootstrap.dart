import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/crux_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/legacy_preferences_migration.dart';
import '../app.dart';

/// Initializes app-wide services and runs the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = CruxDatabase(driftDatabase(name: 'crux'));

  // Users of the SharedPreferences stage keep their favorites, projects
  // and history; no-op on fresh installs.
  final prefs = await SharedPreferences.getInstance();
  await migrateLegacyPreferences(database, prefs);

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const CruxApp(),
    ),
  );
}
