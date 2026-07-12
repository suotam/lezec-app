/// On-disk snapshot of fetched ČHS pages.
///
/// A snapshot directory contains the raw HTML files plus `manifest.json`
/// recording, for every file, the source URL, fetch time and content
/// hash. `build` works only from snapshots — never from the network — so
/// imports are reproducible and re-runs never break half-fetched data
/// (the manifest is written atomically after each page).
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class SnapshotEntry {
  SnapshotEntry({
    required this.kind,
    required this.id,
    required this.url,
    required this.file,
    required this.fetchedAt,
    required this.sha256,
  });

  factory SnapshotEntry.fromJson(Map<String, Object?> json) => SnapshotEntry(
        kind: json['kind'] as String,
        id: json['id'] as int,
        url: json['url'] as String,
        file: json['file'] as String,
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        sha256: json['sha256'] as String,
      );

  /// `oblast`, `sektor`, `sektor-map` or `skala`.
  final String kind;
  final int id;
  final String url;
  final String file;
  final DateTime fetchedAt;
  final String sha256;

  Map<String, Object?> toJson() => {
        'kind': kind,
        'id': id,
        'url': url,
        'file': file,
        'fetchedAt': fetchedAt.toIso8601String(),
        'sha256': sha256,
      };
}

class Snapshot {
  Snapshot(this.directory, {List<SnapshotEntry>? entries})
      : entries = entries ?? [];

  final Directory directory;
  final List<SnapshotEntry> entries;

  File get _manifestFile => File(p.join(directory.path, 'manifest.json'));

  static Future<Snapshot> open(String path) async {
    final directory = Directory(path);
    final manifest = File(p.join(path, 'manifest.json'));
    if (!manifest.existsSync()) return Snapshot(directory);
    final decoded =
        json.decode(await manifest.readAsString()) as Map<String, Object?>;
    return Snapshot(
      directory,
      entries: [
        for (final entry in decoded['entries'] as List)
          SnapshotEntry.fromJson(entry as Map<String, Object?>),
      ],
    );
  }

  SnapshotEntry? find(String kind, int id) {
    for (final entry in entries) {
      if (entry.kind == kind && entry.id == id) return entry;
    }
    return null;
  }

  Future<String> readEntry(SnapshotEntry entry) =>
      File(p.join(directory.path, entry.file)).readAsString();

  /// Stores [body] and upserts the manifest entry. Returns whether the
  /// content changed compared to a previous fetch of the same page.
  Future<bool> store({
    required String kind,
    required int id,
    required String url,
    required String body,
    required String sha256,
    required DateTime fetchedAt,
  }) async {
    directory.createSync(recursive: true);
    final file = '$kind-$id.html';
    await File(p.join(directory.path, file)).writeAsString(body);

    final previous = find(kind, id);
    final changed = previous != null && previous.sha256 != sha256;
    entries.removeWhere((e) => e.kind == kind && e.id == id);
    entries.add(
      SnapshotEntry(
        kind: kind,
        id: id,
        url: url,
        file: file,
        fetchedAt: fetchedAt,
        sha256: sha256,
      ),
    );
    await _writeManifest();
    return changed;
  }

  Future<void> _writeManifest() async {
    final tmp = File('${_manifestFile.path}.tmp');
    await tmp.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'updatedAt': DateTime.now().toIso8601String(),
        'entries': [for (final entry in entries) entry.toJson()],
      }),
    );
    await tmp.rename(_manifestFile.path);
  }
}
