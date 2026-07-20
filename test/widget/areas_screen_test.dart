import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_areas/presentation/widgets/area_card.dart';
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
          _FakeLocationService(const GeoPoint(latitude: 49.1, longitude: 16.1)),
        ),
      ],
    );

    await tester.tap(find.text('Název'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nejbližší'));
    await tester.pumpAndSettle();

    expect(isAbove(tester, 'Testový lom', 'Testové věže'), isTrue);
    expect(
      find.textContaining(' km'),
      findsNWidgets(2),
      reason: 'cards show the distance when sorted by proximity',
    );
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
    expect(
      isAbove(tester, 'Testové věže', 'Testový lom'),
      isTrue,
      reason: 'order must stay alphabetical',
    );
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

  testWidgets('search finds routes across the whole catalog', (tester) async {
    await pumpAreasScreen(tester);

    await tester.enterText(find.byType(TextField), 'hrana');
    await tester.pumpAndSettle();

    // No area matches, but the route section does.
    expect(find.text('Nic jsme nenašli'), findsNothing);
    expect(find.text('Cesty'), findsOneWidget);
    expect(find.text('Testová hrana'), findsOneWidget);
    expect(find.text('Stěna · Testový lom'), findsOneWidget);
    expect(find.text('6b+'), findsOneWidget);
  });

  testWidgets('search finds sectors and rocks alongside areas', (tester) async {
    await pumpAreasScreen(tester);

    await tester.enterText(find.byType(TextField), 'vez');
    await tester.pumpAndSettle();

    // The matching area card is still there (the area name also shows up
    // as the sector tile's subtitle)…
    expect(find.text('Testové věže'), findsWidgets);
    // …plus the sector and rock groups from the catalog-wide search.
    expect(find.text('Sektory'), findsOneWidget);
    expect(find.text('Věže'), findsOneWidget);

    // The rock group sits below the fold of the test viewport.
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Skály a věže'), findsOneWidget);
    expect(find.text('Hlavní věž'), findsOneWidget);
    expect(find.text('Cesty'), findsNothing);
  });

  testWidgets('map view shows a marker per filtered area', (tester) async {
    await pumpAreasScreen(tester);

    await tester.tap(find.byTooltip('Zobrazit mapu'));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsNWidgets(2));

    // Filtering narrows the markers just like the list.
    await tester.enterText(find.byType(TextField), 'lom');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    // Back to the list view.
    await tester.tap(find.byTooltip('Zobrazit seznam'));
    await tester.pumpAndSettle();
    expect(find.byType(FlutterMap), findsNothing);
    expect(find.text('Testový lom'), findsOneWidget);
  });

  testWidgets('tapping a marker shows the area card', (tester) async {
    await pumpAreasScreen(tester);

    await tester.enterText(find.byType(TextField), 'lom');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Zobrazit mapu'));
    await tester.pumpAndSettle();

    expect(find.byType(AreaCard), findsNothing);
    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();

    final card = find.byType(AreaCard);
    expect(card, findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.text('Testový lom')),
      findsOneWidget,
    );
    // The quarry has no parking spots in the test catalog.
    expect(find.byIcon(Icons.local_parking), findsNothing);
  });

  testWidgets('my-location button shows the position dot on the map', (
    tester,
  ) async {
    await pumpAreasScreen(
      tester,
      extraOverrides: [
        locationServiceProvider.overrideWithValue(
          _FakeLocationService(const GeoPoint(latitude: 49.9, longitude: 15.4)),
        ),
      ],
    );
    await tester.tap(find.byTooltip('Zobrazit mapu'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('myLocationMarker')), findsNothing);
    await tester.tap(find.byTooltip('Moje poloha'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('myLocationMarker')), findsOneWidget);
  });

  testWidgets('unavailable location on the map explains itself', (
    tester,
  ) async {
    await pumpAreasScreen(
      tester,
      extraOverrides: [
        locationServiceProvider.overrideWithValue(_FakeLocationService(null)),
      ],
    );
    await tester.tap(find.byTooltip('Zobrazit mapu'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Moje poloha'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('myLocationMarker')), findsNothing);
    expect(find.textContaining('Polohu se nepodařilo zjistit'), findsOneWidget);
  });

  testWidgets('selecting an area reveals its parking markers', (tester) async {
    await pumpAreasScreen(tester);

    await tester.enterText(find.byType(TextField), 'veze');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Zobrazit mapu'));
    await tester.pumpAndSettle();

    // Parking only appears once its area is selected.
    expect(find.byIcon(Icons.local_parking), findsNothing);
    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.local_parking), findsOneWidget);

    // Deselecting (tap on an empty part of the map — its top-left
    // corner; the markers sit on the NE–SW diagonal) hides it. The pump
    // advances fake time so the map's gesture arena resolves the tap.
    final mapRect = tester.getRect(find.byType(FlutterMap));
    await tester.tapAt(mapRect.topLeft + const Offset(30, 30));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.local_parking), findsNothing);
  });
}
