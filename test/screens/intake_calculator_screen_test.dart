import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/models/intake_calculator_model.dart';
import 'package:nursemate/screens/intake_calculator_screen.dart';

void main() {
  testWidgets('식사 종류와 음식별 11개 비율 선택지를 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const IntakeCalculatorScreen(),
      ),
    );

    expect(find.text('섭취량 계산기'), findsOneWidget);
    expect(find.textContaining('퍼센트만 선택하면'), findsOneWidget);
    expect(find.byKey(const Key('mealTypeSelector')), findsOneWidget);
    expect(find.text('밥'), findsNWidgets(2));
    expect(find.text('국'), findsNWidgets(2));
    expect(find.text('채소반찬'), findsNWidgets(2));
    expect(find.text('육류·생선반찬'), findsNWidgets(2));
    expect(find.text('300g · 계산기준 200cc'), findsOneWidget);
    expect(find.text('계산기준 200cc'), findsOneWidget);
    expect(find.text('계산기준 50cc'), findsOneWidget);
    expect(find.text('계산기준 40cc'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(44));
    for (final percentage in IntakeCalculatorModel.percentages) {
      expect(
        find.descendant(
          of: find.byKey(Key('intakeChip-main-$percentage')),
          matching: find.text('$percentage%'),
        ),
        findsOneWidget,
      );
    }
    expect(_totalLabel(tester), '0 cc');
    expect(_itemAmount(tester, 'main'), '0cc');
    expect(_itemAmount(tester, 'soup'), '0cc');
    expect(_itemAmount(tester, 'vegetable'), '0cc');
    expect(_itemAmount(tester, 'protein'), '0cc');
    expect(tester.takeException(), isNull);
  });

  testWidgets('선택한 비율을 자동 계산하고 초기화한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const IntakeCalculatorScreen(),
      ),
    );

    for (final selection in const {
      'main': 50,
      'soup': 50,
      'vegetable': 100,
      'protein': 50,
    }.entries) {
      final chip = find.byKey(
        Key('intakeChip-${selection.key}-${selection.value}'),
      );
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
    }

    expect(_totalLabel(tester), '270 cc');
    expect(_itemAmount(tester, 'main'), '100cc');
    expect(_itemAmount(tester, 'soup'), '100cc');
    expect(_itemAmount(tester, 'vegetable'), '50cc');
    expect(_itemAmount(tester, 'protein'), '20cc');

    final selectedChipScale = tester.widget<AnimatedScale>(
      find.ancestor(
        of: find.byKey(const Key('intakeChip-main-50')),
        matching: find.byType(AnimatedScale),
      ),
    );
    expect(selectedChipScale.scale, 1.06);

    final reset = find.byKey(const Key('intakeResetButton'));
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();

    expect(_totalLabel(tester), '0 cc');
    expect(_itemAmount(tester, 'main'), '0cc');
  });

  testWidgets('죽과 미음 선택 시 첫 번째 음식 계산만 변경한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const IntakeCalculatorScreen(),
      ),
    );

    final main100 = find.byKey(const Key('intakeChip-main-100'));
    await tester.ensureVisible(main100);
    await tester.tap(main100);
    await tester.pumpAndSettle();
    expect(_totalLabel(tester), '200 cc');

    await tester.ensureVisible(find.byKey(const Key('mealType-porridge')));
    await tester.tap(find.byKey(const Key('mealType-porridge')));
    await tester.pumpAndSettle();
    expect(find.text('죽'), findsNWidgets(3));
    expect(find.text('300g · 계산기준 250cc'), findsOneWidget);
    expect(_totalLabel(tester), '250 cc');

    await tester.tap(find.byKey(const Key('mealType-thinPorridge')));
    await tester.pumpAndSettle();
    expect(find.text('미음'), findsNWidgets(3));
    expect(find.text('200cc · 계산기준 200cc'), findsOneWidget);
    expect(_totalLabel(tester), '200 cc');
    expect(tester.takeException(), isNull);
  });
}

String _totalLabel(WidgetTester tester) {
  final semantics = tester.widget<Semantics>(
    find.byKey(const Key('totalIntakeValue')),
  );
  return semantics.properties.label!;
}

String _itemAmount(WidgetTester tester, String itemId) {
  final amount = tester.widget<Text>(
    find.descendant(
      of: find.byKey(Key('intakeAmount-$itemId')),
      matching: find.byType(Text),
    ),
  );
  return amount.data!;
}
