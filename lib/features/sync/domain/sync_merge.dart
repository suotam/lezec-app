import 'package:flutter/foundation.dart';

/// Outcome of a two-way merge: rows the local database must adopt and
/// rows that must be pushed to the backend.
@immutable
class MergeResult<T> {
  const MergeResult({required this.toApplyLocally, required this.toPush});

  final List<T> toApplyLocally;
  final List<T> toPush;
}

/// Last-write-wins merge of two row sets keyed by [keyOf].
///
/// Rows existing on one side only travel to the other; rows existing on
/// both sides go to whichever direction the newer [updatedAtOf] points.
/// Equal timestamps mean "in sync" and produce no work. Deletions are
/// ordinary rows with a tombstone flag, so they win like any other write.
MergeResult<T> mergeByKey<T>({
  required Iterable<T> local,
  required Iterable<T> remote,
  required String Function(T row) keyOf,
  required DateTime Function(T row) updatedAtOf,
}) {
  final localByKey = {for (final row in local) keyOf(row): row};
  final remoteByKey = {for (final row in remote) keyOf(row): row};
  final toApply = <T>[];
  final toPush = <T>[];

  for (final key in {...localByKey.keys, ...remoteByKey.keys}) {
    final localRow = localByKey[key];
    final remoteRow = remoteByKey[key];
    if (localRow == null) {
      toApply.add(remoteRow as T);
    } else if (remoteRow == null) {
      toPush.add(localRow);
    } else {
      final comparison = updatedAtOf(
        localRow,
      ).compareTo(updatedAtOf(remoteRow));
      if (comparison > 0) {
        toPush.add(localRow);
      } else if (comparison < 0) {
        toApply.add(remoteRow);
      }
    }
  }
  return MergeResult(toApplyLocally: toApply, toPush: toPush);
}
