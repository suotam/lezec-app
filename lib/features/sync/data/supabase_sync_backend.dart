import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/sync_records.dart';

/// [SyncBackend] over the Supabase REST API. Row-Level Security scopes
/// every query to the signed-in user; `user_id` is filled server-side by
/// its column default.
///
/// Server `updated_at` triggers bump the timestamp on updates, so a push
/// is followed by one harmless echo on the next pull (the row re-applies
/// with identical content) — the merge converges.
class SupabaseSyncBackend implements SyncBackend {
  SupabaseSyncBackend(this._client);

  final SupabaseClient _client;

  static String _date(DateTime value) =>
      value.toIso8601String().substring(0, 10);

  @override
  Future<List<AscentRecord>> fetchAscents() async {
    final rows = await _client.from('ascents').select();
    return [
      for (final row in rows)
        (
          id: row['id'] as String,
          routeId: row['route_id'] as String,
          routeName: row['route_name'] as String,
          gradeValue: row['grade_value'] as String,
          gradeSystem: row['grade_system'] as String,
          areaId: row['area_id'] as String,
          areaName: row['area_name'] as String,
          sectorName: row['sector_name'] as String,
          style: row['style'] as String,
          climbedOn: DateTime.parse(row['climbed_on'] as String),
          note: row['note'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
          updatedAt: DateTime.parse(row['updated_at'] as String).toUtc(),
          deletedAt: row['deleted_at'] == null
              ? null
              : DateTime.parse(row['deleted_at'] as String).toUtc(),
        ),
    ];
  }

  @override
  Future<void> upsertAscents(List<AscentRecord> records) async {
    if (records.isEmpty) return;
    await _client.from('ascents').upsert([
      for (final record in records)
        {
          'id': record.id,
          'route_id': record.routeId,
          'route_name': record.routeName,
          'grade_value': record.gradeValue,
          'grade_system': record.gradeSystem,
          'area_id': record.areaId,
          'area_name': record.areaName,
          'sector_name': record.sectorName,
          'style': record.style,
          'climbed_on': _date(record.climbedOn),
          'note': record.note,
          'created_at': record.createdAt.toIso8601String(),
          'updated_at': record.updatedAt.toIso8601String(),
          'deleted_at': record.deletedAt?.toIso8601String(),
        },
    ]);
  }

  @override
  Future<List<RouteFlagRecord>> fetchRouteFlags() async {
    final rows = await _client.from('user_route_flags').select();
    return [
      for (final row in rows)
        (
          routeId: row['route_id'] as String,
          isFavorite: row['is_favorite'] as bool,
          isProject: row['is_project'] as bool,
          updatedAt: DateTime.parse(row['updated_at'] as String).toUtc(),
        ),
    ];
  }

  @override
  Future<void> upsertRouteFlags(List<RouteFlagRecord> records) async {
    if (records.isEmpty) return;
    await _client.from('user_route_flags').upsert([
      for (final record in records)
        {
          'route_id': record.routeId,
          'is_favorite': record.isFavorite,
          'is_project': record.isProject,
          'updated_at': record.updatedAt.toIso8601String(),
        },
    ]);
  }

  @override
  Future<List<AreaViewRecord>> fetchAreaViews() async {
    final rows = await _client.from('recent_area_views').select();
    return [
      for (final row in rows)
        (
          areaId: row['area_id'] as String,
          viewedAt: DateTime.parse(row['viewed_at'] as String).toUtc(),
        ),
    ];
  }

  @override
  Future<void> upsertAreaViews(List<AreaViewRecord> records) async {
    if (records.isEmpty) return;
    await _client.from('recent_area_views').upsert([
      for (final record in records)
        {
          'area_id': record.areaId,
          'viewed_at': record.viewedAt.toIso8601String(),
        },
    ]);
  }
}
