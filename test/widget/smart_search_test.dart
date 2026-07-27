import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_areas/presentation/smart_search_screen.dart';

import '../helpers/test_helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapScreen(const SmartSearchScreen(), await testOverrides()),
    );
    await tester.pumpAndSettle();
  }

  Finder outerList() => find.byType(Scrollable).first;

  testWidgets('routes discipline lists route areas from the catalog', (
    tester,
  ) async {
    await pump(tester);

    // Both demo areas are route-based (a trad and a sport one). Scroll to
    // the last card so both are built.
    await tester.scrollUntilVisible(
      find.text('Testové věže'),
      300,
      scrollable: outerList(),
    );
    expect(find.text('Testové věže'), findsOneWidget);
    expect(find.text('Testový lom'), findsOneWidget);
  });

  testWidgets('switching to boulders empties the results', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Bouldery'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Nic neodpovídá'),
      300,
      scrollable: outerList(),
    );
    expect(find.text('Nic neodpovídá'), findsOneWidget);
    expect(find.text('Testový lom'), findsNothing);
  });
}
