import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_repository.dart';

/// [AuthRepository] over Supabase email+password auth. Sessions persist
/// across app restarts (handled by supabase_flutter).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  AppUser? _toAppUser(User? user) =>
      user == null ? null : AppUser(id: user.id, email: user.email ?? '');

  @override
  AppUser? get currentUser => _toAppUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> watchUser() async* {
    yield currentUser;
    yield* _client.auth.onAuthStateChange.map(
      (state) => _toAppUser(state.session?.user),
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(
        () => _client.auth.signInWithPassword(email: email, password: password),
      );

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return SignUpResult(needsEmailConfirmation: response.session == null);
  });

  @override
  Future<void> signOut() => _guard(() => _client.auth.signOut());

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }
}

/// Used when no backend is configured (tests, stripped builds): nobody is
/// signed in and sign-in attempts fail with a clear message.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> watchUser() => Stream.value(null);

  @override
  Future<void> signIn({required String email, required String password}) =>
      throw const AuthFailure('Backend is not configured');

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) => throw const AuthFailure('Backend is not configured');

  @override
  Future<void> signOut() async {}
}
