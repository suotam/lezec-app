import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utilities/unique_id.dart';
import '../domain/trip_photos_repository.dart';

class SupabaseTripPhotosRepository implements TripPhotosRepository {
  SupabaseTripPhotosRepository(this._client);

  static const _bucket = 'photos';

  final SupabaseClient _client;

  @override
  Future<List<TripPhoto>> forTrip(String tripId) async {
    final rows = await _client
        .from('trip_photos')
        .select()
        .eq('trip_id', tripId)
        .order('created_at');
    return [
      for (final row in rows)
        (id: row['id'] as String, storagePath: row['storage_path'] as String),
    ];
  }

  @override
  Future<void> upload({
    required String tripId,
    required Uint8List bytes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('not signed in');
    final path = '$userId/$tripId/${newUniqueId()}.jpg';
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    await _client.from('trip_photos').insert({
      'trip_id': tripId,
      'storage_path': path,
    });
  }

  @override
  Future<Uint8List> download(String storagePath) =>
      _client.storage.from(_bucket).download(storagePath);

  @override
  Future<void> remove(TripPhoto photo) async {
    await _client.storage.from(_bucket).remove([photo.storagePath]);
    await _client.from('trip_photos').delete().eq('id', photo.id);
  }
}
