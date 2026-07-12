import 'dart:math';

final _random = Random();

/// Generates a locally unique ID (creation time + random suffix). Good
/// enough for on-device records; a future backend can keep these as client
/// IDs or map them to server IDs during sync.
String newUniqueId() {
  final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final suffix = _random.nextInt(1 << 32).toRadixString(36);
  return '$micros-$suffix';
}
