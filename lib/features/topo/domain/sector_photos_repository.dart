import 'dart:typed_data';

/// One topo/overview photo of a sector, uploaded by an area manager or
/// admin and visible to everyone (public URL).
typedef SectorPhoto = ({String id, String storagePath, String publicUrl});

abstract interface class SectorPhotosRepository {
  Future<List<SectorPhoto>> forSector(String sectorId);

  /// Manager/admin only (enforced by RLS + storage policies).
  Future<void> upload({
    required String areaId,
    required String sectorId,
    required Uint8List bytes,
  });

  Future<void> remove(SectorPhoto photo);
}
