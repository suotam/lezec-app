import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../data/supabase_sector_photos_repository.dart';
import '../domain/sector_photos_repository.dart';

final sectorPhotosRepositoryProvider = Provider<SectorPhotosRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseSectorPhotosRepository(client);
});

/// Topo photos of a sector; null without a backend.
final sectorPhotosProvider = FutureProvider.family<List<SectorPhoto>?, String>((
  ref,
  sectorId,
) async {
  final repository = ref.watch(sectorPhotosRepositoryProvider);
  if (repository == null) return null;
  return repository.forSector(sectorId);
});
