import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_areas/presentation/sector_detail_screen.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';
import 'package:lezec_app/features/climbing_routes/presentation/route_detail_screen.dart';
import 'package:lezec_app/features/diary/data/drift_diary_repository.dart';
import 'package:lezec_app/features/diary/domain/ascent.dart';
import 'package:lezec_app/features/diary/presentation/diary_screen.dart';

import '../helpers/test_helpers.dart';

Ascent buildAscent({
  required String id,
  String routeId = 'route-hrana',
  String routeName = 'Testová hrana',
  AscentStyle style = AscentStyle.flash,
  DateTime? date,
}) {
  return Ascent(
    id: id,
    routeId: routeId,
    routeName: routeName,
    grade: const RouteGrade(system: GradingSystem.french, value: '6b+'),
    areaId: 'area-lom',
    areaName: 'Testový lom',
    sectorName: 'Stěna',
    style: style,
    date: date ?? DateTime(2026, 7, 10),
    createdAt: DateTime(2026, 7, 10, 18),
  );
}

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
    await DriftDiaryRepository(db).addAscent(buildAscent(id: 'a1'));

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

  testWidgets('shows stats and filters the list by style', (tester) async {
    final db = createTestDatabase();
    final repository = DriftDiaryRepository(db);
    await repository.addAscent(
      buildAscent(id: 'a1', style: AscentStyle.onsight, date: DateTime(2026, 7, 1)),
    );
    await repository.addAscent(
      buildAscent(
        id: 'a2',
        routeId: 'route-plotna',
        routeName: 'Testová plotna',
        style: AscentStyle.flash,
        date: DateTime(2025, 8, 1),
      ),
    );

    await tester.pumpWidget(
      wrapScreen(const DiaryScreen(), await testOverrides(database: db)),
    );
    await tester.pumpAndSettle();

    // Stats card: 2 total, 1 this year, 2 distinct routes.
    expect(find.text('Celkem'), findsOneWidget);
    expect(find.text('Letos'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));
    expect(find.text('1'), findsOneWidget);

    // Style chips carry counts; tapping one narrows the list.
    await tester.tap(find.text('OS · 1'));
    await tester.pumpAndSettle();
    expect(find.text('Testová hrana'), findsOneWidget);
    expect(find.text('Testová plotna'), findsNothing);

    // Selecting the other style too shows both again.
    await tester.tap(find.text('Flash · 1'));
    await tester.pumpAndSettle();
    expect(find.text('Testová plotna'), findsOneWidget);
  });

  testWidgets('empty filter result offers clearing the filter',
      (tester) async {
    final db = createTestDatabase();
    await DriftDiaryRepository(db)
        .addAscent(buildAscent(id: 'a1', style: AscentStyle.onsight));

    await tester.pumpWidget(
      wrapScreen(const DiaryScreen(), await testOverrides(database: db)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('OS · 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OS · 1'));
    await tester.pumpAndSettle();
    expect(find.text('Testová hrana'), findsOneWidget,
        reason: 'toggling a chip twice must reset to all entries');
  });

  testWidgets('climbed route gets a check mark in the sector route list',
      (tester) async {
    final db = createTestDatabase();
    await DriftDiaryRepository(db).addAscent(buildAscent(id: 'a1'));

    await tester.pumpWidget(
      wrapScreen(
        const SectorDetailScreen(areaId: 'area-lom', sectorId: 'sector-stena'),
        await testOverrides(database: db),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget,
        reason: 'only route-hrana is climbed, route-plotna is not');
  });
}
