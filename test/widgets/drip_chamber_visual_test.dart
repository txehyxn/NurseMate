import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/widgets/drip_chamber_visual.dart';

void main() {
  group('dripCycleDuration', () {
    test('원본 초 값을 마이크로초 단위로 변환한다', () {
      expect(dripCycleDuration(5.4).inMicroseconds, 5400000);
      expect(dripCycleDuration(1.44).inMicroseconds, 1440000);
      expect(dripCycleDuration(0.6).inMicroseconds, 600000);
    });

    test('잘못된 값도 0이 아닌 안전한 duration으로 처리한다', () {
      for (final value in [0.0, -1.0, double.nan, double.infinity]) {
        expect(dripCycleDuration(value), invalidDripCycleDuration);
        expect(dripCycleDuration(value), isNot(Duration.zero));
      }
    });
  });

  testWidgets('계산된 주기 동안 방울이 움직이고 반복된다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedDripChamber(secondsPerDrop: 5.4)),
      ),
    );

    final initialPainter = _painter(tester);
    await tester.pump(const Duration(milliseconds: 300));
    final movingPainter = _painter(tester);
    expect(movingPainter.progress, greaterThan(initialPainter.progress));

    await tester.pump(const Duration(milliseconds: 5100));
    final repeatedPainter = _painter(tester);
    expect(repeatedPainter.progress, closeTo(0, .02));
  });

  testWidgets('잘못된 간격도 오류 없이 안전한 주기로 표시한다', (tester) async {
    for (final value in [0.0, -1.0, double.nan, double.infinity]) {
      await tester.pumpWidget(
        MaterialApp(home: AnimatedDripChamber(secondsPerDrop: value)),
      );
      expect(_painter(tester).cycleSeconds, 1);
      expect(find.textContaining('NaN'), findsNothing);
      expect(find.textContaining('Infinity'), findsNothing);
      await tester.pump(const Duration(milliseconds: 20));
    }
  });

  testWidgets('새 계산값을 받으면 주기를 즉시 갱신한다', (tester) async {
    var seconds = 5.4;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AnimatedDripChamber(secondsPerDrop: seconds);
          },
        ),
      ),
    );

    expect(_painter(tester).cycleSeconds, closeTo(5.4, 1e-6));
    update(() => seconds = 0.6);
    await tester.pump();
    expect(_painter(tester).cycleSeconds, closeTo(0.6, 1e-6));

    await tester.pump(const Duration(milliseconds: 300));
    expect(_painter(tester).progress, closeTo(.5, .06));
  });

  testWidgets('백그라운드에서 멈추고 복귀 시 새 주기로 시작한다', (tester) async {
    final binding = tester.binding;
    await tester.pumpWidget(
      const MaterialApp(home: AnimatedDripChamber(secondsPerDrop: 5.4)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 500));
    expect(_painter(tester).progress, 0);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_painter(tester).progress, greaterThan(0));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

DripChamberPainter _painter(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(
    find.byKey(const Key('dripChamberPaint')),
  );
  return customPaint.painter! as DripChamberPainter;
}
