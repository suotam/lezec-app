import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/utilities/location_service.dart';
import 'package:lezec_app/features/climbing_areas/domain/geo_point.dart';
import 'package:lezec_app/features/climbing_areas/presentation/areas_screen.dart';

import '../helpers/test_helpers.dart';

class _FakeLocationService implements LocationService {
  _FakeLocationService(this.point);

  final GeoPoint? point;

  @override
  Future<GeoPoint?> getCurrentPosition() async => point;
}

void main() {
  Future<void> pumpAreasScreen(
    WidgetTester tester, {
    List<Override> extraOverrides = const [],
  }) async {
    final overrides = [...await testOverrides(), ...extraOverrides];
    await tester.pumpWidget(wrapScreen(const AreasScreen(), overrides));
    await tester.pumpAndSettle();
  }

  /// True when [above] is rendered higher in the list than [below].
  bool isAbove(WidgetTester tester, String above, String below) =>
      tester.getTopLeft(find.text(above)).dy <
      tester.getTopLeft(find.text(below)).dy;

  testWidgets('shows all demo areas with counts', (tester) async {
    await pumpAreasScreen(tester);

    expect(find.text('Testové věže'), findsOneWidget);
    expect(find.text('Testový lom'), findsOneWidget);
    expect(find.text('2 oblasti'), findsOneWidget);
  });

  testWidgets('search narrows the list', (tester) async {
    await pumpAreasScreen(tester);

    await tester.enterText(find.byType(TextField), 'lom');
    await tester.pumpAndSettle();

    expect(find.text('Testový lom'), findsOneWidget);
    expect(find.text('Testové věže'), findsNothing);
  });

  testWidgets('search matches without diacritics', (tester) async {
    await pumpAreasScreen(tester);

    await tester.enterText(find.byType(TextField), 'testove veze');
    await tester.pumpAndSettle();

    expect(find.text('Testové věže'), findsOneWidget);
    expect(find.text('Testový lom'), findsNothing);
  });

  testWidgets('climbing type filter narrows the list', (tester) async {
    await pumpAreasScreen(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Sportovní'));
    await tester.pumpAndSettle();

    expect(find.text('Testový lom'), findsOneWidget);
    expect(find.text('Testové věže'), findsNothing);
  });

  testWidgets('rock type filter narrows the list', (tester) async {
    await pumpAreasScreen(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Pískovec'));
    await tester.pumpAndSettle();

    expect(find.text('Testové věže'), findsOneWidget);
    expect(find.text('Testový lom'), findsNothing);
  });

  testWidgets('region filter narrows the list', (tester) async {
    await pumpAreasScreen(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Testový region B'));
    await tester.pumpAndSettle();

    expect(find.text('Testový lom'), findsOneWidget);
    expect(find.text('Testové věže'), findsNothing);
  });

  testWidgets('sort by route count puts the biggest area first', (
    tester,
  ) async {
    await pumpAreasScreen(tester);

    // Default: alphabetical, Testové věže (1 route) first.
    expect(isAbove(tester, 'Testové věže', 'Testový lom'), isTrue);

    await tester.tap(find.text('Název'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Počet cest'));
    await tester.pumpAndSettle();

    // Testový lom has 2 routes and moves up.
    expect(isAbove(tester, 'Testový lom', 'Testové věže'), isTrue);
  });

  testWidgets('distance sort orders by proximity to the user', (tester) async {
    // Position next to Testový lom (49.1, 16.1); the towers are at 50.1.
    await pumpAreasScreen(
      tester,
      extraOverrides: [
        locationServiceProvider.overrideWithValue(
          _FakeLocationService(
            const GeoPoint(latitude: 49.1, longitude: 16.1),
          ),
        ),
      ],
    );

    await tester.tap(find.text('Název'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nejbližší'));
    await tester.pumpAndSettle();

    expect(isAbove(tester, 'Testový lom', 'Testové věže'), isTrue);
  });

  testWidgets('unavailable location keeps sort and explains why', (
    tester,
  ) async {
    await pumpAreasScreen(
      tester,
      extraOverrides: [
        locationServiceProvider.overrideWithValue(_FakeLocationService(null)),
      ],
    );

    await tester.tap(find.text('Název'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nejbližší'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Polohu se nepodařilo'), findsOneWidget);
    expect(isAbove(tester, 'Testové věže', 'Testový lom'), isTrue,
        reason: 'order must stay alphabetical');
  });

  testWidgets('empty search shows empty state and clear restores list', (
    tester,
  ) async {
    await pumpAreasScreen(tester);

    await tester.enterText(find.byType(TextField), 'neexistuje');
    await tester.pumpAndSettle();

    expect(find.text('Nic jsme nenašli'), findsOneWidget);

    await tester.tap(find.text('Zrušit filtry'));
    await tester.pumpAndSettle();

    expect(find.text('Testové věže'), findsOneWidget);
    expect(find.text('Testový lom'), findsOneWidget);
  });
}
