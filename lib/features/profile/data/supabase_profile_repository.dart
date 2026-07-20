import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_profile.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<UserProfile?> getOwnProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return UserProfile(
      id: row['id'] as String,
      displayName: (row['display_name'] as String?) ?? '',
      role: (row['role'] as String?) ?? 'user',
    );
  }

  @override
  Future<void> setDisplayName(String displayName) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('profiles')
        .update({'display_name': displayName})
        .eq('id', userId);
  }
}
