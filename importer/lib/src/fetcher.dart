/// Rate-limited, retrying HTTP fetcher for the ČHS site.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'snapshot.dart';

const chsBaseUrl = 'https://www.horosvaz.cz';

/// Landing page of the rock database; links every region and oblast.
const chsDbIndexUrl = '$chsBaseUrl/databaze-skal-cr/';

String regionUrl(int id) => '$chsBaseUrl/skaly-region-$id/';
String sektorUrl(int id) => '$chsBaseUrl/skaly-sektor-$id/';
String sektorMapUrl(int id) => '$chsBaseUrl/skaly-sektor-$id/?action=map-code';
String oblastUrl(int id) => '$chsBaseUrl/skaly-oblast-$id/';
String skalaUrl(int id) => '$chsBaseUrl/skaly-skala-$id/';

class FetchException implements Exception {
  FetchException(this.message);
  final String message;

  @override
  String toString() => 'FetchException: $message';
}

class ChsFetcher {
  ChsFetcher({
    http.Client? client,
    this.delay = const Duration(seconds: 2),
    this.maxAttempts = 3,
    void Function(String message)? log,
  })  : _client = client ?? http.Client(),
        _log = log ?? print;

  /// Pause between requests. The ČHS site is a volunteer-run resource;
  /// keep this at seconds, not milliseconds.
  final Duration delay;

  /// Manifest is flushed every N stored pages during bulk crawls; on an
  /// interrupted run, at most this many pages are refetched.
  static const _manifestFlushInterval = 25;

  final int maxAttempts;
  final http.Client _client;
  final void Function(String message) _log;
  DateTime? _lastRequest;
  int _storedSinceFlush = 0;

  // ASCII only — HTTP header values must not contain non-ASCII bytes.
  static const _userAgent =
      'CruxCZ-chs-importer/0.1 (nekomercni import pro mobilni aplikaci)';

  Future<String> fetch(String url) async {
    for (var attempt = 1; ; attempt++) {
      await _throttle();
      try {
        final response = await _client
            .get(Uri.parse(url), headers: {'User-Agent': _userAgent})
            .timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          return utf8.decode(response.bodyBytes);
        }
        if (response.statusCode >= 500 && attempt < maxAttempts) {
          _log('  HTTP ${response.statusCode} for $url — retrying');
          continue;
        }
        throw FetchException('HTTP ${response.statusCode} for $url');
      } on IOException catch (e) {
        if (attempt >= maxAttempts) {
          throw FetchException('$url failed after $attempt attempts: $e');
        }
        _log('  $e — retrying $url');
      }
    }
  }

  /// Fetches [url] into [snapshot] unless an entry already exists (pass
  /// [force] to refetch and detect content changes).
  Future<void> fetchInto(
    Snapshot snapshot, {
    required String kind,
    required int id,
    required String url,
    bool force = false,
  }) async {
    if (!force && snapshot.find(kind, id) != null) {
      _log('  $kind-$id already in snapshot, skipping');
      return;
    }
    final body = await fetch(url);
    _storedSinceFlush++;
    final flush = _storedSinceFlush >= _manifestFlushInterval;
    if (flush) _storedSinceFlush = 0;
    final changed = await snapshot.store(
      kind: kind,
      id: id,
      url: url,
      body: body,
      sha256: sha256.convert(utf8.encode(body)).toString(),
      fetchedAt: DateTime.now().toUtc(),
      flush: flush,
    );
    _log('  fetched $kind-$id${changed ? ' (changed since last fetch)' : ''}');
  }

  Future<void> _throttle() async {
    final last = _lastRequest;
    if (last != null) {
      final wait = delay - DateTime.now().difference(last);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
    }
    _lastRequest = DateTime.now();
  }

  void close() => _client.close();
}
