import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';
import 'package:lezec_app/features/diary/data/drift_diary_repository.dart';
import 'package:lezec_app/features/diary/domain/ascent.dart';
import 'package:lezec_app/features/diary/domain/trip.dart';
import 'package:lezec_app/features/diary/domain/trip_photos_repository.dart';
import 'package:lezec_app/features/diary/presentation/diary_providers.dart';
import 'package:lezec_app/features/diary/presentation/diary_screen.dart';
import 'package:lezec_app/features/diary/presentation/log_trip_screen.dart';

import '../helpers/test_helpers.dart';

class _FakeTripPhotos implements TripPhotosRepository {
  final uploaded = <String, List<Uint8List>>{};

  @override
  Future<List<TripPhoto>> forTrip(String tripId) async => [
    for (final (index, _) in (uploaded[tripId] ?? []).indexed)
      (id: 'p$index', storagePath: '$tripId/p$index.jpg'),
  ];

  @override
  Future<void> upload({
    required String tripId,
    required Uint8List bytes,
  }) async {
    uploaded.putIfAbsent(tripId, () => []).add(bytes);
  }

  @override
  Future<Uint8List> download(String storagePath) async => transparentPngBytes;

  @override
  Future<void> remove(TripPhoto photo) async {}
}

void main() {
  late CruxDatabase db;
  late _FakeTripPhotos photos;

  setUp(() {
    db = createTestDatabase();
    photos = _FakeTripPhotos();
  });

  Future<List<Override>> overrides() async => [
    ...await testOverrides(database: db),
    tripPhotosRepositoryProvider.overrideWithValue(photos),
    photoPickerProvider.overrideWithValue(() async => [transparentPngBytes]),
  ];

  testWidgets('bulk trip log creates ascents and uploads photos', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScreen(const LogTripScreen(), await overrides()),
    );
    await tester.pumpAndSettle();

    // Pick the area through the search dialog.
    await tester.tap(find.text('Vybrat oblast'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'lom');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Testový lom'));
    await tester.pumpAndSettle();

    // Add a photo through the fake picker.
    await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
    await tester.pumpAndSettle();

    // Tick both routes of the sector (scrolled into actual view first —
    // scrollUntilVisible stops at the cache extent).
    for (final name in ['Testová hrana', 'Testová plotna']) {
      await tester.scrollUntilVisible(
        find.text(name),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text(name));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Uložit'));
    await tester.pumpAndSettle();

    final repository = DriftDiaryRepository(db);
    final trips = await repository.getTrips();
    expect(trips, hasLength(1));
    expect(trips.single.areaName, 'Testový lom');

    final ascents = await repository.getAscents();
    expect(ascents, hasLength(2));
    expect(ascents.map((a) => a.tripId).toSet(), {trips.single.id});
    expect(ascents.map((a) => a.routeName).toSet(), {
      'Testová hrana',
      'Testová plotna',
    });
    expect(photos.uploaded[trips.single.id], hasLength(1));
  });

  testWidgets('diary shows the trip card and deleting removes everything', (
    tester,
  ) async {
    // Seed a trip with one linked ascent directly through the repository.
    final repository = DriftDiaryRepository(db);
    final trip = Trip(
      id: 'trip-1',
      areaId: 'area-lom',
      areaName: 'Testový lom',
      date: DateTime(2026, 7, 19),
      createdAt: DateTime(2026, 7, 19, 20),
      note: 'Skvělé podmínky.',
    );
    await repository.addTrip(trip);
    await repository.addAscent(
      Ascent(
        id: 'a1',
        tripId: trip.id,
        routeId: 'route-hrana',
        routeName: 'Testová hrana',
        grade: const RouteGrade(system: GradingSystem.french, value: '6b+'),
        areaId: 'area-lom',
        areaName: 'Testový lom',
        sectorName: 'Stěna',
        style: AscentStyle.redpoint,
        date: DateTime(2026, 7, 19),
        createdAt: DateTime(2026, 7, 19, 20, 5),
      ),
    );

    await tester.pumpWidget(wrapScreen(const DiaryScreen(), await overrides()));
    await tester.pumpAndSettle();

    // Trip card with note + the ascent grouped under it.
    expect(find.byIcon(Icons.hiking), findsWidgets);
    expect(find.text('Skvělé podmínky.'), findsOneWidget);
    expect(find.text('Testová hrana'), findsOneWidget);

    // Delete the trip via its menu — the linked ascent goes with it.
    await tester.tap(find.byType(PopupMenuButton<void>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smazat výjezd'));
    await tester.pumpAndSettle();

    expect(find.text('Výjezd byl smazán včetně přelezů.'), findsOneWidget);
    expect(await repository.getTrips(), isEmpty);
    expect(await repository.getAscents(), isEmpty);
  });
}
