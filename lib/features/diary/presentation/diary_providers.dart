import 'dart:typed_data';

import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utilities/unique_id.dart';
import '../../climbing_areas/domain/climbing_area.dart';
import '../../climbing_routes/domain/climbing_route.dart';
import '../../climbing_routes/domain/route_context.dart';
import '../../sync/presentation/sync_providers.dart';
import '../data/drift_diary_repository.dart';
import '../data/gallery_photo_source.dart';
import '../data/supabase_trip_photos_repository.dart';
import '../domain/ascent.dart';
import '../domain/diary_repository.dart';
import '../domain/diary_stats.dart';
import '../domain/trip.dart';
import '../domain/trip_photos_repository.dart';

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
        note: (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
      ),
    );
    await _refreshAndSync();
  }

  Future<void> updateAscent(Ascent ascent) async {
    await _repository.updateAscent(ascent);
    await _refreshAndSync();
  }

  Future<void> deleteAscent(String id) async {
    await _repository.deleteAscent(id);
    await _refreshAndSync();
  }

  Future<void> _refreshAndSync() async {
    state = AsyncData(await _repository.getAscents());
    // No-op when signed out; debounced round-trip when signed in.
    ref.read(syncControllerProvider.notifier).requestSync();
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

/// IDs of every route with at least one logged ascent, for the "climbed"
/// mark in route lists.
final climbedRouteIdsProvider = Provider<Set<String>>((ref) {
  final ascents = ref.watch(diaryProvider).value ?? const <Ascent>[];
  return {for (final ascent in ascents) ascent.routeId};
});

/// Active diary list filter; widgets mutate it only through these methods.
class DiaryFilterController extends Notifier<DiaryFilter> {
  @override
  DiaryFilter build() => const DiaryFilter();

  void toggleStyle(AscentStyle style) => state = state.toggledStyle(style);

  void toggleYear(int year) => state = state.toggledYear(year);

  void setArea(String? areaId) => state = state.withArea(areaId);

  void clear() => state = const DiaryFilter();
}

final diaryFilterProvider =
    NotifierProvider<DiaryFilterController, DiaryFilter>(
      DiaryFilterController.new,
    );

/// Ascents matching the current filter, still an [AsyncValue] so the
/// screen keeps the diary's load/error states.
final filteredAscentsProvider = Provider<AsyncValue<List<Ascent>>>((ref) {
  final filter = ref.watch(diaryFilterProvider);
  return ref
      .watch(diaryProvider)
      .whenData((ascents) => filterAscents(ascents, filter));
});

/// Stats over the whole (unfiltered) diary; null while loading.
final diaryStatsProvider = Provider<DiaryStats?>((ref) {
  final ascents = ref.watch(diaryProvider).value;
  if (ascents == null) return null;
  return DiaryStats.from(ascents, now: DateTime.now());
});

// --- trips -----------------------------------------------------------

/// One route ticked in the bulk trip log.
typedef TripRouteSelection = ({ClimbingRoute route, String sectorName});

final tripPhotosRepositoryProvider = Provider<TripPhotosRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseTripPhotosRepository(client);
});

/// Opens the system gallery; overridden in tests with a fake.
final photoPickerProvider = Provider<Future<List<Uint8List>> Function()>(
  (ref) => pickPhotosFromGallery,
);

/// Photos of one trip; null without a backend.
final tripPhotosProvider = FutureProvider.family<List<TripPhoto>?, String>((
  ref,
  tripId,
) async {
  final repository = ref.watch(tripPhotosRepositoryProvider);
  if (repository == null) return null;
  return repository.forTrip(tripId);
});

/// Downloaded photo bytes, cached per storage path for the session.
final tripPhotoBytesProvider = FutureProvider.family<Uint8List, String>((
  ref,
  storagePath,
) {
  final repository = ref.watch(tripPhotosRepositoryProvider);
  if (repository == null) throw StateError('no backend');
  return repository.download(storagePath);
});

/// Trip logs, newest first, with the bulk-logging operation.
class TripsNotifier extends AsyncNotifier<List<Trip>> {
  DiaryRepository get _repository => ref.read(diaryRepositoryProvider);

  @override
  Future<List<Trip>> build() => ref.watch(diaryRepositoryProvider).getTrips();

  /// Creates the trip plus one ordinary ascent per selected route (all
  /// sharing style/date/note left empty) and uploads [photos] best
  /// effort. Returns the number of photos that failed to upload.
  Future<int> logTrip({
    required ClimbingArea area,
    required DateTime date,
    required AscentStyle style,
    required List<TripRouteSelection> routes,
    String? note,
    List<Uint8List> photos = const [],
  }) async {
    final trimmedNote = note?.trim();
    final trip = Trip(
      id: newUniqueId(),
      areaId: area.id,
      areaName: area.name,
      date: DateUtils.dateOnly(date),
      createdAt: DateTime.now(),
      note: (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
    );
    await _repository.addTrip(trip);
    for (final selection in routes) {
      await _repository.addAscent(
        Ascent(
          id: newUniqueId(),
          tripId: trip.id,
          routeId: selection.route.id,
          routeName: selection.route.name,
          grade: selection.route.grade,
          areaId: area.id,
          areaName: area.name,
          sectorName: selection.sectorName,
          style: style,
          date: trip.date,
          createdAt: DateTime.now(),
        ),
      );
    }

    var failedPhotos = 0;
    final photosRepository = ref.read(tripPhotosRepositoryProvider);
    if (photosRepository != null) {
      for (final bytes in photos) {
        try {
          await photosRepository.upload(tripId: trip.id, bytes: bytes);
        } catch (_) {
          failedPhotos++;
        }
      }
    }

    ref.invalidateSelf();
    ref.invalidate(diaryProvider);
    ref.read(syncControllerProvider.notifier).requestSync();
    return failedPhotos;
  }

  /// Deletes the trip together with its ascents.
  Future<void> deleteTrip(String id) async {
    await _repository.deleteTrip(id);
    ref.invalidateSelf();
    ref.invalidate(diaryProvider);
    ref.read(syncControllerProvider.notifier).requestSync();
  }
}

final tripsProvider = AsyncNotifierProvider<TripsNotifier, List<Trip>>(
  TripsNotifier.new,
);
