import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_access_config.dart';
import 'design_system/nursemate_theme.dart';
import 'models/app_user.dart';
import 'screens/app_lock_screen.dart';
import 'screens/main_menu_screen.dart';
import 'services/auth_service.dart';
import 'services/cloud_service.dart';
import 'services/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await CloudService.initialize();
  } on Object {
    // Cloud configuration must never prevent offline access to NurseMate.
  }
  final preferences = await SharedPreferences.getInstance();
  final isUnlocked = preferences.getBool(nurseMateUnlockedKey) ?? false;
  final themeManager = ThemeManager(preferences: preferences);

  runApp(
    NurseMateApp(
      initiallyUnlocked: isUnlocked,
      preferences: preferences,
      themeManager: themeManager,
    ),
  );
}

class NurseMateApp extends StatefulWidget {
  const NurseMateApp({
    super.key,
    this.initiallyUnlocked = false,
    this.preferences,
    this.themeManager,
  });

  /// 기존 화면을 독립적으로 검사할 때만 사용하는 초기 상태입니다.
  final bool initiallyUnlocked;
  final SharedPreferences? preferences;
  final ThemeManager? themeManager;

  @override
  State<NurseMateApp> createState() => _NurseMateAppState();
}

class _NurseMateAppState extends State<NurseMateApp> {
  late bool _isUnlocked;
  late final AuthService _authService;
  StreamSubscription<AppUser?>? _authSubscription;
  AppUser? _currentUser;
  late final ThemeManager _themeManager;
  late final bool _ownsThemeManager;

  @override
  void initState() {
    super.initState();
    _isUnlocked = widget.initiallyUnlocked;
    _ownsThemeManager = widget.themeManager == null;
    _themeManager =
        widget.themeManager ?? ThemeManager(preferences: widget.preferences);
    _authService = CloudService.auth;
    _currentUser = _authService.currentUser;
    _authSubscription = _authService.userChanges.listen(
      (user) {
        if (!mounted || user?.id == _currentUser?.id) return;
        setState(() => _currentUser = user);
      },
      onError: (_, _) {
        // Offline token refresh failures must not crash the app.
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    if (_ownsThemeManager) {
      _themeManager.dispose();
    }
    super.dispose();
  }

  Future<void> _unlock() async {
    final preferences =
        widget.preferences ?? await SharedPreferences.getInstance();
    final didSave = await preferences.setBool(nurseMateUnlockedKey, true);
    if (!didSave) {
      throw StateError('잠금 해제 상태를 저장하지 못했습니다.');
    }
    if (!mounted) return;

    setState(() {
      _isUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeManager,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NurseMate',
        theme: NurseMateTheme.light(),
        darkTheme: NurseMateTheme.dark(),
        themeMode: _themeManager.themeMode,
        themeAnimationDuration: const Duration(milliseconds: 250),
        themeAnimationCurve: Curves.easeOutCubic,
        home: _isUnlocked
            ? MainMenuScreen(
                key: ValueKey(_currentUser?.id ?? 'guest'),
                authService: _authService,
                themeManager: _themeManager,
              )
            : AppLockScreen(onUnlocked: _unlock),
      ),
    );
  }
}
