import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:chs_importer/chs_importer.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand(
      'fetch',
      ArgParser()
        ..addMultiOption('oblast', help: 'ČHS oblast id(s) to fetch fully')
        ..addMultiOption('sektor', help: 'ČHS sektor id(s) to fetch')
        ..addOption('snapshot', mandatory: true, help: 'Snapshot directory')
        ..addOption(
          'delay-ms',
          defaultsTo: '2000',
          help: 'Pause between requests (be polite: >= 1000)',
        )
        ..addFlag('force', help: 'Refetch pages already in the snapshot'),
    )
    ..addCommand(
      'build',
      ArgParser()
        ..addOption('snapshot', mandatory: true, help: 'Snapshot directory')
        ..addOption('out', mandatory: true, help: 'Output catalog JSON file')
        ..addOption(
          'version',
          mandatory: true,
          help: 'Catalog version to stamp (bump on every content change)',
        ),
    )
    ..addCommand(
      'validate',
      ArgParser()..addOption('catalog', mandatory: true, help: 'Catalog JSON'),
    );

  final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    _fail('${e.message}\n\n${_usage(parser)}');
  }

  switch (results.command?.name) {
    case 'fetch':
      await _fetch(results.command!);
    case 'build':
      await _build(results.command!);
    case 'validate':
      _validate(results.command!);
    default:
      _fail(_usage(parser));
  }
}

String _usage(ArgParser parser) => '''
ČHS → Crux CZ catalog importer.

Usage:
  dart run chs_importer fetch --oblast 161 --snapshot snapshots/oblast-161
  dart run chs_importer fetch --sektor 470 --snapshot snapshots/sektor-470
  dart run chs_importer build --snapshot snapshots/sektor-470 \\
      --out out/catalog.json --version 2
  dart run chs_importer validate --catalog out/catalog.json

Commands:
${parser.commands.keys.map((c) => '  $c\n${parser.commands[c]!.usage.split('\n').map((l) => '    $l').join('\n')}').join('\n')}
''';

Future<void> _fetch(ArgResults args) async {
  final oblastIds = (args['oblast'] as List<String>).map(int.parse).toList();
  final sektorIds = (args['sektor'] as List<String>).map(int.parse).toSet();
  if (oblastIds.isEmpty && sektorIds.isEmpty) {
    _fail('fetch needs at least one --oblast or --sektor id');
  }
  final delayMs = int.parse(args['delay-ms'] as String);
  if (delayMs < 1000) {
    _fail('--delay-ms below 1000 is not allowed; be considerate of the site');
  }
  final force = args['force'] as bool;

  final snapshot = await Snapshot.open(args['snapshot'] as String);
  final fetcher = ChsFetcher(delay: Duration(milliseconds: delayMs));
  try {
    for (final oblastId in oblastIds) {
      stdout.writeln('oblast $oblastId');
      await fetcher.fetchInto(
        snapshot,
        kind: 'oblast',
        id: oblastId,
        url: oblastUrl(oblastId),
        force: force,
      );
      final entry = snapshot.find('oblast', oblastId)!;
      sektorIds.addAll(parseSektorIds(await snapshot.readEntry(entry)));
    }

    final skalaIds = <int>{};
    for (final sektorId in sektorIds) {
      stdout.writeln('sektor $sektorId');
      await fetcher.fetchInto(
        snapshot,
        kind: 'sektor',
        id: sektorId,
        url: sektorUrl(sektorId),
        force: force,
      );
      await fetcher.fetchInto(
        snapshot,
        kind: 'sektor-map',
        id: sektorId,
        url: sektorMapUrl(sektorId),
        force: force,
      );
      final entry = snapshot.find('sektor', sektorId)!;
      final sektor = parseSektorPage(
        await snapshot.readEntry(entry),
        id: sektorId,
        sourceUrl: entry.url,
        fetchedAt: entry.fetchedAt,
      );
      skalaIds.addAll(sektor.skalaIds);
    }

    for (final skalaId in skalaIds) {
      stdout.writeln('skala $skalaId');
      await fetcher.fetchInto(
        snapshot,
        kind: 'skala',
        id: skalaId,
        url: skalaUrl(skalaId),
        force: force,
      );
    }
  } finally {
    fetcher.close();
  }
  stdout.writeln(
    'done: ${snapshot.entries.length} pages in ${snapshot.directory.path}',
  );
}

Future<void> _build(ArgResults args) async {
  final snapshot = await Snapshot.open(args['snapshot'] as String);
  if (snapshot.entries.isEmpty) {
    _fail('snapshot ${snapshot.directory.path} is empty — run fetch first');
  }
  final result = await buildCatalogFromSnapshot(
    snapshot,
    version: int.parse(args['version'] as String),
  );

  final outFile = File(args['out'] as String)..parent.createSync(recursive: true);
  await outFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(result.catalog),
  );
  final reportFile = File('${outFile.path}.report.txt');
  await reportFile.writeAsString(buildReport(result));

  stdout
    ..writeln('catalog: ${outFile.path}')
    ..writeln('report:  ${reportFile.path}')
    ..write(buildReport(result));
  if (!result.validation.isValid) {
    stderr.writeln('validation FAILED — catalog must not ship');
    exitCode = 1;
  }
}

void _validate(ArgResults args) {
  final file = File(args['catalog'] as String);
  if (!file.existsSync()) _fail('${file.path} does not exist');
  final catalog =
      json.decode(file.readAsStringSync()) as Map<String, Object?>;
  final result = validateCatalog(catalog);
  for (final error in result.errors) {
    stdout.writeln('ERROR: $error');
  }
  for (final warning in result.warnings) {
    stdout.writeln('WARN:  $warning');
  }
  stdout.writeln(result.isValid ? 'VALID' : 'INVALID');
  if (!result.isValid) exitCode = 1;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(2);
}
