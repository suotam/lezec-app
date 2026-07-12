/// Persists the user's personal route flags (favorites and projects).
///
/// Backed by SharedPreferences today; the interface is designed so a Drift
/// database with backend sync can replace it without touching presentation.
abstract interface class UserRouteStateRepository {
  Future<Set<String>> getFavoriteRouteIds();

  Future<Set<String>> getProjectRouteIds();

  Future<void> setFavorite(String routeId, bool isFavorite);

  Future<void> setProject(String routeId, bool isProject);
}
