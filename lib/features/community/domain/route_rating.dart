import 'package:flutter/foundation.dart';

/// A route's community rating: the average, how many people rated it and
/// the signed-in user's own stars (null when they haven't rated it).
@immutable
class RouteRatingSummary {
  const RouteRatingSummary({
    required this.average,
    required this.count,
    this.myStars,
  });

  static const empty = RouteRatingSummary(average: 0, count: 0);

  final double average;
  final int count;
  final int? myStars;

  bool get hasRatings => count > 0;
}

/// Community star ratings for routes (quality, 1–5). Reading works
/// without an account; rating requires one.
abstract interface class RouteRatingsRepository {
  Future<RouteRatingSummary> forRoute(String routeId);

  Future<void> setMyRating(String routeId, int stars);

  Future<void> clearMyRating(String routeId);
}
