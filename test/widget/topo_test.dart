import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/utilities/map_tile_cache.dart';
import 'package:lezec_app/features/auth/domain/auth_repository.dart';
import 'package:lezec_app/features/auth/presentation/auth_providers.dart';
import 'package:lezec_app/features/diary/presentation/diary_providers.dart';
import 'package:lezec_app/features/profile/domain/user_profile.dart';
import 'package:lezec_app/features/profile/presentation/profile_providers.dart';
import 'package:lezec_app/features/topo/domain/sector_photos_repository.dart';
import 'package:lezec_app/features/topo/presentation/topo_providers.dart';
import 'package:lezec_app/features/topo/presentation/widgets/sector_topo_section.dart';

import '../helpers/test_helpers.dart';

class _FakeSectorPhotos implements SectorPhotosRepository {
  final photos = <SectorPhoto>[];
  var uploads = 0;

  @override
  Future<List<SectorPhoto>> forSector(String sectorId) async => photos;

  @override
  Future<void> upload({
    required String areaId,
    required String sectorId,
    required Uint8List bytes,
  }) async {
    uploads++;
    photos.add((
      id: 'p$uploads',
      storagePath: '$areaId/$sectorId/p$uploads.jpg',
      publicUrl: 'https://example.com/p$uploads.jpg',
    ));
  }

  @override
  Future<void> remove(SectorPhoto photo) async {
    photos.remove(photo);
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

class _FakeProfileRepo implements ProfileRepository {
  _FakeProfileRepo(this.role);

  final String role;

  @override
  Future<UserProfile?> getOwnProfile() async =>
      UserProfile(id: 'user-1', displayName: 'Správce', role: role);

  @override
  Future<void> setDisplayName(String displayName) async {}
}

void main() {
  late _FakeSectorPhotos repository;

  setUp(() => repository = _FakeSectorPhotos());

  Future<void> pumpSection(
    WidgetTester tester, {
    AppUser? user,
    String role = 'user',
    List<Uint8List> pickerResult = const [],
  }) async {
    final overrides = [
      ...await testOverrides(),
      sectorPhotosRepositoryProvider.overrideWithValue(repository),
      authRepositoryProvider.overrideWithValue(_FakeAuth(user)),
      if (user != null)
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepo(role)),
      cachedImageBytesProvider.overrideWith(
        (ref, url) async => transparentPngBytes,
      ),
      photoPickerProvider.overrideWithValue(() async => pickerResult),
    ];
    await tester.pumpWidget(
      wrapScreen(
        const Scaffold(
          body: SingleChildScrollView(
            child: SectorTopoSection(areaId: 'area-lom', sectorId: 's1'),
          ),
        ),
        overrides,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('visitors see uploaded topos but no add button', (tester) async {
    repository.photos.add((
      id: 'p1',
      storagePath: 'area-lom/s1/p1.jpg',
      publicUrl: 'https://example.com/p1.jpg',
    ));

    await pumpSection(tester);

    expect(find.text('Topo a fotky sektoru'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsNothing);
  });

  testWidgets('section hides completely for visitors without photos', (
    tester,
  ) async {
    await pumpSection(tester);
    expect(find.text('Topo a fotky sektoru'), findsNothing);
  });

  testWidgets('admins can upload a photo', (tester) async {
    await pumpSection(
      tester,
      user: const AppUser(id: 'user-1', email: 'admin@example.com'),
      role: 'admin',
      pickerResult: [transparentPngBytes],
    );

    expect(find.text('Topo a fotky sektoru'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pumpAndSettle();

    expect(repository.uploads, 1);
    expect(find.byType(Image), findsOneWidget);
  });
}
