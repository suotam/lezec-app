import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utilities/unique_id.dart';
import '../domain/sector_photos_repository.dart';

class SupabaseSectorPhotosRepository implements SectorPhotosRepository {
  SupabaseSectorPhotosRepository(this._client);

  static const _bucket = 'topos';

  final SupabaseClient _client;

  @override
  Future<List<SectorPhoto>> forSector(String sectorId) async {
    final rows = await _client
        .from('sector_photos')
        .select()
        .eq('sector_id', sectorId)
        .order('created_at');
    return [
      for (final row in rows)
        (
          id: row['id'] as String,
          storagePath: row['storage_path'] as String,
          publicUrl: _client.storage
              .from(_bucket)
              .getPublicUrl(row['storage_path'] as String),
        ),
    ];
  }

  @override
  Future<void> upload({
    required String areaId,
    required String sectorId,
    required Uint8List bytes,
  }) async {
    final path = '$areaId/$sectorId/${newUniqueId()}.jpg';
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    await _client.from('sector_photos').insert({
      'area_id': areaId,
      'sector_id': sectorId,
      'storage_path': path,
    });
  }

  @override
  Future<void> remove(SectorPhoto photo) async {
    await _client.storage.from(_bucket).remove([photo.storagePath]);
    await _client.from('sector_photos').delete().eq('id', photo.id);
  }
}
