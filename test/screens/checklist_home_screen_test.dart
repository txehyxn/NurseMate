import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_design_system.dart';
import 'package:nursemate/models/duty_type.dart';
import 'package:nursemate/repositories/duty_repository.dart';
import 'package:nursemate/screens/checklist_home_screen.dart';
import 'package:nursemate/screens/day_checklist_screen.dart';
import 'package:nursemate/screens/evening_checklist_screen.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:nursemate/screens/night_checklist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('신규간호사 체크리스트의 주요 영역과 근무 카드 3개를 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const ChecklistHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('신규간호사 체크리스트'), findsOneWidget);
    expect(find.text('근무에 필요한 항목을 체크해보세요!'), findsOneWidget);
    expect(find.byKey(const Key('checklistNurseIllustration')), findsOneWidget);
    expect(find.byKey(const Key('dayChecklistCard')), findsOneWidget);
    expect(find.byKey(const Key('eveningChecklistCard')), findsOneWidget);
    expect(find.byKey(const Key('nightChecklistCard')), findsOneWidget);
    expect(find.text('파이널 라운딩 1시'), findsOneWidget);
    expect(find.text('파이널 라운딩 8PM'), findsOneWidget);
    expect(find.text('파이널 라운딩 5AM'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('checklistTipCard')));
    await tester.pumpAndSettle();
    expect(find.text('TIP'), findsOneWidget);
    expect(find.text('체크한 항목은 자동 저장됩니다.'), findsOneWidget);
    expect(find.byKey(const Key('checklistTipIllustration')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('DAY 카드는 day_checklist_screen으로 이동한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const ChecklistHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await _invokeCard(tester, find.byKey(const Key('dayChecklistCard')));
    await tester.pumpAndSettle();

    expect(find.byType(DayChecklistScreen), findsOneWidget);
    expect(find.text('DAY 체크리스트'), findsOneWidget);
  });

  testWidgets('EVENING 카드는 evening_checklist_screen으로 이동한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const ChecklistHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await _invokeCard(tester, find.byKey(const Key('eveningChecklistCard')));
    await tester.pumpAndSettle();

    expect(find.byType(EveningChecklistScreen), findsOneWidget);
    expect(find.text('EVENING 체크리스트'), findsOneWidget);
  });

  testWidgets('NIGHT 카드는 night_checklist_screen으로 이동한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const ChecklistHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await _invokeCard(tester, find.byKey(const Key('nightChecklistCard')));
    await tester.pumpAndSettle();

    expect(find.byType(NightChecklistScreen), findsOneWidget);
    expect(find.text('NIGHT 체크리스트'), findsOneWidget);
  });

  testWidgets('홈의 듀티별 체크리스트 메뉴에서 메인 화면을 연다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: MainMenuScreen(dutyRepository: _EmptyDutyRepository()),
      ),
    );
    await tester.pump();

    final menu = find.byKey(const Key('dutyChecklistMenu'));
    await tester.ensureVisible(menu);
    await _invokeCard(tester, menu);
    await tester.pumpAndSettle();

    expect(find.byType(ChecklistHomeScreen), findsOneWidget);
    expect(find.text('신규간호사 체크리스트'), findsOneWidget);
  });
}

Future<void> _invokeCard(WidgetTester tester, Finder ancestor) async {
  final inkWell = tester.widget<InkWell>(
    find.descendant(of: ancestor, matching: find.byType(InkWell)).first,
  );
  inkWell.onTap!();
  await tester.pump();
}

class _EmptyDutyRepository implements DutyRepository {
  @override
  Future<void> delete(DateTime date) async {}

  @override
  Future<Map<String, DutyType>> getForMonth(DateTime month) async => const {};

  @override
  Future<void> save(DateTime date, DutyType type) async {}
}
