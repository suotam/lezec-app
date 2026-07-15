import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';
import 'package:lezec_app/features/diary/domain/ascent.dart';
import 'package:lezec_app/features/diary/domain/diary_stats.dart';

Ascent ascent({
  required String id,
  String routeId = 'route-1',
  AscentStyle style = AscentStyle.redpoint,
  DateTime? date,
}) {
  return Ascent(
    id: id,
    routeId: routeId,
    routeName: 'Cesta',
    grade: const RouteGrade(system: GradingSystem.uiaa, value: 'VI'),
    areaId: 'area-1',
    areaName: 'Oblast',
    sectorName: 'Sektor',
    style: style,
    date: date ?? DateTime(2026, 7, 1),
    createdAt: DateTime(2026, 7, 1, 18),
  );
}

void main() {
  final now = DateTime(2026, 7, 15);

  group('DiaryStats.from', () {
    test('is all zeros for an empty diary', () {
      final stats = DiaryStats.from(const [], now: now);
      expect(stats.totalAscents, 0);
      expect(stats.ascentsThisYear, 0);
      expect(stats.uniqueRoutes, 0);
      expect(stats.byStyle, isEmpty);
    });

    test('counts totals, this year and unique routes', () {
      final stats = DiaryStats.from([
        ascent(id: 'a1', routeId: 'r1', date: DateTime(2026, 7, 1)),
        ascent(id: 'a2', routeId: 'r1', date: DateTime(2025, 8, 1)),
        ascent(id: 'a3', routeId: 'r2', date: DateTime(2026, 1, 1)),
      ], now: now);

      expect(stats.totalAscents, 3);
      expect(stats.ascentsThisYear, 2);
      expect(stats.uniqueRoutes, 2);
    });

    test('groups by style in declaration order, only occurring styles', () {
      final stats = DiaryStats.from([
        ascent(id: 'a1', style: AscentStyle.attempt),
        ascent(id: 'a2', style: AscentStyle.onsight),
        ascent(id: 'a3', style: AscentStyle.attempt),
      ], now: now);

      expect(stats.byStyle.keys.toList(), [
        AscentStyle.onsight,
        AscentStyle.attempt,
      ]);
      expect(stats.byStyle[AscentStyle.attempt], 2);
      expect(stats.byStyle.containsKey(AscentStyle.flash), isFalse);
    });
  });

  group('DiaryFilter', () {
    final entries = [
      ascent(id: 'a1', style: AscentStyle.onsight),
      ascent(id: 'a2', style: AscentStyle.flash),
      ascent(id: 'a3', style: AscentStyle.onsight),
    ];

    test('empty filter matches everything', () {
      expect(filterAscents(entries, const DiaryFilter()), hasLength(3));
      expect(const DiaryFilter().isActive, isFalse);
    });

    test('selected styles combine and toggle off again', () {
      var filter = const DiaryFilter().toggled(AscentStyle.onsight);
      expect(filterAscents(entries, filter).map((a) => a.id), ['a1', 'a3']);

      filter = filter.toggled(AscentStyle.flash);
      expect(filterAscents(entries, filter), hasLength(3));

      filter = filter.toggled(AscentStyle.onsight);
      expect(filterAscents(entries, filter).map((a) => a.id), ['a2']);

      filter = filter.toggled(AscentStyle.flash);
      expect(filter.isActive, isFalse);
    });
  });
}
