import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/supabase_config.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/supabase_profile_repository.dart';
import '../domain/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseProfileRepository(client);
});

/// The signed-in user's profile (display name, role); null when signed
/// out or without a backend. Re-fetches on login/logout.
final ownProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final user = ref.watch(currentUserProvider).value;
  if (repository == null || user == null) return null;
  return repository.getOwnProfile();
});

/// Areas the signed-in user manages (empty set for regular users; null
/// when signed out or without a backend).
final managedAreaIdsProvider = FutureProvider<Set<String>?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider).value;
  if (client == null || user == null) return null;
  final rows = await client
      .from('area_managers')
      .select('area_id')
      .eq('user_id', user.id);
  return {for (final row in rows) row['area_id'] as String};
});

/// Whether the signed-in user may manage content of [areaId]
/// (admin or assigned area manager). Mirrors the server-side RLS rule.
final canManageAreaProvider = Provider.family<bool, String>((ref, areaId) {
  final profile = ref.watch(ownProfileProvider).value;
  if (profile?.isAdmin ?? false) return true;
  final managed = ref.watch(managedAreaIdsProvider).value;
  return managed?.contains(areaId) ?? false;
});

/// The name to attach to public content (comments): the display name,
/// with the email's local part as a fallback.
final authorNameProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return null;
  final profile = ref.watch(ownProfileProvider).value;
  final displayName = profile?.displayName.trim() ?? '';
  if (displayName.isNotEmpty) return displayName;
  final email = user.email;
  return email.contains('@') ? email.split('@').first : email;
});
