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

/// Which ascents the diary list shows. An empty style set means "all".
@immutable
class DiaryFilter {
  const DiaryFilter({this.styles = const {}});

  final Set<AscentStyle> styles;

  bool get isActive => styles.isNotEmpty;

  bool matches(Ascent ascent) =>
      styles.isEmpty || styles.contains(ascent.style);

  DiaryFilter toggled(AscentStyle style) {
    final result = {...styles};
    if (!result.remove(style)) result.add(style);
    return DiaryFilter(styles: result);
  }
}

List<Ascent> filterAscents(List<Ascent> ascents, DiaryFilter filter) =>
    [for (final ascent in ascents) if (filter.matches(ascent)) ascent];
