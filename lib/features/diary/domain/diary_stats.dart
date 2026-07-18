import 'package:flutter/foundation.dart';

import 'ascent.dart';

/// Aggregated diary numbers shown above the ascent list. Pure derivation
/// from the ascent list so it stays trivially testable.
@immutable
class DiaryStats {
  const DiaryStats({
    required this.totalAscents,
    required this.ascentsThisYear,
    required this.uniqueRoutes,
    required this.byStyle,
  });

  factory DiaryStats.from(List<Ascent> ascents, {required DateTime now}) {
    final byStyle = <AscentStyle, int>{};
    final routeIds = <String>{};
    var thisYear = 0;
    for (final ascent in ascents) {
      byStyle.update(ascent.style, (count) => count + 1, ifAbsent: () => 1);
      routeIds.add(ascent.routeId);
      if (ascent.date.year == now.year) thisYear++;
    }
    return DiaryStats(
      totalAscents: ascents.length,
      ascentsThisYear: thisYear,
      uniqueRoutes: routeIds.length,
      byStyle: {
        // Stable chip order: declaration order of AscentStyle.
        for (final style in AscentStyle.values) style: ?byStyle[style],
      },
    );
  }

  final int totalAscents;
  final int ascentsThisYear;
  final int uniqueRoutes;

  /// Ascent counts per style, only styles that occur, in enum order.
  final Map<AscentStyle, int> byStyle;
}

/// Which ascents the diary list shows. Empty sets/null mean "all".
@immutable
class DiaryFilter {
  const DiaryFilter({
    this.styles = const {},
    this.years = const {},
    this.areaId,
  });

  final Set<AscentStyle> styles;
  final Set<int> years;
  final String? areaId;

  bool get isActive => styles.isNotEmpty || years.isNotEmpty || areaId != null;

  bool matches(Ascent ascent) =>
      (styles.isEmpty || styles.contains(ascent.style)) &&
      (years.isEmpty || years.contains(ascent.date.year)) &&
      (areaId == null || ascent.areaId == areaId);

  DiaryFilter toggledStyle(AscentStyle style) => DiaryFilter(
    styles: _toggled(styles, style),
    years: years,
    areaId: areaId,
  );

  DiaryFilter toggledYear(int year) =>
      DiaryFilter(styles: styles, years: _toggled(years, year), areaId: areaId);

  /// Null selects all areas again.
  DiaryFilter withArea(String? areaId) =>
      DiaryFilter(styles: styles, years: years, areaId: areaId);

  static Set<T> _toggled<T>(Set<T> set, T value) {
    final result = {...set};
    if (!result.remove(value)) result.add(value);
    return result;
  }
}

/// One area option for the diary's area filter dropdown.
typedef DiaryAreaOption = ({String areaId, String areaName, int count});

/// Distinct climb years in [ascents], newest first.
List<int> diaryYears(List<Ascent> ascents) {
  final years = {for (final ascent in ascents) ascent.date.year}.toList()
    ..sort((a, b) => b.compareTo(a));
  return years;
}

/// Distinct areas in [ascents] with entry counts, alphabetical.
List<DiaryAreaOption> diaryAreas(List<Ascent> ascents) {
  final names = <String, String>{};
  final counts = <String, int>{};
  for (final ascent in ascents) {
    names[ascent.areaId] = ascent.areaName;
    counts.update(ascent.areaId, (c) => c + 1, ifAbsent: () => 1);
  }
  final options = [
    for (final id in names.keys)
      (areaId: id, areaName: names[id]!, count: counts[id]!),
  ]..sort((a, b) => a.areaName.compareTo(b.areaName));
  return options;
}

List<Ascent> filterAscents(List<Ascent> ascents, DiaryFilter filter) => [
  for (final ascent in ascents)
    if (filter.matches(ascent)) ascent,
];
