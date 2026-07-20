/// Row snapshots exchanged between the local database and the backend.
/// Plain records so both sides (Drift and Supabase) map to the same shape
/// and the merge logic stays pure.
library;

typedef AscentRecord = ({
  String id,
  String? tripId,
  String routeId,
  String routeName,
  String gradeValue,
  String gradeSystem,
  String areaId,
  String areaName,
  String sectorName,
  String style,
  DateTime climbedOn,
  String? note,
  DateTime createdAt,
  DateTime updatedAt,
  DateTime? deletedAt,
});

typedef RouteFlagRecord = ({
  String routeId,
  bool isFavorite,
  bool isProject,
  DateTime updatedAt,
});

typedef AreaViewRecord = ({String areaId, DateTime viewedAt});

typedef TripRecord = ({
  String id,
  String areaId,
  String areaName,
  DateTime tripDate,
  String? note,
  DateTime createdAt,
  DateTime updatedAt,
  DateTime? deletedAt,
});

/// Remote side of the sync. Implemented over Supabase; faked in tests.
/// All calls operate on the signed-in user's rows only.
abstract interface class SyncBackend {
  Future<List<AscentRecord>> fetchAscents();

  Future<void> upsertAscents(List<AscentRecord> records);

  Future<List<TripRecord>> fetchTrips();

  Future<void> upsertTrips(List<TripRecord> records);

  Future<List<RouteFlagRecord>> fetchRouteFlags();

  Future<void> upsertRouteFlags(List<RouteFlagRecord> records);

  Future<List<AreaViewRecord>> fetchAreaViews();

  Future<void> upsertAreaViews(List<AreaViewRecord> records);
}
