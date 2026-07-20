import 'package:flutter/foundation.dart';

/// Public profile data of the signed-in user. [role] is granted
/// server-side (see migration 00002); the client only mirrors it to show
/// or hide privileged UI — enforcement lives in RLS.
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String displayName;
  final String role;

  bool get isAdmin => role == 'admin';
}

/// Access to the user's own profile row.
abstract interface class ProfileRepository {
  Future<UserProfile?> getOwnProfile();

  Future<void> setDisplayName(String displayName);
}
