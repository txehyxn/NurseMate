import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import 'auth_session_service.dart';
import 'auth_service.dart';

abstract final class CloudService {
  static SupabaseClient? _client;
  static AuthSessionService? _sessionService;

  static SupabaseClient? get client => _client;

  static bool get isConfigured => _client != null;

  static AuthService get auth => _client == null
      ? const UnavailableAuthService()
      : SupabaseAuthService(_client!, _sessionService!);

  static Future<void> initialize({
    required AuthSessionService sessionService,
    bool preserveRecoverySession = false,
  }) async {
    if (!SupabaseConfig.isConfigured) return;
    _sessionService = sessionService;
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    _client = Supabase.instance.client;
    if (!preserveRecoverySession &&
        !sessionService.shouldRememberLogin &&
        _client!.auth.currentSession != null) {
      await _client!.auth.signOut(scope: SignOutScope.local);
    }
  }
}
