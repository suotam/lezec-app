import 'climbing_area.dart';
import 'climbing_region.dart';

/// Read access to the climbing catalog. Implemented today by the bundled
/// demo dataset; later by a backend-backed catalog with local cache.
abstract interface class ClimbingAreaRepository {
  Future<List<ClimbingRegion>> getRegions();

  Future<List<ClimbingArea>> getAreas();

  Future<ClimbingArea?> getAreaById(String id);
}
