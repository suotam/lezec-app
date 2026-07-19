import 'package:flutter/foundation.dart';

/// Signed-in user as the app sees it.
@immutable
class AppUser {
  const AppUser({required this.id, required this.email});

  final String id;
  final String email;

  @override
  bool operator ==(Object other) =>
      other is AppUser && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}

/// Outcome of a sign-up attempt. When the project requires email
/// confirmation there is no session yet and the UI must say so.
@immutable
class SignUpResult {
  const SignUpResult({required this.needsEmailConfirmation});

  final bool needsEmailConfirmation;
}

/// Thrown by auth operations with a message the UI can show.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

/// Account management. An account exists only for backup/sync — the whole
/// app works without one.
abstract interface class AuthRepository {
  AppUser? get currentUser;

  /// Emits the current user immediately and then on every change.
  Stream<AppUser?> watchUser();

  Future<void> signIn({required String email, required String password});

  Future<SignUpResult> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
