import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/main.dart';
import 'package:nursemate/widgets/drip_chamber_visual.dart';

void main() {
  testWidgets('계산 전에는 두 입력만 표시하고 애니메이션은 표시하지 않는다', (tester) async {
    await _openCalculator(tester);

    expect(find.byKey(const Key('volumeField')), findsOneWidget);
    expect(find.byKey(const Key('hoursField')), findsOneWidget);
    expect(find.byKey(const Key('minutesField')), findsNothing);
    expect(find.byKey(const Key('dropFactorField')), findsNothing);
    expect(find.byType(AnimatedDripChamber), findsNothing);
  });

  testWidgets('기본값 100mL와 3hr를 20 gtt/mL 기준으로 계산한다', (tester) async {
    await _openCalculator(tester);
    await _calculate(tester);

    expect(find.text('33.33'), findsOneWidget);
    expect(find.text('cc/hr'), findsOneWidget);
    expect(find.text('11.11 gtt/min'), findsOneWidget);
    expect(find.text('5.40초에 한 방울'), findsOneWidget);
    expect(find.text('일반 성인 수액세트 20 gtt/mL 기준'), findsOneWidget);
    expect(find.byType(AnimatedDripChamber), findsOneWidget);
    expect(find.byKey(const Key('dropCountdown')), findsOneWidget);
    expect(_animationSeconds(tester), closeTo(5.4, 0.000001));

    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('100mL와 4hr 결과 및 원본 7.2초를 애니메이션에 전달한다', (tester) async {
    await _openCalculator(tester);
    await tester.enterText(find.byKey(const Key('hoursField')), '4');
    await _calculate(tester);

    expect(find.text('25.00'), findsOneWidget);
    expect(find.text('8.33 gtt/min'), findsOneWidget);
    expect(find.text('7.20초에 한 방울'), findsOneWidget);
    expect(_animationSeconds(tester), closeTo(7.2, 0.000001));
  });

  testWidgets('소수 시간 1.5hr를 허용하고 원본 2.7초를 전달한다', (tester) async {
    await _openCalculator(tester);
    await tester.enterText(find.byKey(const Key('hoursField')), '1.5');
    await _calculate(tester);

    expect(find.text('66.67'), findsOneWidget);
    expect(find.text('2.70초에 한 방울'), findsOneWidget);
    expect(_animationSeconds(tester), closeTo(2.7, 0.000001));
  });

  testWidgets('빈 값, 문자열, 0, 음수 입력에 오류를 표시하고 계산하지 않는다', (tester) async {
    await _openCalculator(tester);

    await tester.enterText(find.byKey(const Key('volumeField')), '');
    await tester.enterText(find.byKey(const Key('hoursField')), '');
    await _calculate(tester);
    expect(find.text('용량을 입력해 주세요.'), findsOneWidget);
    expect(find.text('시간을 입력해 주세요.'), findsOneWidget);
    expect(find.byType(AnimatedDripChamber), findsNothing);

    await tester.enterText(find.byKey(const Key('volumeField')), 'abc');
    await tester.enterText(find.byKey(const Key('hoursField')), 'xyz');
    await _calculate(tester);
    expect(find.text('올바른 숫자를 입력해 주세요.'), findsNWidgets(2));

    await tester.enterText(find.byKey(const Key('volumeField')), '0');
    await tester.enterText(find.byKey(const Key('hoursField')), '0');
    await _calculate(tester);
    expect(find.text('용량은 0보다 커야 합니다.'), findsOneWidget);
    expect(find.text('시간은 0보다 커야 합니다.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('volumeField')), '-1');
    await tester.enterText(find.byKey(const Key('hoursField')), '-2.5');
    await _calculate(tester);
    expect(find.text('용량은 0보다 커야 합니다.'), findsOneWidget);
    expect(find.text('시간은 0보다 커야 합니다.'), findsOneWidget);
    expect(find.byType(AnimatedDripChamber), findsNothing);
  });

  testWidgets('계산 후 입력이 잘못되면 기존 애니메이션을 제거한다', (tester) async {
    await _openCalculator(tester);
    await _calculate(tester);
    expect(find.byType(AnimatedDripChamber), findsOneWidget);

    await tester.enterText(find.byKey(const Key('volumeField')), '0');
    await _calculate(tester);

    expect(find.byType(AnimatedDripChamber), findsNothing);
  });
}

Future<void> _openCalculator(WidgetTester tester) async {
  await tester.pumpWidget(const NurseMateApp(initiallyUnlocked: true));
  final calculatorAction = tester.widget<InkWell>(
    find.descendant(
      of: find.byKey(const Key('infusionCalculatorMenu')),
      matching: find.byType(InkWell),
    ),
  );
  calculatorAction.onTap!();
  await tester.pumpAndSettle();
}

Future<void> _calculate(WidgetTester tester) async {
  final button = tester.widget<FilledButton>(
    find.byKey(const Key('calculateButton')),
  );
  button.onPressed!();
  await tester.pump();
}

double _animationSeconds(WidgetTester tester) {
  return tester
      .widget<AnimatedDripChamber>(find.byType(AnimatedDripChamber))
      .secondsPerDrop;
}
