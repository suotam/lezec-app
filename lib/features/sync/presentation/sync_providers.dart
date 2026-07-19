import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../../../core/database/database_provider.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../climbing_areas/presentation/climbing_areas_providers.dart';
import '../../diary/presentation/diary_providers.dart';
import '../../projects/presentation/user_route_state_providers.dart';
import '../data/drift_sync_store.dart';
import '../data/supabase_sync_backend.dart';
import '../data/sync_service.dart';
import '../domain/sync_records.dart';

final syncBackendProvider = Provider<SyncBackend?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseSyncBackend(client);
});

final syncServiceProvider = Provider<SyncService?>((ref) {
  final backend = ref.watch(syncBackendProvider);
  if (backend == null) return null;
  return SyncService(
    store: DriftSyncStore(ref.watch(databaseProvider)),
    backend: backend,
  );
});

/// When the last successful sync of this session happened (null = none
/// yet). `syncNow` runs immediately; `requestSync` debounces — call it
/// after local mutations so edits made offline right after each other
/// coalesce into one round-trip.
class SyncController extends AsyncNotifier<DateTime?> {
  Timer? _debounce;

  @override
  Future<DateTime?> build() async {
    ref.onDispose(() => _debounce?.cancel());
    return null;
  }

  Future<void> syncNow() async {
    final service = ref.read(syncServiceProvider);
    final user = ref.read(currentUserProvider).value;
    if (service == null || user == null) return;
    _debounce?.cancel();
    state = const AsyncLoading<DateTime?>();
    try {
      await service.sync();
      state = AsyncData(DateTime.now());
      // Synced rows may have changed what the screens show.
      ref.invalidate(diaryProvider);
      ref.invalidate(userRouteStateProvider);
      ref.invalidate(recentlyViewedAreasProvider);
    } catch (error, stackTrace) {
      state = AsyncError<DateTime?>(error, stackTrace);
    }
  }

  /// Fire-and-forget sync a few seconds after a local mutation.
  void requestSync() {
    if (ref.read(currentUserProvider).value == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 4), () {
      unawaited(syncNow());
    });
  }
}

final syncControllerProvider = AsyncNotifierProvider<SyncController, DateTime?>(
  SyncController.new,
);
