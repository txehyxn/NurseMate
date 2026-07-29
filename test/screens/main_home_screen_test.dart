import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/models/duty_type.dart';
import 'package:nursemate/models/dday_setting.dart';
import 'package:nursemate/repositories/duty_repository.dart';
import 'package:nursemate/screens/appearance_screen.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:nursemate/services/dday_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('리뉴얼 홈의 주요 영역과 기존 기능 메뉴를 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(
          dutyRepository: _EmptyDutyRepository(),
          initialDutyMonth: DateTime(2025, 7),
          dutyToday: DateTime(2025, 7, 16),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('NurseMate'), findsOneWidget);
    expect(find.text('간호사의 하루를 더 쉽게'), findsOneWidget);
    expect(find.text('듀티표'), findsOneWidget);
    expect(find.text('2025년 7월'), findsOneWidget);
    expect(find.text('주요 기능'), findsOneWidget);

    expect(find.byKey(const Key('infusionCalculatorMenu')), findsOneWidget);
    expect(find.byKey(const Key('drainagePatternMenu')), findsOneWidget);
    expect(find.byKey(const Key('dutyChecklistMenu')), findsOneWidget);
    expect(find.byKey(const Key('drugSearchMenu')), findsOneWidget);
    expect(find.byKey(const Key('diseaseSearchMenu')), findsOneWidget);
    expect(find.byKey(const Key('memoMenu')), findsOneWidget);

    expect(find.text('빠른 계산'), findsOneWidget);
    expect(find.text('D-Day'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('계산'), findsOneWidget);
    expect(find.text('기록'), findsOneWidget);
    expect(find.text('지식'), findsOneWidget);
    expect(find.text('마이'), findsOneWidget);
  });

  testWidgets('배액양상 메뉴는 배액 양상 화면으로 연결한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MainMenuScreen(dutyRepository: _EmptyDutyRepository())),
    );

    final drainage = find.byKey(const Key('drainagePatternMenu'));
    final action = tester.widget<InkWell>(
      find.descendant(of: drainage, matching: find.byType(InkWell)),
    );
    action.onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(AppearanceScreen), findsOneWidget);
    expect(find.text('배액 양상'), findsOneWidget);
    expect(find.text('배액관 양상'), findsNWidgets(2));
  });

  testWidgets('모바일에서도 주요 기능은 3열 2행이고 빠른 계산과 D-Day가 같은 줄이다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(490, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(
          dutyRepository: _EmptyDutyRepository(),
          initialDutyMonth: DateTime(2025, 7),
          dutyToday: DateTime(2025, 7, 16),
        ),
      ),
    );
    await tester.pump();

    final first = tester.getTopLeft(
      find.byKey(const Key('infusionCalculatorMenu')),
    );
    final second = tester.getTopLeft(
      find.byKey(const Key('drainagePatternMenu')),
    );
    final third = tester.getTopLeft(find.byKey(const Key('dutyChecklistMenu')));
    final fourth = tester.getTopLeft(find.byKey(const Key('drugSearchMenu')));

    expect(second.dy, closeTo(first.dy, 0.1));
    expect(third.dy, closeTo(first.dy, 0.1));
    expect(first.dx, lessThan(second.dx));
    expect(second.dx, lessThan(third.dx));
    expect(fourth.dy, greaterThan(first.dy));

    final quick = tester.getTopLeft(find.text('빠른 계산'));
    final dDay = tester.getTopLeft(find.text('D-Day'));
    expect(dDay.dy, closeTo(quick.dy, 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('넓은 웹 화면에서 하단 내비게이션이 본문을 가리지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1910, 904));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(
          dutyRepository: _EmptyDutyRepository(),
          initialDutyMonth: DateTime(2025, 7),
          dutyToday: DateTime(2025, 7, 16),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('NurseMate').hitTestable(), findsOneWidget);
    expect(find.text('듀티표').hitTestable(), findsOneWidget);

    final navigationRect = tester.getRect(
      find.byKey(const Key('homeBottomNavigation')),
    );
    expect(navigationRect.height, 76);
    expect(navigationRect.bottom, closeTo(904, 0.1));
    expect(navigationRect.top, greaterThan(800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('저장된 D-Day를 홈에 표시하고 설정 저장 후 즉시 갱신한다', (tester) async {
    SharedPreferences.setMockInitialValues({
      ddayTitleKey: '입사 1주년',
      ddayDateKey: DateTime(2025, 7, 11).toIso8601String(),
      ddayCalculationModeKey: DDayCalculationMode.countdown.name,
      ddayCardColorKey: DDayCardColor.orange.name,
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(const Size(490, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(
          dutyRepository: _EmptyDutyRepository(),
          dDaySettingsService: DDaySettingsService(preferences),
          dDayToday: DateTime(2025, 7, 1),
          initialDDaySetting: DDaySetting(
            title: '입사 1주년',
            date: DateTime(2025, 7, 11),
            calculationMode: DDayCalculationMode.countdown,
            cardColor: DDayCardColor.orange,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('D-10'), findsOneWidget);
    expect(find.textContaining('입사 1주년'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('ddayHomeCard')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ddayHomeCard')));
    await tester.pumpAndSettle();
    expect(find.text('D-Day 설정'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '프리셉터 종료');
    await tester.tap(find.byKey(const Key('ddayMode-countUp')));
    await tester.tap(find.byKey(const Key('ddayColor-green')));
    await tester.tap(find.byKey(const Key('ddaySaveButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('프리셉터 종료'), findsOneWidget);
    expect(find.text('D+10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _EmptyDutyRepository implements DutyRepository {
  @override
  Future<void> delete(DateTime date) async {}

  @override
  Future<Map<String, DutyType>> getForMonth(DateTime month) async => const {};

  @override
  Future<void> save(DateTime date, DutyType type) async {}
}
