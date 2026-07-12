import 'package:drift/drift.dart';

import '../../../core/database/crux_database.dart';
import '../domain/recently_viewed_areas_repository.dart';

/// Drift-backed history of opened areas, newest first, capped at
/// [_maxEntries] rows.
class DriftRecentlyViewedRepository implements RecentlyViewedAreasRepository {
  DriftRecentlyViewedRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const _maxEntries = 10;

  final CruxDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<List<String>> getRecentlyViewedAreaIds() async {
    final query = _db.select(_db.recentAreaViews)
      ..orderBy([(t) => OrderingTerm.desc(t.viewedAtMicros)])
      ..limit(_maxEntries);
    return [for (final row in await query.get()) row.areaId];
  }

  @override
  Future<void> recordAreaView(String areaId) {
    return _db.transaction(() async {
      await _db
          .into(_db.recentAreaViews)
          .insertOnConflictUpdate(
            RecentAreaViewsCompanion.insert(
              areaId: areaId,
              viewedAtMicros: _clock().microsecondsSinceEpoch,
            ),
          );
      final keep = _db.selectOnly(_db.recentAreaViews)
        ..addColumns([_db.recentAreaViews.areaId])
        ..orderBy([OrderingTerm.desc(_db.recentAreaViews.viewedAtMicros)])
        ..limit(_maxEntries);
      await (_db.delete(_db.recentAreaViews)..where(
            (t) => t.areaId.isNotInQuery(keep),
          ))
          .go();
    });
  }
}
