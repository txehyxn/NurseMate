import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_design_system.dart';
import 'package:nursemate/screens/night_checklist_screen.dart';
import 'package:nursemate/services/checklist_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('NIGHT 체크리스트 17개와 초기 진행률을 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(_TestApp(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('NIGHT 체크리스트'), findsOneWidget);
    expect(find.text('오늘 진행률'), findsOneWidget);
    expect(find.text('0 / 17 완료'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.byKey(const Key('nightChecklistList')), findsOneWidget);
    expect(find.text('9PM Inj.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('nightChecklistItem-charting_review')),
      420,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('차팅 확인'), findsOneWidget);
    expect(
      find.byKey(const Key('nightChecklistClearAllButton')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('nightChecklistCompleteAllButton')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('NIGHT 체크 상태를 전용 키에 저장하고 복원한다', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(_TestApp(preferences: preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nightChecklistCheck-inj_9pm')));
    await tester.pumpAndSettle();

    expect(find.text('1 / 17 완료'), findsOneWidget);
    expect(find.text('6%'), findsOneWidget);
    expect(
      preferences.getStringList(nightChecklistCompletedKey),
      contains('inj_9pm'),
    );
    expect(preferences.getStringList(dayChecklistCompletedKey), isNull);
    expect(preferences.getStringList(eveningChecklistCompletedKey), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(_TestApp(preferences: preferences));
    await tester.pumpAndSettle();

    expect(find.text('1 / 17 완료'), findsOneWidget);
    final restoredText = tester.widget<Text>(find.text('9PM Inj.'));
    expect(restoredText.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('NIGHT 전체 완료와 전체 해제를 저장한다', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(_TestApp(preferences: preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nightChecklistCompleteAllButton')));
    await tester.pumpAndSettle();

    expect(find.text('17 / 17 완료'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(
      preferences.getStringList(nightChecklistCompletedKey),
      hasLength(17),
    );

    await tester.tap(find.byKey(const Key('nightChecklistClearAllButton')));
    await tester.pumpAndSettle();

    expect(find.text('0 / 17 완료'), findsOneWidget);
    expect(preferences.getStringList(nightChecklistCompletedKey), isEmpty);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: NurseMateTheme.light(),
      home: NightChecklistScreen(preferences: preferences),
    );
  }
}
