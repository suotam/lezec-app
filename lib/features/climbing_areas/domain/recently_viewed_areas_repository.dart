/// Stores which areas the user opened recently, newest first.
abstract interface class RecentlyViewedAreasRepository {
  Future<List<String>> getRecentlyViewedAreaIds();

  Future<void> recordAreaView(String areaId);
}
