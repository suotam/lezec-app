import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_routes/domain/climbing_route.dart';
import 'package:lezec_app/features/climbing_routes/domain/climbing_type.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_sorting.dart';

ClimbingRoute route(
  String id,
  String name,
  GradingSystem system,
  String value,
) {
  return ClimbingRoute(
    id: id,
    name: name,
    grade: RouteGrade(system: system, value: value),
    type: ClimbingType.sport,
  );
}

void main() {
  group('RouteGrade ordering', () {
    test('orders Saxon grades', () {
      final grades =
          ['VIIb', 'IV', 'VIIIa', 'V', 'VIIa']
              .map(
                (v) =>
                    RouteGrade(system: GradingSystem.czechSandstone, value: v),
              )
              .toList()
            ..sort();
      expect(grades.map((g) => g.value), ['IV', 'V', 'VIIa', 'VIIb', 'VIIIa']);
    });

    test('orders French grades', () {
      final grades =
          ['7a', '5c', '6b+', '6b', '7b']
              .map((v) => RouteGrade(system: GradingSystem.french, value: v))
              .toList()
            ..sort();
      expect(grades.map((g) => g.value), ['5c', '6b', '6b+', '7a', '7b']);
    });

    test('orders UIAA grades with signs', () {
      final grades =
          ['VII-', 'VI', 'VII+', 'VII']
              .map((v) => RouteGrade(system: GradingSystem.uiaa, value: v))
              .toList()
            ..sort();
      expect(grades.map((g) => g.value), ['VI', 'VII-', 'VII', 'VII+']);
    });

    test('groups by system before comparing values', () {
      final uiaa = RouteGrade(system: GradingSystem.uiaa, value: 'IX');
      final french = RouteGrade(system: GradingSystem.french, value: '5a');
      expect(uiaa.compareTo(french), lessThan(0));
    });
  });

  group('sortRoutes', () {
    final routes = [
      route('r1', 'Cesta B', GradingSystem.french, '7a'),
      route('r2', 'Cesta A', GradingSystem.french, '5c'),
      route('r3', 'Cesta C', GradingSystem.french, '6b'),
    ];

    test('guidebook order keeps input order', () {
      expect(sortRoutes(routes, RouteSortOrder.guidebook).map((r) => r.id), [
        'r1',
        'r2',
        'r3',
      ]);
    });

    test('sorts by name', () {
      expect(sortRoutes(routes, RouteSortOrder.name).map((r) => r.id), [
        'r2',
        'r1',
        'r3',
      ]);
    });

    test('sorts by grade', () {
      expect(sortRoutes(routes, RouteSortOrder.grade).map((r) => r.id), [
        'r2',
        'r3',
        'r1',
      ]);
    });

    test('does not mutate the input list', () {
      sortRoutes(routes, RouteSortOrder.name);
      expect(routes.map((r) => r.id), ['r1', 'r2', 'r3']);
    });
  });
}
