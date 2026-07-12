import 'ascent.dart';

/// Persists the user's climbing diary.
abstract interface class DiaryRepository {
  /// All ascents, newest first (by climb date, ties by logging time).
  Future<List<Ascent>> getAscents();

  Future<void> addAscent(Ascent ascent);

  Future<void> deleteAscent(String id);
}
