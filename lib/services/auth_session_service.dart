import 'package:shared_preferences/shared_preferences.dart';

const rememberLoginPreferenceKey = 'auth.remember_login';

class AuthSessionService {
  const AuthSessionService(this._preferences);

  final SharedPreferences _preferences;

  bool get shouldRememberLogin =>
      _preferences.getBool(rememberLoginPreferenceKey) ?? false;

  Future<void> setRememberLogin(bool value) =>
      _preferences.setBool(rememberLoginPreferenceKey, value);
}
