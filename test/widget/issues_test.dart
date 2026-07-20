import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/auth/domain/auth_repository.dart';
import 'package:lezec_app/features/auth/presentation/auth_providers.dart';
import 'package:lezec_app/features/issues/domain/issue_report.dart';
import 'package:lezec_app/features/issues/presentation/issues_providers.dart';
import 'package:lezec_app/features/issues/presentation/widgets/report_issue_button.dart';

import '../helpers/test_helpers.dart';

class _FakeIssues implements IssueReportsRepository {
  final reports = <IssueReport>[];
  var _nextId = 1;

  @override
  Future<void> fileReport({
    required String areaId,
    required String areaName,
    required String description,
  }) async {
    reports.add(
      IssueReport(
        id: 'i${_nextId++}',
        userId: 'user-1',
        areaId: areaId,
        areaName: areaName,
        description: description,
        status: IssueStatus.open,
        createdAt: DateTime(2026, 7, 20),
      ),
    );
  }

  @override
  Future<List<IssueReport>> visibleReports() async => reports.reversed.toList();

  @override
  Future<void> setStatus(String reportId, IssueStatus status) async {
    final index = reports.indexWhere((report) => report.id == reportId);
    final old = reports[index];
    reports[index] = IssueReport(
      id: old.id,
      userId: old.userId,
      areaId: old.areaId,
      areaName: old.areaName,
      description: old.description,
      status: status,
      createdAt: old.createdAt,
    );
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
  Future<void> signOut() async {}
}

void main() {
  late _FakeIssues repository;

  setUp(() => repository = _FakeIssues());

  Future<void> pumpButton(WidgetTester tester, {AppUser? user}) async {
    final overrides = [
      ...await testOverrides(),
      issueReportsRepositoryProvider.overrideWithValue(repository),
      authRepositoryProvider.overrideWithValue(_FakeAuth(user)),
    ];
    await tester.pumpWidget(
      wrapScreen(
        const Scaffold(
          body: ReportIssueButton(areaId: 'area-lom', areaName: 'Testový lom'),
        ),
        overrides,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('signed out tap only hints to sign in', (tester) async {
    await pumpButton(tester);

    await tester.tap(find.text('Nahlásit závadu'));
    await tester.pumpAndSettle();

    expect(
      find.text('Pro nahlášení závady se přihlaste v záložce Profil.'),
      findsOneWidget,
    );
    expect(find.text('Nahlášení závady'), findsNothing);
  });

  testWidgets('signed in files a report through the dialog', (tester) async {
    await pumpButton(
      tester,
      user: const AppUser(id: 'user-1', email: 'pepa@example.com'),
    );

    await tester.tap(find.text('Nahlásit závadu'));
    await tester.pumpAndSettle();
    expect(find.text('Nahlášení závady'), findsOneWidget);
    expect(find.text('Testový lom'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Vyklepaný druhý kruh na Testové hraně.',
    );
    await tester.tap(find.text('Odeslat'));
    await tester.pumpAndSettle();

    expect(repository.reports, hasLength(1));
    expect(repository.reports.single.areaId, 'area-lom');
    expect(find.text('Děkujeme, závada byla nahlášena.'), findsOneWidget);
  });
}
