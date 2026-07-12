import 'dart:io';

import 'package:chs_importer/chs_importer.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('chs_importer'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  Future<Snapshot> snapshotFromFixtures() async {
    final snapshot = await Snapshot.open(tempDir.path);
    Future<void> store(String kind, int id, String fixtureFile) =>
        snapshot.store(
          kind: kind,
          id: id,
          url: 'https://www.horosvaz.cz/skaly-$kind-$id/',
          body: File('test/fixtures/$fixtureFile').readAsStringSync(),
          sha256: fixtureFile,
          fetchedAt: DateTime.utc(2026, 7, 12),
        );
    await store('sektor', 9001, 'sektor-9001.html');
    await store('sektor-map', 9001, 'sektor-map-9001.txt');
    await store('skala', 8001, 'skala-8001.html');
    return snapshot;
  }

  test('builds a valid catalog from a snapshot directory', () async {
    final snapshot = await snapshotFromFixtures();
    final result = await buildCatalogFromSnapshot(snapshot, version: 3);

    expect(result.validation.isValid, isTrue,
        reason: result.validation.errors.join('\n'));
    expect(result.catalog['version'], 3);

    final area =
        (result.catalog['areas'] as List).single as Map<String, Object?>;
    expect(area['name'], 'Zkušební skály');
    expect(
      (area['location'] as Map)['latitude'],
      49.9003444,
      reason: 'GPS must come from the map-code pin',
    );

    final sector = (area['sectors'] as List).single as Map<String, Object?>;
    expect(sector['name'], 'Velká stěna');
    expect((sector['routes'] as List), hasLength(2));

    // One skála page (8002) was not fetched — only a note, not an error.
    expect(result.validation.errors, isEmpty);
  });

  test('manifest survives reopening and records content changes', () async {
    await snapshotFromFixtures();

    final reopened = await Snapshot.open(tempDir.path);
    expect(reopened.entries, hasLength(3));
    expect(reopened.find('sektor', 9001)?.url, contains('skaly-sektor-9001'));

    final changed = await reopened.store(
      kind: 'sektor',
      id: 9001,
      url: 'https://www.horosvaz.cz/skaly-sektor-9001/',
      body: '<html>new content</html>',
      sha256: 'different-hash',
      fetchedAt: DateTime.utc(2026, 7, 13),
    );
    expect(changed, isTrue);
    expect(reopened.entries, hasLength(3), reason: 'upsert, not append');
  });

  test('report summarizes counts and validation', () async {
    final snapshot = await snapshotFromFixtures();
    final result = await buildCatalogFromSnapshot(snapshot, version: 3);
    final report = buildReport(result);

    expect(report, contains('areas: 1'));
    expect(report, contains('routes: 2'));
    expect(report, contains('PASSED'));
  });
}
