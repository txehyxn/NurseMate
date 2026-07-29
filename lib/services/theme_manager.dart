import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const nurseMateThemeModeKey = 'nursemate_theme_mode';

class ThemeManager extends ChangeNotifier {
  ThemeManager({SharedPreferences? preferences})
    : _preferences = preferences,
      _themeMode = _readMode(preferences) {
    if (preferences == null) {
      _load();
    }
  }

  SharedPreferences? _preferences;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final preferences = _preferences ??= await SharedPreferences.getInstance();
    await preferences.setString(nurseMateThemeModeKey, mode.name);
  }

  Future<void> toggle(Brightness currentBrightness) {
    return setThemeMode(
      currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
    final savedMode = _readMode(preferences);
    if (_themeMode == savedMode) return;
    _themeMode = savedMode;
    notifyListeners();
  }

  static ThemeMode _readMode(SharedPreferences? preferences) {
    final savedName = preferences?.getString(nurseMateThemeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == savedName,
      orElse: () => ThemeMode.system,
    );
  }
}
