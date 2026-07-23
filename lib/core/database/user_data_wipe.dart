import 'crux_database.dart';

/// Removes every locally stored user row (diary, trips, flags, history).
/// Used after account deletion; the catalog tables are untouched.
Future<void> wipeLocalUserData(CruxDatabase db) async {
  await db.transaction(() async {
    await db.delete(db.ascents).go();
    await db.delete(db.trips).go();
    await db.delete(db.userRouteFlags).go();
    await db.delete(db.recentAreaViews).go();
  });
}
