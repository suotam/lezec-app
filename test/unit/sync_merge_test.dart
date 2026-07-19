import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/sync/domain/sync_merge.dart';

typedef TestRow = ({String key, DateTime updatedAt, String payload});

TestRow row(String key, int minute, [String payload = '']) => (
  key: key,
  updatedAt: DateTime.utc(2026, 1, 1, 12, minute),
  payload: payload,
);

MergeResult<TestRow> merge(List<TestRow> local, List<TestRow> remote) =>
    mergeByKey(
      local: local,
      remote: remote,
      keyOf: (r) => r.key,
      updatedAtOf: (r) => r.updatedAt,
    );

void main() {
  group('mergeByKey', () {
    test('local-only rows are pushed, remote-only rows are applied', () {
      final result = merge([row('a', 1)], [row('b', 2)]);
      expect(result.toPush.map((r) => r.key), ['a']);
      expect(result.toApplyLocally.map((r) => r.key), ['b']);
    });

    test('newer side wins on conflicts', () {
      final result = merge(
        [row('a', 5, 'local'), row('b', 1, 'local')],
        [row('a', 3, 'remote'), row('b', 4, 'remote')],
      );
      expect(result.toPush.single.payload, 'local');
      expect(result.toPush.single.key, 'a');
      expect(result.toApplyLocally.single.payload, 'remote');
      expect(result.toApplyLocally.single.key, 'b');
    });

    test('identical timestamps mean no work', () {
      final result = merge([row('a', 2)], [row('a', 2)]);
      expect(result.toPush, isEmpty);
      expect(result.toApplyLocally, isEmpty);
    });

    test('empty sides are handled', () {
      expect(merge([], []).toPush, isEmpty);
      expect(merge([row('a', 1)], []).toPush, hasLength(1));
      expect(merge([], [row('a', 1)]).toApplyLocally, hasLength(1));
    });
  });
}
