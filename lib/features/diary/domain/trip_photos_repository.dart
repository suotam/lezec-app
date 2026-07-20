import 'dart:typed_data';

/// One photo attached to a trip log.
typedef TripPhoto = ({String id, String storagePath});

/// Trip photos live in the private per-user Storage folder and are
/// inherently online — the diary shows them when a connection exists,
/// everything else about the trip works offline.
abstract interface class TripPhotosRepository {
  Future<List<TripPhoto>> forTrip(String tripId);

  Future<void> upload({required String tripId, required Uint8List bytes});

  Future<Uint8List> download(String storagePath);

  Future<void> remove(TripPhoto photo);
}
