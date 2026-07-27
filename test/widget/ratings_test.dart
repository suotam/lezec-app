import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/auth/domain/auth_repository.dart';
import 'package:lezec_app/features/auth/presentation/auth_providers.dart';
import 'package:lezec_app/features/community/domain/route_rating.dart';
import 'package:lezec_app/features/community/presentation/ratings_providers.dart';
import 'package:lezec_app/features/community/presentation/widgets/route_rating_section.dart';

import '../helpers/test_helpers.dart';

class _FakeRatings implements RouteRatingsRepository {
  final Map<String, int> mine = {};
  int otherCount = 0;
  int otherSum = 0;

  @override
  Future<RouteRatingSummary> forRoute(String routeId) async {
    final my = mine[routeId];
    final count = otherCount + (my != null ? 1 : 0);
    final sum = otherSum + (my ?? 0);
    return RouteRatingSummary(
      average: count == 0 ? 0 : sum / count,
      count: count,
      myStars: my,
    );
  }

  @override
  Future<void> setMyRating(String routeId, int stars) async {
    mine[routeId] = stars;
  }

  @override
  Future<void> clearMyRating(String routeId) async {
    mine.remove(routeId);
  }
}

class _FakeAuth implements AuthRepository {
  _FakeAuth(this._user);

  final AppUser? _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> watchUser() => Stream.value(_user);

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> requestPasswordReset(String email) => throw UnimplementedError();

  @override
  Future<void> completePasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) => throw UnimplementedError();
}

void main() {
  late _FakeRatings repository;

  setUp(() => repository = _FakeRatings());

  Future<void> pump(WidgetTester tester, {AppUser? user}) async {
    final overrides = [
      ...await testOverrides(),
      routeRatingsRepositoryProvider.overrideWithValue(repository),
      authRepositoryProvider.overrideWithValue(_FakeAuth(user)),
    ];
    await tester.pumpWidget(
      wrapScreen(
        const Scaffold(body: RouteRatingSection(routeId: 'route-1')),
        overrides,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the community average and count', (tester) async {
    repository
      ..otherCount = 3
      ..otherSum = 12; // average 4.0
    await pump(tester);

    expect(find.text('4.0'), findsOneWidget);
    expect(find.text('3 hodnocení'), findsOneWidget);
  });

  testWidgets('signed-out tap only hints to sign in', (tester) async {
    await pump(tester);

    // Only the interactive stars are IconButtons; tap the third.
    await tester.tap(find.byType(IconButton).at(2));
    await tester.pumpAndSettle();

    expect(
      find.text('Pro hodnocení cesty se přihlaste v záložce Profil.'),
      findsOneWidget,
    );
    expect(repository.mine, isEmpty);
  });

  testWidgets('signed-in user can rate and re-tapping clears it', (
    tester,
  ) async {
    await pump(
      tester,
      user: const AppUser(id: 'user-1', email: 'a@b.cz'),
    );

    await tester.tap(find.byType(IconButton).at(3)); // 4 stars
    await tester.pumpAndSettle();
    expect(repository.mine['route-1'], 4);

    // Re-tapping the same star clears the rating.
    await tester.tap(find.byType(IconButton).at(3));
    await tester.pumpAndSettle();
    expect(repository.mine.containsKey('route-1'), isFalse);
  });
}
