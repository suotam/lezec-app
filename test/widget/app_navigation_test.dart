import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/app/app.dart';

import '../helpers/test_helpers.dart';

void main() {
  testWidgets('user can browse from discover to a route detail', (
    tester,
  ) async {
    final overrides = await testOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const CruxApp()),
    );
    await tester.pumpAndSettle();

    // Discover screen shows the brand and featured demo areas.
    expect(find.text('Crux CZ'), findsOneWidget);
    expect(find.text('Testové věže'), findsWidgets);

    // Switch to the areas tab.
    await tester.tap(find.text('Oblasti'));
    await tester.pumpAndSettle();
    expect(find.text('Testový lom'), findsOneWidget);

    // Open the area detail; the description sits below the mini-map.
    await tester.tap(find.text('Testový lom'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Dlouhý popis lomu.'), 200);
    expect(find.text('Dlouhý popis lomu.'), findsOneWidget);
    expect(find.text('Sektory'), findsOneWidget);

    // Open the sector (its card sits below the fold on small screens).
    await tester.scrollUntilVisible(find.text('Stěna'), 200);
    await tester.ensureVisible(find.text('Stěna'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stěna'));
    await tester.pumpAndSettle();
    expect(find.text('Testová hrana'), findsOneWidget);
    expect(find.text('Testová plotna'), findsOneWidget);

    // Open the route detail.
    await tester.scrollUntilVisible(find.text('Testová hrana'), 200);
    await tester.ensureVisible(find.text('Testová hrana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Testová hrana'));
    await tester.pumpAndSettle();
    expect(find.text('6b+'), findsWidgets);
    expect(find.text('Oblíbená'), findsOneWidget);
    expect(find.text('Projekt'), findsOneWidget);

    // Back returns to the sector (pageBack expects an English tooltip, so
    // tap the material back button directly).
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Testová plotna'), findsOneWidget);
  });

  testWidgets('area detail is recorded as recently viewed on discover', (
    tester,
  ) async {
    final overrides = await testOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const CruxApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oblasti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Testový lom'));
    await tester.pumpAndSettle();

    // Back to discover: the visited area now appears in the recent rail.
    await tester.tap(find.text('Objevovat'));
    await tester.pumpAndSettle();

    expect(find.text('Naposledy zobrazené'), findsOneWidget);
  });

  testWidgets('a route found by search opens its detail directly', (
    tester,
  ) async {
    final overrides = await testOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const CruxApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oblasti'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'spára');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Testová spára'));
    await tester.pumpAndSettle();

    // Route detail with its context; the route lives on a rock.
    expect(find.text('Oblíbená'), findsOneWidget);
    expect(find.text('Věže · Hlavní věž'), findsOneWidget);

    // Back returns to the search results.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Cesty'), findsOneWidget);
  });

  testWidgets('an area picked on the map opens its detail', (tester) async {
    final overrides = await testOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const CruxApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oblasti'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'lom');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Zobrazit mapu'));
    await tester.pumpAndSettle();

    // Marker → selection card → area detail.
    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Testový lom'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Dlouhý popis lomu.'), 200);
    expect(find.text('Dlouhý popis lomu.'), findsOneWidget);
  });
}
