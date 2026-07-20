import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/features/climbing_areas/data/catalog_update_service.dart';
import 'package:lezec_app/features/climbing_areas/data/demo_catalog_data_source.dart';
import 'package:lezec_app/features/climbing_areas/data/drift_catalog_store.dart';
import 'package:lezec_app/features/climbing_areas/data/drift_climbing_area_repository.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CruxDatabase db;
  late DriftCatalogStore store;

  final baseUri = Uri.parse('https://example.test/catalog');
  final requested = <String>[];

  setUp(() {
    db = CruxDatabase(NativeDatabase.memory());
    store = DriftCatalogStore(
      db,
      DemoCatalogDataSource(bundle: FakeAssetBundle(testCatalogJson)),
    );
    requested.clear();
  });

  tearDown(() => db.close());

  String v2Json() => testCatalogJson
      .replaceFirst('"version": 1', '"version": 2')
      .replaceFirst('Testový lom', 'Aktualizovaný lom');

  CatalogUpdateService service(Map<String, List<int>> files) {
    return CatalogUpdateService(
      store: store,
      baseUri: baseUri,
      fetcher: (uri) async {
        final name = uri.path.split('/').last;
        requested.add(name);
        final body = files[name];
        if (body == null) throw HttpException('404', uri: uri);
        return Uint8List.fromList(body);
      },
    );
  }

  test('downloads and imports a newer catalog', () async {
    await store.ensureSeeded();
    final result = await service({
      'latest.json': utf8.encode('{"version":2,"object":"catalog-v2.json.gz"}'),
      'catalog-v2.json.gz': gzip.encode(utf8.encode(v2Json())),
    }).checkAndApply();

    expect(result.outcome, CatalogUpdateOutcome.updated);
    expect(result.version, 2);
    expect(await store.currentVersion(), 2);
    final names = (await DriftClimbingAreaRepository(
      db,
      store,
    ).getAreas()).map((a) => a.name);
    expect(names, contains('Aktualizovaný lom'));
  });

  test('same version means up to date and no catalog download', () async {
    await store.ensureSeeded();
    final result = await service({
      'latest.json': utf8.encode('{"version":1,"object":"catalog-v1.json.gz"}'),
    }).checkAndApply();

    expect(result.outcome, CatalogUpdateOutcome.upToDate);
    expect(requested, ['latest.json']);
  });

  test('the bundled asset never overwrites a newer OTA catalog', () async {
    await store.ensureSeeded();
    await service({
      'latest.json': utf8.encode('{"version":2,"object":"catalog-v2.json"}'),
      'catalog-v2.json': utf8.encode(v2Json()),
    }).checkAndApply();

    // Simulate an app restart: a fresh store over the same database and
    // the same (older) bundled asset.
    final restarted = DriftCatalogStore(
      db,
      DemoCatalogDataSource(bundle: FakeAssetBundle(testCatalogJson)),
    );
    await restarted.ensureSeeded();

    expect(await restarted.currentVersion(), 2);
    final names = (await DriftClimbingAreaRepository(
      db,
      restarted,
    ).getAreas()).map((a) => a.name);
    expect(names, contains('Aktualizovaný lom'));
    expect(names, isNot(contains('Testový lom')));
  });

  test('a malformed manifest throws instead of importing', () async {
    await store.ensureSeeded();
    await expectLater(
      service({'latest.json': utf8.encode('{"object": 42}')}).checkAndApply(),
      throwsA(anything),
    );
    expect(await store.currentVersion(), 1);
  });
}
