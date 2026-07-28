import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

abstract interface class AuthService {
  AppUser? get currentUser;

  Stream<AppUser?> get userChanges;

  bool get isAvailable;

  Future<void> signIn({required String email, required String password});

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  @override
  bool get isAvailable => true;

  @override
  AppUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> get userChanges => _client.auth.onAuthStateChange.map(
    (data) => _mapUser(data.session?.user),
  );

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
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
  Future<void> signOut() => _client.auth.signOut();

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
  Future<void> signIn({required String email, required String password}) {
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
  Future<void> signOut() async {}
}
