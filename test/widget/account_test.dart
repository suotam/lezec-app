import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/utilities/map_tile_cache.dart';
import 'package:lezec_app/features/auth/domain/auth_repository.dart';
import 'package:lezec_app/features/auth/presentation/auth_providers.dart';
import 'package:lezec_app/features/profile/presentation/profile_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_helpers.dart';

class FakeAuthRepository implements AuthRepository {
  AppUser? _user;
  final _controller = StreamController<AppUser?>.broadcast();
  bool failNextSignIn = false;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> watchUser() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (failNextSignIn) {
      throw const AuthFailure('Invalid login credentials');
    }
    _user = AppUser(id: 'user-1', email: email);
    _controller.add(_user);
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async => const SignUpResult(needsEmailConfirmation: true);

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}

void main() {
  late Directory tempDir;
  late FakeAuthRepository auth;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Crux CZ',
      packageName: 'cz.cruxcz.app',
      version: '0.5.0',
      buildNumber: '2',
      buildSignature: '',
      installerStore: null,
    );
    tempDir = Directory.systemTemp.createTempSync('crux_account_test');
    auth = FakeAuthRepository();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  Future<void> pumpProfile(WidgetTester tester) async {
    final overrides = [
      ...await testOverrides(),
      mapTileCacheProvider.overrideWithValue(MapTileCache(tempDir)),
      authRepositoryProvider.overrideWithValue(auth),
    ];
    await tester.pumpWidget(wrapScreen(const ProfileScreen(), overrides));
    await tester.pumpAndSettle();
  }

  testWidgets('signing in switches the card to the account panel', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Přihlásit se'), findsOneWidget);
    expect(find.text('Vytvořit účet'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'E-mail'),
      'lezec@example.com',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Heslo'), 'tajne');
    await tester.tap(find.text('Přihlásit se'));
    await tester.pumpAndSettle();

    expect(find.text('lezec@example.com'), findsOneWidget);
    expect(find.text('Odhlásit se'), findsOneWidget);
    expect(find.text('Synchronizovat'), findsOneWidget);
    expect(find.text('Zatím nesynchronizováno'), findsOneWidget);

    await tester.tap(find.text('Odhlásit se'));
    await tester.pumpAndSettle();
    expect(find.text('Přihlásit se'), findsOneWidget);
  });

  testWidgets('a failed sign-in shows the error', (tester) async {
    auth.failNextSignIn = true;
    await pumpProfile(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'E-mail'),
      'lezec@example.com',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Heslo'), 'spatne');
    await tester.tap(find.text('Přihlásit se'));
    await tester.pumpAndSettle();

    expect(
      find.text('Nepodařilo se: Invalid login credentials'),
      findsOneWidget,
    );
  });

  testWidgets('sign-up asking for email confirmation says so', (tester) async {
    await pumpProfile(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'E-mail'),
      'lezec@example.com',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Heslo'), 'tajne');
    await tester.tap(find.text('Vytvořit účet'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Účet vytvořen. Potvrďte registraci v e-mailu a poté se přihlaste.',
      ),
      findsOneWidget,
    );
  });
}
