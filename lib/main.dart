import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_access_config.dart';
import 'design_system/nursemate_theme.dart';
import 'screens/app_lock_screen.dart';
import 'screens/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final isUnlocked = preferences.getBool(nurseMateUnlockedKey) ?? false;

  runApp(NurseMateApp(initiallyUnlocked: isUnlocked, preferences: preferences));
}

class NurseMateApp extends StatefulWidget {
  const NurseMateApp({
    super.key,
    this.initiallyUnlocked = false,
    this.preferences,
  });

  /// 기존 화면을 독립적으로 검사할 때만 사용하는 초기 상태입니다.
  final bool initiallyUnlocked;
  final SharedPreferences? preferences;

  @override
  State<NurseMateApp> createState() => _NurseMateAppState();
}

class _NurseMateAppState extends State<NurseMateApp> {
  late bool _isUnlocked;

  @override
  void initState() {
    super.initState();
    _isUnlocked = widget.initiallyUnlocked;
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NurseMate',
      theme: NurseMateTheme.light(),
      home: _isUnlocked
          ? const MainMenuScreen()
          : AppLockScreen(onUnlocked: _unlock),
    );
  }
}
