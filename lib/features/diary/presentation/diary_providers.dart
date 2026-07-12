import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/utilities/unique_id.dart';
import '../../climbing_routes/domain/route_context.dart';
import '../data/drift_diary_repository.dart';
import '../domain/ascent.dart';
import '../domain/diary_repository.dart';

final diaryRepositoryProvider = Provider<DiaryRepository>(
  (ref) => DriftDiaryRepository(ref.watch(databaseProvider)),
);

/// The whole diary, newest first. Every mutation writes through the
/// repository and re-reads, so nothing lives only in memory.
class DiaryNotifier extends AsyncNotifier<List<Ascent>> {
  DiaryRepository get _repository => ref.read(diaryRepositoryProvider);

  @override
  Future<List<Ascent>> build() =>
      ref.watch(diaryRepositoryProvider).getAscents();

  Future<void> logAscent({
    required RouteContext routeContext,
    required AscentStyle style,
    required DateTime date,
    String? note,
  }) async {
    final route = routeContext.route;
    final rock = routeContext.rock;
    final trimmedNote = note?.trim();
    await _repository.addAscent(
      Ascent(
        id: newUniqueId(),
        routeId: route.id,
        routeName: route.name,
        grade: route.grade,
        areaId: routeContext.area.id,
        areaName: routeContext.area.name,
        sectorName: rock == null
            ? routeContext.sector.name
            : '${routeContext.sector.name} · ${rock.name}',
        style: style,
        date: DateUtils.dateOnly(date),
        createdAt: DateTime.now(),
        note: (trimmedNote == null || trimmedNote.isEmpty)
            ? null
            : trimmedNote,
      ),
    );
    state = AsyncData(await _repository.getAscents());
  }

  Future<void> deleteAscent(String id) async {
    await _repository.deleteAscent(id);
    state = AsyncData(await _repository.getAscents());
  }
}

final diaryProvider = AsyncNotifierProvider<DiaryNotifier, List<Ascent>>(
  DiaryNotifier.new,
);

/// The user's ascents of one route, newest first. Empty while the diary is
/// still loading.
final routeAscentsProvider = Provider.family<List<Ascent>, String>((
  ref,
  routeId,
) {
  final ascents = ref.watch(diaryProvider).value ?? const <Ascent>[];
  return [
    for (final ascent in ascents)
      if (ascent.routeId == routeId) ascent,
  ];
});
