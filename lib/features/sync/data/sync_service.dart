import '../domain/sync_merge.dart';
import '../domain/sync_records.dart';
import 'drift_sync_store.dart';

/// Two-way sync of all user data. Pulls the backend state, merges with
/// last-write-wins per row (tombstones included) and pushes whatever the
/// local side has newer. Idempotent — running it twice in a row is a
/// no-op the second time (modulo server-side `updated_at` echoes).
class SyncService {
  SyncService({required this._store, required this._backend});

  final DriftSyncStore _store;
  final SyncBackend _backend;

  Future<void> sync() async {
    final ascents = mergeByKey(
      local: await _store.readAscents(),
      remote: await _backend.fetchAscents(),
      keyOf: (row) => row.id,
      updatedAtOf: (row) => row.updatedAt,
    );
    await _store.applyAscents(ascents.toApplyLocally);
    await _backend.upsertAscents(ascents.toPush);

    final flags = mergeByKey(
      local: await _store.readRouteFlags(),
      remote: await _backend.fetchRouteFlags(),
      keyOf: (row) => row.routeId,
      updatedAtOf: (row) => row.updatedAt,
    );
    await _store.applyRouteFlags(flags.toApplyLocally);
    await _backend.upsertRouteFlags(flags.toPush);

    final views = mergeByKey(
      local: await _store.readAreaViews(),
      remote: await _backend.fetchAreaViews(),
      keyOf: (row) => row.areaId,
      updatedAtOf: (row) => row.viewedAt,
    );
    await _store.applyAreaViews(views.toApplyLocally);
    await _backend.upsertAreaViews(views.toPush);
  }
}
