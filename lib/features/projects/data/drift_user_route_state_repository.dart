import 'package:drift/drift.dart';

import '../../../core/database/crux_database.dart';
import '../domain/user_route_state_repository.dart';

/// Drift-backed favorites/projects storage. Both flags share one row per
/// route; a row with neither flag set is removed.
class DriftUserRouteStateRepository implements UserRouteStateRepository {
  DriftUserRouteStateRepository(this._db);

  final CruxDatabase _db;

  @override
  Future<Set<String>> getFavoriteRouteIds() =>
      _idsWhere((t) => t.isFavorite.equals(true));

  @override
  Future<Set<String>> getProjectRouteIds() =>
      _idsWhere((t) => t.isProject.equals(true));

  @override
  Future<void> setFavorite(String routeId, bool isFavorite) =>
      _writeFlags(routeId, favorite: isFavorite);

  @override
  Future<void> setProject(String routeId, bool isProject) =>
      _writeFlags(routeId, project: isProject);

  Future<Set<String>> _idsWhere(
    Expression<bool> Function($UserRouteFlagsTable t) predicate,
  ) async {
    final rows = await (_db.select(_db.userRouteFlags)..where(predicate)).get();
    return {for (final row in rows) row.routeId};
  }

  Future<void> _writeFlags(String routeId, {bool? favorite, bool? project}) {
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.userRouteFlags,
      )..where((t) => t.routeId.equals(routeId))).getSingleOrNull();
      final isFavorite = favorite ?? existing?.isFavorite ?? false;
      final isProject = project ?? existing?.isProject ?? false;
      if (!isFavorite && !isProject) {
        await (_db.delete(
          _db.userRouteFlags,
        )..where((t) => t.routeId.equals(routeId))).go();
      } else {
        await _db
            .into(_db.userRouteFlags)
            .insertOnConflictUpdate(
              UserRouteFlagsCompanion.insert(
                routeId: routeId,
                isFavorite: Value(isFavorite),
                isProject: Value(isProject),
              ),
            );
      }
    });
  }
}
