abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured {
    final uri = Uri.tryParse(url.trim());
    return isResolvedValue(url) &&
        isResolvedValue(publishableKey) &&
        uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty;
  }

  static bool isResolvedValue(String value) {
    final normalized = value.trim();
    return normalized.isNotEmpty &&
        !normalized.startsWith(r'$') &&
        !normalized.startsWith('%') &&
        !normalized.contains('YOUR_');
  }
}
