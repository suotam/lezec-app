import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/utilities/map_tile_cache.dart';
import 'package:lezec_app/features/profile/presentation/profile_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Crux CZ',
      packageName: 'cz.cruxcz.app',
      version: '0.5.0',
      buildNumber: '2',
      buildSignature: '',
      installerStore: null,
    );
    tempDir = Directory.systemTemp.createTempSync('crux_tiles_test');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  Future<void> pumpProfile(WidgetTester tester) async {
    final overrides = [
      ...await testOverrides(),
      mapTileCacheProvider.overrideWithValue(MapTileCache(tempDir)),
    ];
    await tester.pumpWidget(wrapScreen(const ProfileScreen(), overrides));
    await tester.pumpAndSettle();
  }

  testWidgets('shows app version and catalog info', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Crux CZ'), findsOneWidget);
    expect(find.textContaining('0.5.0 (2)'), findsOneWidget);
    // The data card sits below the account card on the test viewport;
    // the first Scrollable is the screen's ListView (text fields in the
    // sign-in form have their own).
    await tester.scrollUntilVisible(
      find.text('2 oblasti · 3 cesty'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // Test catalog: version 1, two areas, three routes.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2 oblasti · 3 cesty'), findsOneWidget);
  });

  testWidgets('shows map cache size and clears it', (tester) async {
    // Two fake cached tiles totalling 1 MiB.
    File('${tempDir.path}/a.tile').writeAsBytesSync(List.filled(786432, 1));
    File('${tempDir.path}/b.tile').writeAsBytesSync(List.filled(262144, 2));

    await pumpProfile(tester);
    await tester.scrollUntilVisible(
      find.text('Vymazat'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Vymazat'));
    await tester.pumpAndSettle();
    expect(find.text('1.0 MB'), findsOneWidget);

    await tester.tap(find.text('Vymazat'));
    await tester.pumpAndSettle();

    expect(find.text('Mapová cache byla vymazána.'), findsOneWidget);
    expect(find.text('0.0 MB'), findsOneWidget);
    expect(tempDir.listSync(), isEmpty);
  });
}
