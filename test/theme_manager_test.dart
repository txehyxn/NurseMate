import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/config/app_access_config.dart';
import 'package:nursemate/main.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:nursemate/services/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('system, light, dark 모드를 저장하고 다시 불러온다', () async {
    final preferences = await SharedPreferences.getInstance();
    final manager = ThemeManager(preferences: preferences);

    expect(manager.themeMode, ThemeMode.system);

    await manager.setThemeMode(ThemeMode.light);
    expect(manager.themeMode, ThemeMode.light);
    expect(preferences.getString(nurseMateThemeModeKey), 'light');

    await manager.setThemeMode(ThemeMode.dark);
    expect(manager.themeMode, ThemeMode.dark);
    expect(preferences.getString(nurseMateThemeModeKey), 'dark');

    final restored = ThemeManager(preferences: preferences);
    expect(restored.themeMode, ThemeMode.dark);

    await restored.setThemeMode(ThemeMode.system);
    expect(preferences.getString(nurseMateThemeModeKey), 'system');

    manager.dispose();
    restored.dispose();
  });

  testWidgets('홈의 토글로 즉시 다크모드를 적용하고 저장한다', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      nurseMateUnlockedKey: true,
      nurseMateThemeModeKey: 'light',
    });
    final preferences = await SharedPreferences.getInstance();
    final manager = ThemeManager(preferences: preferences);
    addTearDown(manager.dispose);

    await tester.pumpWidget(
      NurseMateApp(
        initiallyUnlocked: true,
        preferences: preferences,
        themeManager: manager,
      ),
    );
    await tester.pump();

    final toggle = find.byKey(const Key('themeToggleButton'));
    expect(toggle, findsOneWidget);
    expect(
      find.descendant(of: toggle, matching: find.byType(AnimatedSwitcher)),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(manager.themeMode, ThemeMode.dark);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(preferences.getString(nurseMateThemeModeKey), 'dark');
    expect(
      Theme.of(tester.element(find.byType(MainMenuScreen))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('저장된 다크모드를 앱 시작 시 복원한다', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      nurseMateUnlockedKey: true,
      nurseMateThemeModeKey: 'dark',
    });
    final preferences = await SharedPreferences.getInstance();
    final manager = ThemeManager(preferences: preferences);
    addTearDown(manager.dispose);

    await tester.pumpWidget(
      NurseMateApp(
        initiallyUnlocked: true,
        preferences: preferences,
        themeManager: manager,
      ),
    );
    await tester.pump();

    expect(manager.themeMode, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(MainMenuScreen))).brightness,
      Brightness.dark,
    );
  });
}
