import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import 'auth_service.dart';

abstract final class CloudService {
  static SupabaseClient? _client;

  static SupabaseClient? get client => _client;

  static bool get isConfigured => _client != null;

  static AuthService get auth => _client == null
      ? const UnavailableAuthService()
      : SupabaseAuthService(_client!);

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    _client = Supabase.instance.client;
  }
}
