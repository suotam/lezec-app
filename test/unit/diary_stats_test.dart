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
      var filter = const DiaryFilter().toggledStyle(AscentStyle.onsight);
      expect(filterAscents(entries, filter).map((a) => a.id), ['a1', 'a3']);

      filter = filter.toggledStyle(AscentStyle.flash);
      expect(filterAscents(entries, filter), hasLength(3));

      filter = filter.toggledStyle(AscentStyle.onsight);
      expect(filterAscents(entries, filter).map((a) => a.id), ['a2']);

      filter = filter.toggledStyle(AscentStyle.flash);
      expect(filter.isActive, isFalse);
    });

    test('filters by year and area and combines them', () {
      final mixed = [
        ascent(id: 'y1', date: DateTime(2025, 6, 1)),
        ascent(id: 'y2', date: DateTime(2026, 6, 1)),
      ];
      expect(
        filterAscents(mixed, const DiaryFilter(years: {2025})).single.id,
        'y1',
      );
      expect(
        filterAscents(mixed, const DiaryFilter(areaId: 'area-1')),
        hasLength(2),
      );
      expect(
        filterAscents(
          mixed,
          const DiaryFilter(years: {2025}, areaId: 'missing'),
        ),
        isEmpty,
      );
      expect(const DiaryFilter(areaId: 'area-1').isActive, isTrue);
    });
  });

  group('diaryYears and diaryAreas', () {
    test('lists distinct years newest first and areas with counts', () {
      final entries = [
        ascent(id: 'a1', date: DateTime(2024, 5, 1)),
        ascent(id: 'a2', date: DateTime(2026, 5, 1)),
        ascent(id: 'a3', date: DateTime(2026, 8, 1)),
      ];
      expect(diaryYears(entries), [2026, 2024]);

      final areas = diaryAreas(entries);
      expect(areas.single.areaId, 'area-1');
      expect(areas.single.count, 3);
    });
  });

  group('Ascent.copyWith', () {
    test('changes editable fields and can clear the note', () {
      final original = ascent(id: 'a1');
      final updated = original.copyWith(
        style: AscentStyle.flash,
        date: DateTime(2026, 1, 2),
        note: 'nová poznámka',
      );
      expect(updated.id, original.id);
      expect(updated.routeName, original.routeName);
      expect(updated.createdAt, original.createdAt);
      expect(updated.style, AscentStyle.flash);
      expect(updated.note, 'nová poznámka');

      expect(updated.copyWith(note: null).note, isNull);
      expect(updated.copyWith().note, 'nová poznámka');
    });
  });
}
