import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/auth/domain/auth_repository.dart';
import 'package:lezec_app/features/auth/presentation/auth_providers.dart';
import 'package:lezec_app/features/community/domain/route_comment.dart';
import 'package:lezec_app/features/community/presentation/comments_providers.dart';
import 'package:lezec_app/features/community/presentation/widgets/route_comments_section.dart';

import '../helpers/test_helpers.dart';

class _FakeComments implements CommentsRepository {
  final comments = <RouteComment>[];
  var _nextId = 1;

  @override
  Future<List<RouteComment>> forRoute(String routeId) async => [
    for (final comment in comments.reversed)
      if (comment.routeId == routeId) comment,
  ];

  @override
  Future<void> add({
    required String routeId,
    required String body,
    required String authorName,
  }) async {
    comments.add(
      RouteComment(
        id: 'c${_nextId++}',
        routeId: routeId,
        userId: 'user-1',
        authorName: authorName,
        body: body,
        createdAt: DateTime(2026, 7, 20),
      ),
    );
  }

  @override
  Future<void> remove(String commentId) async {
    comments.removeWhere((comment) => comment.id == commentId);
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

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  late _FakeComments repository;

  setUp(() => repository = _FakeComments());

  Future<void> pumpSection(WidgetTester tester, {AppUser? user}) async {
    final overrides = [
      ...await testOverrides(),
      commentsRepositoryProvider.overrideWithValue(repository),
      authRepositoryProvider.overrideWithValue(_FakeAuth(user)),
    ];
    await tester.pumpWidget(
      wrapScreen(
        const Scaffold(
          body: SingleChildScrollView(
            child: RouteCommentsSection(routeId: 'route-1'),
          ),
        ),
        overrides,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('signed out: comments are readable, composing is hinted', (
    tester,
  ) async {
    await repository.add(
      routeId: 'route-1',
      body: 'Krásná cesta, pozor na druhý kruh.',
      authorName: 'Pepa',
    );

    await pumpSection(tester);

    expect(find.text('Komentáře'), findsOneWidget);
    expect(find.text('Krásná cesta, pozor na druhý kruh.'), findsOneWidget);
    expect(find.textContaining('Pepa'), findsOneWidget);
    expect(
      find.text('Pro přidání komentáře se přihlaste v záložce Profil.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.send), findsNothing);
  });

  testWidgets('signed in: sending a comment adds it to the list', (
    tester,
  ) async {
    await pumpSection(
      tester,
      user: const AppUser(id: 'user-1', email: 'pepa@example.com'),
    );

    expect(find.text('Zatím žádné komentáře. Buďte první!'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Napsat komentář…'),
      'Dnes suchá, doporučuji.',
    );
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(repository.comments, hasLength(1));
    expect(find.text('Dnes suchá, doporučuji.'), findsOneWidget);
  });

  testWidgets('own comment can be deleted', (tester) async {
    await repository.add(
      routeId: 'route-1',
      body: 'Smazat mě',
      authorName: 'Pepa',
    );
    await pumpSection(
      tester,
      user: const AppUser(id: 'user-1', email: 'pepa@example.com'),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(repository.comments, isEmpty);
    expect(find.text('Smazat mě'), findsNothing);
  });
}
