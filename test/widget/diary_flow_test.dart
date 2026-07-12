import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';
import 'package:lezec_app/features/climbing_routes/presentation/route_detail_screen.dart';
import 'package:lezec_app/features/diary/data/drift_diary_repository.dart';
import 'package:lezec_app/features/diary/domain/ascent.dart';
import 'package:lezec_app/features/diary/presentation/diary_screen.dart';

import '../helpers/test_helpers.dart';

void main() {
  testWidgets('user logs an ascent and finds it in the diary', (tester) async {
    final db = createTestDatabase();
    await tester.pumpWidget(
      wrapScreen(
        const RouteDetailScreen(routeId: 'route-hrana'),
        await testOverrides(database: db),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zapsat přelez'));
    await tester.pumpAndSettle();
    expect(find.text('Zápis přelezu'), findsOneWidget);

    await tester.tap(find.text('OS'));
    await tester.enterText(find.byType(TextField), 'Krásné podmínky.');
    await tester.ensureVisible(find.text('Uložit přelez'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uložit přelez'));
    await tester.pumpAndSettle();

    // Confirmation snackbar and the new "my ascents" section.
    expect(find.text('Přelez byl uložen do deníku.'), findsOneWidget);
    expect(find.text('Moje přelezy'), findsOneWidget);

    // A fresh widget tree over the same database (simulated restart):
    // the diary lists the ascent.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      wrapScreen(const DiaryScreen(), await testOverrides(database: db)),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 přelez'), findsOneWidget);
    expect(find.text('Testová hrana'), findsOneWidget);
    expect(find.textContaining('OS'), findsWidgets);
    expect(find.text('Krásné podmínky.'), findsOneWidget);
  });

  testWidgets('deleting the only entry shows the empty state', (tester) async {
    final db = createTestDatabase();
    await DriftDiaryRepository(db).addAscent(
      Ascent(
        id: 'a1',
        routeId: 'route-hrana',
        routeName: 'Testová hrana',
        grade: const RouteGrade(system: GradingSystem.french, value: '6b+'),
        areaId: 'area-lom',
        areaName: 'Testový lom',
        sectorName: 'Stěna',
        style: AscentStyle.flash,
        date: DateTime(2026, 7, 10),
        createdAt: DateTime(2026, 7, 10, 18),
      ),
    );

    await tester.pumpWidget(
      wrapScreen(const DiaryScreen(), await testOverrides(database: db)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Testová hrana'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<void>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smazat záznam'));
    await tester.pumpAndSettle();

    expect(find.text('Záznam byl smazán.'), findsOneWidget);
    expect(find.text('Zatím žádné přelezy'), findsOneWidget);
  });
}
