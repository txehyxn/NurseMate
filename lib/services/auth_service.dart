import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/app_user.dart';
import 'auth_session_service.dart';

abstract interface class AuthService {
  AppUser? get currentUser;

  Stream<AppUser?> get userChanges;

  bool get isAvailable;

  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberLogin,
  });

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updatePassword(String password);

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client, this._sessionService);

  final SupabaseClient _client;
  final AuthSessionService _sessionService;

  @override
  bool get isAvailable => true;

  @override
  AppUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> get userChanges => _client.auth.onAuthStateChange.map(
    (data) => _mapUser(data.session?.user),
  );

  @override
  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberLogin,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    await _sessionService.setRememberLogin(rememberLogin);
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': displayName.trim()},
    );
    return response.session != null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: SupabaseConfig.passwordResetRedirectUrl,
      );

  @override
  Future<void> updatePassword(String password) =>
      _client.auth.updateUser(UserAttributes(password: password));

  @override
  Future<void> signOut() async {
    await _sessionService.setRememberLogin(false);
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    final displayName = user.userMetadata?['display_name'] as String?;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: displayName?.trim().isEmpty == true ? null : displayName,
    );
  }
}

class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  @override
  bool get isAvailable => false;

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> get userChanges => const Stream.empty();

  @override
  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberLogin,
  }) {
    throw StateError('클라우드 로그인이 아직 연결되지 않았습니다.');
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    throw StateError('클라우드 회원가입이 아직 연결되지 않았습니다.');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    throw StateError('클라우드 비밀번호 재설정이 아직 연결되지 않았습니다.');
  }

  @override
  Future<void> updatePassword(String password) {
    throw StateError('클라우드 비밀번호 재설정이 아직 연결되지 않았습니다.');
  }

  @override
  Future<void> signOut() async {}
}
