import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/screens/intake_calculator_screen.dart';
import 'package:nursemate/screens/non_covered_test_screen.dart';
import 'package:nursemate/screens/quick_calculation_more_screen.dart';
import 'package:nursemate/screens/quick_menu_placeholder_screen.dart';

void main() {
  testWidgets('빠른 계산 더보기 메뉴 7개를 모바일에서 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const QuickCalculationMoreScreen(),
      ),
    );

    expect(find.text('빠른 계산 더보기'), findsOneWidget);
    expect(find.text('🧮 계산 도구'), findsOneWidget);
    expect(find.text('📚 업무 자료'), findsOneWidget);
    expect(find.text('BMI 계산'), findsNothing);
    expect(find.text('AST(항생제)'), findsOneWidget);
    expect(find.text('항생제 정보'), findsOneWidget);
    expect(find.text('병원 전화번호'), findsOneWidget);
    expect(find.text('부서 연락처'), findsOneWidget);
    expect(find.text('비급여 검사'), findsOneWidget);
    expect(find.text('검사/비용'), findsOneWidget);
    expect(find.text('혈액 검사'), findsOneWidget);
    expect(find.text('혈액검사 정보'), findsOneWidget);
    expect(find.byIcon(Icons.medication_rounded), findsOneWidget);
    expect(find.byIcon(Icons.local_phone_rounded), findsOneWidget);
    expect(find.byIcon(Icons.science_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bloodtype_rounded), findsOneWidget);

    final calculationTitle = tester.getTopLeft(
      find.byKey(const Key('quickCategory-calculation')),
    );
    final drop = tester.getTopLeft(find.byKey(const Key('quickMore-drop')));
    final ccPerHour = tester.getTopLeft(
      find.byKey(const Key('quickMore-ccPerHour')),
    );
    final intake = tester.getTopLeft(find.byKey(const Key('quickMore-intake')));
    final referenceTitle = tester.getTopLeft(
      find.byKey(const Key('quickCategory-reference')),
    );
    final search = tester.getTopLeft(
      find.byKey(const Key('workReferenceSearchBar')),
    );
    final ast = tester.getTopLeft(find.byKey(const Key('quickMore-ast')));
    final blood = tester.getTopLeft(
      find.byKey(const Key('quickMore-bloodTest')),
    );
    final nonCovered = tester.getTopLeft(
      find.byKey(const Key('quickMore-nonCoveredTest')),
    );
    final phone = tester.getTopLeft(find.byKey(const Key('quickMore-phone')));

    expect(calculationTitle.dy, lessThan(drop.dy));
    expect(drop.dy, lessThan(ccPerHour.dy));
    expect(ccPerHour.dy, lessThan(intake.dy));
    expect(intake.dy, lessThan(referenceTitle.dy));
    expect(referenceTitle.dy, lessThan(search.dy));
    expect(search.dy, lessThan(ast.dy));
    expect(ast.dy, lessThan(blood.dy));
    expect(blood.dy, lessThan(nonCovered.dy));
    expect(nonCovered.dy, lessThan(phone.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('업무 자료 검색창은 포커스와 입력만 받고 메뉴는 유지한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const QuickCalculationMoreScreen(),
      ),
    );

    final searchBar = find.byKey(const Key('workReferenceSearchBar'));
    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.text('업무 자료 검색'), findsOneWidget);
    expect(
      find.descendant(
        of: searchBar,
        matching: find.byIcon(Icons.search_rounded),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(searchBar);
    await tester.tap(searchBar);
    await tester.pump();

    final editable = tester.widget<EditableText>(
      find.descendant(of: searchBar, matching: find.byType(EditableText)),
    );
    expect(editable.focusNode.hasFocus, isTrue);

    await tester.enterText(searchBar, 'AST');
    await tester.pump();

    expect(find.byKey(const Key('quickMore-ast')), findsOneWidget);
    expect(find.byKey(const Key('quickMore-bloodTest')), findsOneWidget);
    expect(find.byKey(const Key('quickMore-nonCoveredTest')), findsOneWidget);
    expect(find.byKey(const Key('quickMore-phone')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('새 정보 메뉴는 동일한 준비 화면으로 연결한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const QuickCalculationMoreScreen(),
      ),
    );

    for (final entry in const {
      'quickMore-ast': 'AST(항생제)',
      'quickMore-phone': '병원 전화번호',
      'quickMore-bloodTest': '혈액 검사',
    }.entries) {
      final menu = find.byKey(Key(entry.key));
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();

      expect(find.byType(QuickMenuPlaceholderScreen), findsOneWidget);
      expect(find.text(entry.value), findsNWidgets(2));
      expect(find.text('준비 중입니다.'), findsOneWidget);
      expect(find.text('추후 업데이트될 기능입니다.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('비급여 검사 메뉴는 카테고리 화면으로 연결한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const QuickCalculationMoreScreen(),
      ),
    );

    final menu = find.byKey(const Key('quickMore-nonCoveredTest'));
    await tester.ensureVisible(menu);
    await tester.tap(menu);
    await tester.pumpAndSettle();

    expect(find.byType(NonCoveredTestScreen), findsOneWidget);
    expect(find.text('검사명을 검색하세요'), findsOneWidget);
    expect(find.byKey(const Key('nonCoveredCategory-mri')), findsOneWidget);
  });

  testWidgets('기존 섭취량 계산기 연결은 유지한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const QuickCalculationMoreScreen(),
      ),
    );

    final intake = find.byKey(const Key('quickMore-intake'));
    await tester.ensureVisible(intake);
    await tester.tap(intake);
    await tester.pumpAndSettle();

    expect(find.byType(IntakeCalculatorScreen), findsOneWidget);
    expect(find.text('총 섭취량'), findsOneWidget);
  });

  testWidgets('넓은 화면에서는 메뉴 카드를 2열로 배치한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const QuickCalculationMoreScreen(),
      ),
    );

    final first = tester.getTopLeft(find.byKey(const Key('quickMore-drop')));
    final second = tester.getTopLeft(
      find.byKey(const Key('quickMore-ccPerHour')),
    );
    final third = tester.getTopLeft(find.byKey(const Key('quickMore-intake')));
    final referenceTitle = tester.getTopLeft(
      find.byKey(const Key('quickCategory-reference')),
    );
    final search = tester.getTopLeft(
      find.byKey(const Key('workReferenceSearchBar')),
    );
    final ast = tester.getTopLeft(find.byKey(const Key('quickMore-ast')));
    final blood = tester.getTopLeft(
      find.byKey(const Key('quickMore-bloodTest')),
    );

    expect(second.dy, closeTo(first.dy, 0.1));
    expect(second.dx, greaterThan(first.dx));
    expect(third.dy, greaterThan(first.dy));
    expect(referenceTitle.dy, greaterThan(third.dy));
    expect(search.dy, greaterThan(referenceTitle.dy));
    expect(ast.dy, greaterThan(search.dy));
    expect(blood.dy, closeTo(ast.dy, 0.1));
    expect(blood.dx, greaterThan(ast.dx));
    expect(tester.takeException(), isNull);
  });
}
