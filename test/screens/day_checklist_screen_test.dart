import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_design_system.dart';
import 'package:nursemate/screens/day_checklist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('DAY 체크리스트와 초기 진행률을 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(_TestApp(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('DAY 체크리스트'), findsOneWidget);
    expect(find.text('오늘 진행률'), findsOneWidget);
    expect(find.text('0 / 19 완료'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.byKey(const Key('dayChecklistList')), findsOneWidget);
    expect(find.text('9AM Inj.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('dayChecklistItem-intake_output')),
      420,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('I&O (06시~13시)'), findsOneWidget);
    expect(find.byKey(const Key('dayChecklistClearAllButton')), findsOneWidget);
    expect(
      find.byKey(const Key('dayChecklistCompleteAllButton')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('체크 상태를 저장하고 다시 열 때 복원한다', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(_TestApp(preferences: preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dayChecklistCheck-inj_9am')));
    await tester.pumpAndSettle();

    expect(find.text('1 / 19 완료'), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);
    expect(
      preferences.getStringList(dayChecklistCompletedKey),
      contains('inj_9am'),
    );
    final checkedText = tester.widget<Text>(find.text('9AM Inj.'));
    expect(checkedText.style?.decoration, TextDecoration.lineThrough);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(_TestApp(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('1 / 19 완료'), findsOneWidget);
    final restoredText = tester.widget<Text>(find.text('9AM Inj.'));
    expect(restoredText.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('전체 완료와 전체 해제가 진행률과 저장값에 반영된다', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(_TestApp(preferences: preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dayChecklistCompleteAllButton')));
    await tester.pumpAndSettle();

    expect(find.text('19 / 19 완료'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(preferences.getStringList(dayChecklistCompletedKey), hasLength(19));

    await tester.tap(find.byKey(const Key('dayChecklistClearAllButton')));
    await tester.pumpAndSettle();

    expect(find.text('0 / 19 완료'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(preferences.getStringList(dayChecklistCompletedKey), isEmpty);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: NurseMateTheme.light(),
      home: DayChecklistScreen(preferences: preferences),
    );
  }
}
