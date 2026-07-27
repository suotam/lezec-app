import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/community/domain/route_rating.dart';
import 'package:lezec_app/features/community/presentation/ratings_providers.dart';
import 'package:lezec_app/features/community/presentation/widgets/top_rated_section.dart';

import '../helpers/test_helpers.dart';

class _TopRatedFake implements RouteRatingsRepository {
  _TopRatedFake(this._top);

  final List<RatedRoute> _top;

  @override
  Future<List<RatedRoute>> topRated({int minCount = 1, int limit = 20}) async =>
      _top;

  @override
  Future<RouteRatingSummary> forRoute(String routeId) async =>
      RouteRatingSummary.empty;

  @override
  Future<void> setMyRating(String routeId, int stars) async {}

  @override
  Future<void> clearMyRating(String routeId) async {}
}

void main() {
  Future<void> pump(WidgetTester tester, List<RatedRoute> top) async {
    final overrides = [
      ...await testOverrides(),
      routeRatingsRepositoryProvider.overrideWithValue(_TopRatedFake(top)),
    ];
    await tester.pumpWidget(
      wrapScreen(
        const Scaffold(
          body: SingleChildScrollView(child: TopRatedRoutesSection()),
        ),
        overrides,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('resolves top-rated ids against the local catalog', (
    tester,
  ) async {
    await pump(tester, [(routeId: 'route-hrana', average: 4.6, count: 5)]);

    expect(find.text('Nejlépe hodnocené cesty'), findsOneWidget);
    expect(find.text('Testová hrana'), findsOneWidget); // from the catalog
    expect(find.text('4.6'), findsOneWidget);
    expect(find.text('Testový lom'), findsOneWidget); // its area
  });

  testWidgets('hides when nothing is rated', (tester) async {
    await pump(tester, const []);
    expect(find.text('Nejlépe hodnocené cesty'), findsNothing);
  });

  testWidgets('skips ids missing from the current catalog', (tester) async {
    await pump(tester, [(routeId: 'route-gone', average: 5.0, count: 3)]);
    // No resolvable routes → section hides.
    expect(find.text('Nejlépe hodnocené cesty'), findsNothing);
  });
}
