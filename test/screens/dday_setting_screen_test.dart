import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/models/dday_setting.dart';
import 'package:nursemate/screens/dday_setting_screen.dart';
import 'package:nursemate/services/dday_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final today = DateTime(2025, 7, 1);

  testWidgets('저장된 D-Day 설정을 자동으로 불러와 미리보기에 표시한다', (tester) async {
    SharedPreferences.setMockInitialValues({
      ddayTitleKey: '신규 간호사 100일',
      ddayDateKey: DateTime(2025, 6, 21).toIso8601String(),
      ddayCalculationModeKey: DDayCalculationMode.countUp.name,
      ddayCardColorKey: DDayCardColor.green.name,
    });

    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: DDaySettingScreen(today: today),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('D-Day 설정'), findsOneWidget);
    expect(find.text('2025년 6월 21일'), findsOneWidget);
    expect(find.text('D+Day'), findsNWidgets(2));
    expect(find.text('D+10'), findsOneWidget);
    expect(find.text('신규 간호사 100일'), findsOneWidget);
    expect(find.byKey(const Key('ddayColor-green')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('입력값이 미리보기에 반영되고 SharedPreferences에 저장된다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = DDaySettingsService(preferences);

    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: DDaySettingScreen(settingsService: service, today: today),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '간호사 시험');
    await tester.tap(find.byKey(const Key('ddayMode-countUp')));
    await tester.tap(find.byKey(const Key('ddayColor-blue')));
    await tester.pumpAndSettle();

    expect(find.text('간호사 시험'), findsOneWidget);
    expect(find.text('D+120'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('ddayDateSelector')));
    await tester.tap(find.byKey(const Key('ddayDateSelector')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ddaySaveButton')));
    await tester.pumpAndSettle();

    expect(preferences.getString(ddayTitleKey), '간호사 시험');
    expect(
      preferences.getString(ddayCalculationModeKey),
      DDayCalculationMode.countUp.name,
    );
    expect(preferences.getString(ddayCardColorKey), DDayCardColor.blue.name);
    expect(preferences.getString(ddayDateKey), isNotNull);
    expect(tester.takeException(), isNull);
  });
}
