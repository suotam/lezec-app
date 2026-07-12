import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_areas/presentation/areas_screen.dart';

import '../helpers/test_helpers.dart';

void main() {
  Future<void> pumpAreasScreen(WidgetTester tester) async {
    final overrides = await testOverrides();
    await tester.pumpWidget(wrapScreen(const AreasScreen(), overrides));
    await tester.pumpAndSettle();
  }

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
