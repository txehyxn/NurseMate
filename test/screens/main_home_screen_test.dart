import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/screens/coming_soon_screen.dart';
import 'package:nursemate/screens/main_menu_screen.dart';

void main() {
  testWidgets('리뉴얼 홈의 주요 영역과 기존 기능 메뉴를 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

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

  testWidgets('미구현 주요 기능은 준비중 화면으로 연결한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

    final drainage = find.byKey(const Key('drainagePatternMenu'));
    final action = tester.widget<InkWell>(
      find.descendant(of: drainage, matching: find.byType(InkWell)),
    );
    action.onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(ComingSoonScreen), findsOneWidget);
    expect(find.text('배액양상 준비 중'), findsOneWidget);
  });
}
