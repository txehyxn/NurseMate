import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_design_system.dart';
import 'package:nursemate/models/duty_calendar_day.dart';
import 'package:nursemate/models/duty_schedule.dart';
import 'package:nursemate/models/duty_type.dart';
import 'package:nursemate/repositories/duty_repository.dart';
import 'package:nursemate/screens/duty_manage_screen.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:nursemate/services/duty_schedule_service.dart';
import 'package:nursemate/widgets/home/duty_calendar_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('월간 달력에 이전·현재·다음 달 날짜를 주 단위로 생성한다', () {
    final days = buildDutyCalendarDays(
      month: DateTime(2025, 7),
      duties: {'2025-07-16': DutyType.day},
    );

    expect(days, hasLength(35));
    expect(dutyDateKey(days.first.date), '2025-06-29');
    expect(dutyDateKey(days.last.date), '2025-08-02');
    expect(
      days.singleWhere((day) => dutyDateKey(day.date) == '2025-07-16').duty,
      DutyType.day,
    );
    expect(DutyType.fromStorage('day'), DutyType.day);
    expect(DutyType.fromStorage('OFF'), DutyType.off);
    expect(DutyType.fromStorage('middle'), DutyType.middle);
  });

  testWidgets('근무 선택 후 날짜를 누르면 저장되고 다시 누르면 삭제된다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final scheduleService = DutyScheduleService(
      await SharedPreferences.getInstance(),
    );
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _MemoryDutyRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: DutyManageScreen(
          repository: repository,
          initialMonth: DateTime(2025, 7),
          today: DateTime(2025, 7, 16),
          scheduleService: scheduleService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _invokeInkWell(tester, find.byKey(const Key('dutySelector_evening')));
    await _invokeInkWell(tester, find.byKey(const Key('dutyDay_2025-07-21')));
    await tester.pumpAndSettle();
    expect(find.text('2025.07.21 일정'), findsOneWidget);
    await _tapButton(tester, find.byKey(const Key('saveDutyDayButton')));
    await tester.pumpAndSettle();

    expect(repository.values['2025-07-21'], DutyType.evening);
    expect(
      tester
          .widget<DutyBadge>(
            find.descendant(
              of: find.byKey(const Key('dutyDay_2025-07-21')),
              matching: find.byType(DutyBadge),
            ),
          )
          .type,
      DutyType.evening,
    );

    await _invokeInkWell(tester, find.byKey(const Key('dutyDay_2025-07-21')));
    await tester.pumpAndSettle();
    await _tapButton(tester, find.byKey(const Key('deleteDutyDayButton')));
    await tester.pumpAndSettle();
    expect(repository.values.containsKey('2025-07-21'), isFalse);
  });

  testWidgets('월 이동과 홈 화면 즉시 반영이 동작한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final scheduleService = DutyScheduleService(
      await SharedPreferences.getInstance(),
    );
    await tester.binding.setSurfaceSize(const Size(1000, 1700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _MemoryDutyRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: MainMenuScreen(
          dutyRepository: repository,
          initialDutyMonth: DateTime(2025, 7),
          dutyToday: DateTime(2025, 7, 16),
          dutyScheduleService: scheduleService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _invokeIconButton(
      tester,
      find.byKey(const Key('nextDutyMonth')),
    );
    await tester.pumpAndSettle();
    expect(find.text('2025년 8월'), findsOneWidget);
    await _invokeIconButton(
      tester,
      find.byKey(const Key('previousDutyMonth')),
    );
    await tester.pumpAndSettle();

    tester
        .widget<FilledButton>(find.byKey(const Key('manageDutyButton')))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(find.byType(DutyManageScreen), findsOneWidget);

    await _invokeInkWell(tester, find.byKey(const Key('dutySelector_night')));
    await _invokeInkWell(tester, find.byKey(const Key('dutyDay_2025-07-24')));
    await tester.pumpAndSettle();
    await _tapButton(tester, find.byKey(const Key('saveDutyDayButton')));
    await tester.pumpAndSettle();

    final saveButton = tester.widget<NurseMatePrimaryButton>(
      find.byKey(const Key('saveDutyButton')),
    );
    saveButton.onPressed!();
    await tester.pumpAndSettle();

    final badge = tester.widget<DutyBadge>(
      find.descendant(
        of: find.byKey(const Key('dutyDay_2025-07-24')),
        matching: find.byType(DutyBadge),
      ),
    );
    expect(badge.type, DutyType.night);
  });

  testWidgets('M 듀티와 회식·약속을 함께 저장하고 달력에 아이콘을 표시한다', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final scheduleService = DutyScheduleService(preferences);
    final repository = _MemoryDutyRepository();
    await tester.binding.setSurfaceSize(const Size(1000, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: DutyManageScreen(
          repository: repository,
          scheduleService: scheduleService,
          initialMonth: DateTime(2026, 8),
          today: DateTime(2026, 8, 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _invokeInkWell(tester, find.byKey(const Key('dutySelector_middle')));
    await _invokeInkWell(tester, find.byKey(const Key('dutyDay_2026-08-01')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('gatheringSwitch')));
    await tester.pumpAndSettle();
    await _enterText(
      tester,
      find.byKey(const Key('gatheringTimeField')),
      '19:00',
    );
    await _tapButton(tester, find.byKey(const Key('addAppointmentButton')));
    await tester.pump();
    await _enterText(
      tester,
      find.byKey(const Key('appointmentTitleField_0')),
      '치과 예약',
    );
    await _enterText(
      tester,
      find.byKey(const Key('appointmentTimeField_0')),
      '15:00',
    );
    await _tapButton(tester, find.byKey(const Key('saveDutyDayButton')));
    await tester.pumpAndSettle();

    expect(repository.values['2026-08-01'], DutyType.middle);
    final stored = scheduleService.loadAll()['2026-08-01']!;
    expect(stored.items, hasLength(2));
    expect(stored.items.first.time, '19:00');
    expect(stored.items.last.title, '치과 예약');
    expect(find.text('🍻'), findsOneWidget);
    expect(find.text('📅'), findsOneWidget);

    await _invokeInkWell(tester, find.byKey(const Key('dutyDay_2026-08-01')));
    await tester.pumpAndSettle();
    expect(find.text('치과 예약'), findsOneWidget);
    expect(find.text('19:00'), findsOneWidget);
  });

  testWidgets('모바일 너비에서도 듀티와 일정 아이콘이 넘치지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const schedule = DutyDaySchedule(
      items: [
        DutyScheduleItem(
          id: 'gathering',
          type: DutyScheduleType.gathering,
          title: '회식',
        ),
        DutyScheduleItem(
          id: 'appointment',
          type: DutyScheduleType.appointment,
          title: '치과 예약',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: DutyCalendarCard(
              month: DateTime(2026, 8),
              duties: const {'2026-08-01': DutyType.middle},
              schedules: const {'2026-08-01': schedule},
              today: DateTime(2026, 8, 1),
              onPreviousMonth: _noop,
              onNextMonth: _noop,
              onManage: _noop,
              onSettings: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('M'), findsWidgets);
    expect(find.text('🍻'), findsOneWidget);
    expect(find.text('📅'), findsOneWidget);
  });
}

void _noop() {}

Future<void> _invokeIconButton(WidgetTester tester, Finder ancestor) async {
  final button = tester.widget<IconButton>(
    find.descendant(of: ancestor, matching: find.byType(IconButton)),
  );
  button.onPressed!();
  await tester.pump();
}

Future<void> _invokeInkWell(WidgetTester tester, Finder ancestor) async {
  final inkWell = tester.widget<InkWell>(
    find.descendant(of: ancestor, matching: find.byType(InkWell)).first,
  );
  inkWell.onTap!();
  await tester.pump();
}

Future<void> _tapButton(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _enterText(
  WidgetTester tester,
  Finder ancestor,
  String value,
) async {
  await tester.ensureVisible(ancestor);
  await tester.enterText(
    find.descendant(of: ancestor, matching: find.byType(TextField)),
    value,
  );
  await tester.pump();
}

class _MemoryDutyRepository implements DutyRepository {
  final values = <String, DutyType>{};

  @override
  Future<Map<String, DutyType>> getForMonth(DateTime month) async {
    final prefix = '${month.year}-${month.month.toString().padLeft(2, '0')}-';
    return Map.fromEntries(
      values.entries.where((entry) => entry.key.startsWith(prefix)),
    );
  }

  @override
  Future<void> save(DateTime date, DutyType type) async {
    values[dutyDateKey(date)] = type;
  }

  @override
  Future<void> delete(DateTime date) async {
    values.remove(dutyDateKey(date));
  }
}
