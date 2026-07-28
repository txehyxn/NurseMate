import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_access_config.dart';
import 'screens/app_lock_screen.dart';
import 'screens/infusion_calculator_screen.dart';

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
    const navy = Color(0xFF17324D);
    const blue = Color(0xFF2166D1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NurseMate',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
          titleLarge: TextStyle(
            color: navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          titleMedium: TextStyle(color: navy, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: Color(0xFF344B60), height: 1.45),
          bodyMedium: TextStyle(color: Color(0xFF5B6F82), height: 1.45),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: blue, width: 2),
          ),
          errorMaxLines: 2,
        ),
      ),
      home: _isUnlocked
          ? const InfusionCalculatorScreen()
          : AppLockScreen(onUnlocked: _unlock),
    );
  }
}
