import 'package:flutter/foundation.dart';

import '../../climbing_routes/domain/climbing_type.dart';
import 'climbing_area.dart';
import 'rock_type.dart';

/// Search query + filters applied to the area list. Value object so
/// providers can compare states cheaply.
@immutable
class AreaFilter {
  const AreaFilter({
    this.query = '',
    this.climbingTypes = const {},
    this.rockTypes = const {},
  });

  final String query;

  /// Empty set means "no filter" (all types match).
  final Set<ClimbingType> climbingTypes;
  final Set<RockType> rockTypes;

  bool get isEmpty =>
      query.trim().isEmpty && climbingTypes.isEmpty && rockTypes.isEmpty;

  AreaFilter copyWith({
    String? query,
    Set<ClimbingType>? climbingTypes,
    Set<RockType>? rockTypes,
  }) {
    return AreaFilter(
      query: query ?? this.query,
      climbingTypes: climbingTypes ?? this.climbingTypes,
      rockTypes: rockTypes ?? this.rockTypes,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AreaFilter &&
      other.query == query &&
      setEquals(other.climbingTypes, climbingTypes) &&
      setEquals(other.rockTypes, rockTypes);

  @override
  int get hashCode => Object.hash(
    query,
    Object.hashAllUnordered(climbingTypes),
    Object.hashAllUnordered(rockTypes),
  );
}

/// Applies [filter] to [areas]. Pure function so it is trivially unit
/// testable and can later move server-side unchanged in meaning.
List<ClimbingArea> filterAreas(List<ClimbingArea> areas, AreaFilter filter) {
  final query = _normalize(filter.query);
  return areas.where((area) {
    if (filter.climbingTypes.isNotEmpty &&
        !area.climbingTypes.any(filter.climbingTypes.contains)) {
      return false;
    }
    if (filter.rockTypes.isNotEmpty &&
        !filter.rockTypes.contains(area.rockType)) {
      return false;
    }
    if (query.isEmpty) return true;
    final haystack = _normalize(
      '${area.name} ${area.regionName} ${area.summary} ${area.description}',
    );
    return query.split(' ').every(haystack.contains);
  }).toList();
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
