import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase project coordinates. The publishable key is public by design
/// (Row-Level Security protects all data), so defaults are baked in for
/// one-command tester builds; `--dart-define` overrides both for other
/// environments. The `service_role` key must never appear here.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qnidhwymflzulkxgavlj.supabase.co',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_3-TZKzJaTrHoZXu05lO3Aw_kdQu1ssE',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

/// The initialized Supabase client, or null when the backend is not
/// configured (e.g. in tests). Overridden in `bootstrap()`.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);
