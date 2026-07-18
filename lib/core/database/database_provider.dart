import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crux_database.dart';

/// Provides the app-wide Drift database.
///
/// Overridden in `bootstrap()` with the real on-device database and in
/// tests with an in-memory one; reading it without an override is a
/// programming error.
final databaseProvider = Provider<CruxDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden in bootstrap()',
  );
});
