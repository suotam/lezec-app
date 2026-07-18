import 'package:flutter/foundation.dart';

import '../../climbing_routes/domain/climbing_type.dart';
import 'climbing_area.dart';
import 'geo_point.dart';
import 'rock_type.dart';

/// How the area list is ordered.
enum AreaSort {
  name,
  routeCount,

  /// Nearest first; needs the user's position ([AreaFilter.origin]).
  distance,
}

/// Search query + filters + ordering applied to the area list. Value
/// object so providers can compare states cheaply.
@immutable
class AreaFilter {
  const AreaFilter({
    this.query = '',
    this.climbingTypes = const {},
    this.rockTypes = const {},
    this.regionIds = const {},
    this.sort = AreaSort.name,
    this.origin,
  });

  final String query;

  /// Empty set means "no filter" (all types match).
  final Set<ClimbingType> climbingTypes;
  final Set<RockType> rockTypes;
  final Set<String> regionIds;

  final AreaSort sort;

  /// The user's position when sorting by distance; null until located.
  final GeoPoint? origin;

  bool get isEmpty =>
      query.trim().isEmpty &&
      climbingTypes.isEmpty &&
      rockTypes.isEmpty &&
      regionIds.isEmpty;

  AreaFilter copyWith({
    String? query,
    Set<ClimbingType>? climbingTypes,
    Set<RockType>? rockTypes,
    Set<String>? regionIds,
    AreaSort? sort,
    GeoPoint? origin,
  }) {
    return AreaFilter(
      query: query ?? this.query,
      climbingTypes: climbingTypes ?? this.climbingTypes,
      rockTypes: rockTypes ?? this.rockTypes,
      regionIds: regionIds ?? this.regionIds,
      sort: sort ?? this.sort,
      origin: origin ?? this.origin,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AreaFilter &&
      other.query == query &&
      setEquals(other.climbingTypes, climbingTypes) &&
      setEquals(other.rockTypes, rockTypes) &&
      setEquals(other.regionIds, regionIds) &&
      other.sort == sort &&
      other.origin == origin;

  @override
  int get hashCode => Object.hash(
    query,
    Object.hashAllUnordered(climbingTypes),
    Object.hashAllUnordered(rockTypes),
    Object.hashAllUnordered(regionIds),
    sort,
    origin,
  );
}

/// Applies [filter] to [areas] and orders the result by [AreaFilter.sort].
/// Pure function so it is trivially unit testable and can later move
/// server-side unchanged in meaning.
List<ClimbingArea> filterAreas(List<ClimbingArea> areas, AreaFilter filter) {
  final query = _normalize(filter.query);
  final result = areas.where((area) {
    if (filter.climbingTypes.isNotEmpty &&
        !area.climbingTypes.any(filter.climbingTypes.contains)) {
      return false;
    }
    if (filter.rockTypes.isNotEmpty &&
        !filter.rockTypes.contains(area.rockType)) {
      return false;
    }
    if (filter.regionIds.isNotEmpty &&
        !filter.regionIds.contains(area.regionId)) {
      return false;
    }
    if (query.isEmpty) return true;
    final haystack = _normalize(
      '${area.name} ${area.regionName} ${area.summary} ${area.description}',
    );
    return query.split(' ').every(haystack.contains);
  }).toList();
  return sortAreas(result, filter.sort, origin: filter.origin);
}

/// Orders [areas] by [sort]. Distance sorting without an [origin] keeps
/// name order (the UI only enables it once a position is known).
List<ClimbingArea> sortAreas(
  List<ClimbingArea> areas,
  AreaSort sort, {
  GeoPoint? origin,
}) {
  final result = [...areas];
  switch (sort) {
    case AreaSort.name:
      result.sort((a, b) => _normalize(a.name).compareTo(_normalize(b.name)));
    case AreaSort.routeCount:
      result.sort((a, b) => b.routeCount.compareTo(a.routeCount));
    case AreaSort.distance:
      if (origin == null) {
        return sortAreas(result, AreaSort.name);
      }
      result.sort(
        (a, b) => origin
            .distanceInKmTo(a.location)
            .compareTo(origin.distanceInKmTo(b.location)),
      );
  }
  return result;
}

/// Lowercases and strips Czech diacritics so `veze` finds `věže`.
String _normalize(String input) {
  const diacritics = 'áčďéěíňóřšťúůýžàäëöü';
  const plain = 'acdeeinorstuuyzaaeou';
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = diacritics.indexOf(char);
    buffer.write(index >= 0 ? plain[index] : char);
  }
  return buffer.toString().trim();
}
