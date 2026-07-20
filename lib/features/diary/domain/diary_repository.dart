import 'ascent.dart';
import 'trip.dart';

/// Persists the user's climbing diary.
abstract interface class DiaryRepository {
  /// All ascents, newest first (by climb date, ties by logging time).
  Future<List<Ascent>> getAscents();

  Future<void> addAscent(Ascent ascent);

  /// Replaces the stored ascent with the same [Ascent.id].
  Future<void> updateAscent(Ascent ascent);

  Future<void> deleteAscent(String id);

  /// All trip logs, newest first.
  Future<List<Trip>> getTrips();

  Future<void> addTrip(Trip trip);

  /// Removes the trip together with the ascents logged under it.
  Future<void> deleteTrip(String id);
}
