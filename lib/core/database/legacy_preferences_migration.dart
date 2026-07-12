import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crux_database.dart';

/// One-time import of user data written by the SharedPreferences stage
/// (favorites, projects, recently viewed areas) into the Drift database.
///
/// The legacy keys are removed after a successful import, so this is a
/// no-op on every later launch and on fresh installs.
Future<void> migrateLegacyPreferences(
  CruxDatabase db,
  SharedPreferences prefs,
) async {
  const favoritesKey = 'favorite_route_ids';
  const projectsKey = 'project_route_ids';
  const recentKey = 'recently_viewed_area_ids';

  final favorites = prefs.getStringList(favoritesKey);
  final projects = prefs.getStringList(projectsKey);
  final recent = prefs.getStringList(recentKey);
  if (favorites == null && projects == null && recent == null) return;

  await db.transaction(() async {
    final flags = <String, ({bool favorite, bool project})>{};
    for (final id in favorites ?? const <String>[]) {
      flags[id] = (favorite: true, project: false);
    }
    for (final id in projects ?? const <String>[]) {
      final existing = flags[id];
      flags[id] = (favorite: existing?.favorite ?? false, project: true);
    }
    for (final entry in flags.entries) {
      await db
          .into(db.userRouteFlags)
          .insertOnConflictUpdate(
            UserRouteFlagsCompanion.insert(
              routeId: entry.key,
              isFavorite: Value(entry.value.favorite),
              isProject: Value(entry.value.project),
            ),
          );
    }

    // The legacy list is newest first; keep that order by assigning
    // descending timestamps.
    final now = DateTime.now().microsecondsSinceEpoch;
    for (final (index, areaId) in (recent ?? const <String>[]).indexed) {
      await db
          .into(db.recentAreaViews)
          .insertOnConflictUpdate(
            RecentAreaViewsCompanion.insert(
              areaId: areaId,
              viewedAtMicros: now - index,
            ),
          );
    }
  });

  await prefs.remove(favoritesKey);
  await prefs.remove(projectsKey);
  await prefs.remove(recentKey);
}
