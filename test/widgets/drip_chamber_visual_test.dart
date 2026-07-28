import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/widgets/drip_chamber_visual.dart';

void main() {
  group('dripCycleDuration', () {
    test('원본 secondsPerDrop을 마이크로초 Duration으로 변환한다', () {
      final cases = {
        7.2: 7200000,
        5.4: 5400000,
        2.7: 2700000,
        1.44: 1440000,
        2.16: 2160000,
        0.6: 600000,
        5.76: 5760000,
      };

      for (final entry in cases.entries) {
        expect(
          dripCycleDuration(entry.key).inMicroseconds,
          entry.value,
          reason: '${entry.key}초 변환',
        );
      }
    });

    test('0, 음수, NaN, Infinity는 안전한 대체 주기를 사용한다', () {
      for (final value in [0.0, -1.0, double.nan, double.infinity]) {
        expect(dripCycleDuration(value), invalidDripCycleDuration);
        expect(dripCycleDuration(value), isNot(Duration.zero));
      }
    });

    test('0.1초 미만은 시각화에만 최소 주기를 적용한다', () {
      expect(dripCycleDuration(0.6), const Duration(milliseconds: 600));
      expect(dripCycleDuration(0.1), minimumDripCycleDuration);
      expect(dripCycleDuration(0.099), minimumDripCycleDuration);
      expect(dripCycleDuration(0.001), minimumDripCycleDuration);
    });
  });

  group('AnimatedDripChamber 주기', () {
    for (final secondsPerDrop in [7.2, 5.4, 2.7, 2.16, 1.44, 0.6]) {
      testWidgets('$secondsPerDrop초 직전에는 첫 주기이고 경과 후 새 주기가 시작된다', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimatedDripChamber(secondsPerDrop: secondsPerDrop),
            ),
          ),
        );

        expect(_painter(tester).cycleSeconds, closeTo(secondsPerDrop, 1e-6));
        expect(_painter(tester).progress, 0);

        final cycle = dripCycleDuration(secondsPerDrop);
        await tester.pump(cycle - const Duration(milliseconds: 1));
        expect(_painter(tester).progress, greaterThan(0.99));

        await tester.pump(const Duration(milliseconds: 1));
        expect(_painter(tester).progress, closeTo(0, 0.002));

        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      });
    }

    testWidgets('재계산 시 5.4초에서 2.16초로 바꾸고 새 방울부터 시작한다', (tester) async {
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

      await tester.pump(const Duration(seconds: 1));
      expect(_painter(tester).progress, greaterThan(0));

      update(() => seconds = 2.16);
      await tester.pump();

      expect(find.byType(AnimatedDripChamber), findsOneWidget);
      expect(find.byKey(const Key('dripChamberPaint')), findsOneWidget);
      expect(_painter(tester).cycleSeconds, closeTo(2.16, 1e-6));
      expect(_painter(tester).progress, 0);
      expect(_countdown(tester), closeTo(2.2, 0.05));

      await tester.pump(const Duration(milliseconds: 540));
      expect(_painter(tester).progress, closeTo(0.25, 0.02));

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('반복 재계산에도 애니메이션 컨트롤러가 중복 실행되지 않는다', (tester) async {
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

      for (var index = 0; index < 12; index++) {
        update(() => seconds = index.isEven ? 2.16 : 1.44);
        await tester.pump();
        expect(find.byType(AnimatedDripChamber), findsOneWidget);
        expect(find.byKey(const Key('dripChamberPaint')), findsOneWidget);
        expect(_painter(tester).progress, 0);
      }

      await tester.pump(const Duration(milliseconds: 360));
      expect(_painter(tester).progress, closeTo(0.25, 0.03));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('AnimatedDripChamber 카운트다운과 방어 처리', () {
    testWidgets('카운트다운은 원본 주기를 사용해 감소하고 반복 시 복원된다', (tester) async {
      const interval = 5.4;
      await tester.pumpWidget(
        const MaterialApp(home: AnimatedDripChamber(secondsPerDrop: interval)),
      );

      expect(_countdown(tester), closeTo(interval, 0.05));
      await tester.pump(const Duration(seconds: 1));
      expect(_countdown(tester), closeTo(4.4, 0.11));
      await tester.pump(const Duration(milliseconds: 4400));
      expect(_countdown(tester), closeTo(interval, 0.11));
      expect(_countdown(tester), greaterThanOrEqualTo(0));
      expect(
        tester
            .widget<AnimatedDripChamber>(find.byType(AnimatedDripChamber))
            .secondsPerDrop,
        interval,
      );

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('0.1초 미만에서도 원본 값은 유지하고 표현 주기만 제한한다', (tester) async {
      const originalInterval = 0.05;
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedDripChamber(secondsPerDrop: originalInterval),
        ),
      );

      expect(
        tester
            .widget<AnimatedDripChamber>(find.byType(AnimatedDripChamber))
            .secondsPerDrop,
        originalInterval,
      );
      expect(_painter(tester).cycleSeconds, 0.1);
      expect(find.text('매우 빠른 속도로 애니메이션은 근사 표시됩니다.'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: AnimatedDripChamber(secondsPerDrop: 0.1)),
      );
      expect(_painter(tester).cycleSeconds, 0.1);
      expect(find.text('매우 빠른 속도로 애니메이션은 근사 표시됩니다.'), findsNothing);
    });

    testWidgets('잘못된 간격도 NaN이나 Infinity 없이 안전하게 표시한다', (tester) async {
      for (final value in [0.0, -1.0, double.nan, double.infinity]) {
        await tester.pumpWidget(
          MaterialApp(home: AnimatedDripChamber(secondsPerDrop: value)),
        );
        expect(_painter(tester).cycleSeconds, 1);
        expect(find.textContaining('NaN'), findsNothing);
        expect(find.textContaining('Infinity'), findsNothing);
        expect(_countdown(tester), greaterThanOrEqualTo(0));
        await tester.pump(const Duration(milliseconds: 20));
      }
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
      expect(tester.takeException(), isNull);
    });
  });

  test('CustomPainter는 진행률이나 주기가 바뀔 때만 다시 그린다', () {
    const original = DripChamberPainter(progress: 0.2, cycleSeconds: 5.4);
    const same = DripChamberPainter(progress: 0.2, cycleSeconds: 5.4);
    const changedProgress = DripChamberPainter(
      progress: 0.3,
      cycleSeconds: 5.4,
    );
    const changedCycle = DripChamberPainter(progress: 0.2, cycleSeconds: 2.16);

    expect(original.shouldRepaint(same), isFalse);
    expect(original.shouldRepaint(changedProgress), isTrue);
    expect(original.shouldRepaint(changedCycle), isTrue);
  });
}

DripChamberPainter _painter(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(
    find.byKey(const Key('dripChamberPaint')),
  );
  return customPaint.painter! as DripChamberPainter;
}

double _countdown(WidgetTester tester) {
  final text = tester
      .widget<Text>(find.byKey(const Key('dropCountdown')))
      .data!;
  final match = RegExp(r'(\d+(?:\.\d+)?)초$').firstMatch(text);
  return double.parse(match!.group(1)!);
}
