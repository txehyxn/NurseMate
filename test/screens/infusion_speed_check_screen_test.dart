import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/main.dart';
import 'package:nursemate/screens/infusion_speed_check_screen.dart';
import 'package:nursemate/widgets/drip_chamber_visual.dart';

void main() {
  const expectedIntervals = {
    30: 6.0,
    40: 4.5,
    60: 3.0,
    80: 2.25,
    100: 1.8,
    120: 1.5,
    150: 1.2,
    180: 1.0,
  };

  test('지정된 cc/hr별 secondsPerDrop 고정값을 제공한다', () {
    expect(infusionSpeedSecondsPerDrop, expectedIntervals);
  });

  testWidgets('메인 화면에서 기존 계산과 수액속도 확인 메뉴를 제공한다', (tester) async {
    await tester.pumpWidget(const NurseMateApp(initiallyUnlocked: true));

    expect(find.text('수액속도 계산'), findsOneWidget);
    expect(find.text('방울수 계산'), findsOneWidget);

    final quickAction = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const Key('infusionSpeedCheckMenu')),
        matching: find.byType(InkWell),
      ),
    );
    quickAction.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(InfusionSpeedCheckScreen), findsOneWidget);
    expect(find.text('일반 성인 수액세트(20 gtt/mL) 기준'), findsOneWidget);
  });

  testWidgets('각 속도 선택 시 기존 애니메이션에 대응하는 원본 값을 전달한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InfusionSpeedCheckScreen()),
    );

    for (final entry in expectedIntervals.entries) {
      final option = find.byKey(Key('speedOption_${entry.key}'));
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pump();

      final selectedSpeed = tester.widget<Text>(
        find.byKey(const Key('selectedSpeedValue')),
      );
      final selectedInterval = tester.widget<Text>(
        find.byKey(const Key('selectedSecondsPerDrop')),
      );
      final animation = tester.widget<AnimatedDripChamber>(
        find.byType(AnimatedDripChamber),
      );

      expect(selectedSpeed.data, '${entry.key} cc/hr');
      expect(selectedInterval.data, '1방울당 ${entry.value.toStringAsFixed(2)}초');
      expect(animation.secondsPerDrop, entry.value);
    }
  });

  testWidgets('속도 확인 페이지에는 계산 입력과 계산 버튼이 없다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InfusionSpeedCheckScreen()),
    );

    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const Key('volumeField')), findsNothing);
    expect(find.byKey(const Key('hoursField')), findsNothing);
    expect(find.byKey(const Key('calculateButton')), findsNothing);
  });
}
