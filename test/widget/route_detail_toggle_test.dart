import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/features/climbing_routes/presentation/route_detail_screen.dart';
import 'package:lezec_app/features/projects/data/drift_user_route_state_repository.dart';

import '../helpers/test_helpers.dart';

void main() {
  Future<CruxDatabase> pumpRouteDetail(
    WidgetTester tester, {
    CruxDatabase? database,
  }) async {
    final db = database ?? createTestDatabase();
    final overrides = await testOverrides(database: db);
    await tester.pumpWidget(
      wrapScreen(const RouteDetailScreen(routeId: 'route-hrana'), overrides),
    );
    await tester.pumpAndSettle();
    return db;
  }

  testWidgets('shows route information', (tester) async {
    await pumpRouteDetail(tester);

    expect(find.text('Testová hrana'), findsWidgets);
    expect(find.text('6b+'), findsWidgets);
    expect(find.textContaining('Francouzská'), findsOneWidget);
    expect(find.text('15 m'), findsOneWidget);
    expect(find.text('Testový lom'), findsOneWidget);
  });

  testWidgets('favorite toggle persists to storage', (tester) async {
    final db = await pumpRouteDetail(tester);

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.text('Oblíbená'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(await DriftUserRouteStateRepository(db).getFavoriteRouteIds(), {
      'route-hrana',
    });
  });

  testWidgets('project toggle persists to storage', (tester) async {
    final db = await pumpRouteDetail(tester);

    await tester.tap(find.text('Projekt'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.flag), findsOneWidget);
    expect(await DriftUserRouteStateRepository(db).getProjectRouteIds(), {
      'route-hrana',
    });
  });

  testWidgets('favorite state survives an app restart', (tester) async {
    final db = await pumpRouteDetail(tester);
    await tester.tap(find.text('Oblíbená'));
    await tester.pumpAndSettle();

    // Simulate a restart: a fresh widget tree and provider scope reading
    // from the same database.
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpRouteDetail(tester, database: db);

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });
}
