import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/models/infusion_calculation_result.dart';
import 'package:nursemate/services/infusion_calculator.dart';

void main() {
  const calculator = InfusionCalculator();

  group('InfusionCalculator', () {
    final cases =
        <
          ({
            double volume,
            int hours,
            int minutes,
            int factor,
            double mlPerHour,
            double gttPerMinute,
            double secondsPerDrop,
          })
        >[
          (
            volume: 100,
            hours: 3,
            minutes: 0,
            factor: 20,
            mlPerHour: 100 / 3,
            gttPerMinute: 100 / 9,
            secondsPerDrop: 5.4,
          ),
          (
            volume: 1000,
            hours: 8,
            minutes: 0,
            factor: 20,
            mlPerHour: 125,
            gttPerMinute: 125 / 3,
            secondsPerDrop: 1.44,
          ),
          (
            volume: 500,
            hours: 4,
            minutes: 30,
            factor: 15,
            mlPerHour: 1000 / 9,
            gttPerMinute: 250 / 9,
            secondsPerDrop: 2.16,
          ),
          (
            volume: 50,
            hours: 0,
            minutes: 30,
            factor: 60,
            mlPerHour: 100,
            gttPerMinute: 100,
            secondsPerDrop: 0.6,
          ),
        ];

    for (final testCase in cases) {
      test(
        '${testCase.volume}mL / ${testCase.hours}시간 ${testCase.minutes}분',
        () {
          final result = calculator.calculate(
            volumeMl: testCase.volume,
            hours: testCase.hours,
            minutes: testCase.minutes,
            dropFactor: testCase.factor,
          );
          expect(result.mlPerHour, closeTo(testCase.mlPerHour, 1e-9));
          expect(result.gttPerMinute, closeTo(testCase.gttPerMinute, 1e-9));
          expect(result.secondsPerDrop, closeTo(testCase.secondsPerDrop, 1e-9));
        },
      );
    }

    test('중간 반올림 없이 초당 방울 간격을 계산한다', () {
      final result = calculator.calculate(
        volumeMl: 100,
        hours: 3,
        minutes: 0,
        dropFactor: 20,
      );
      expect(result.roundedDropsPerMinute, 11);
      expect(result.secondsPerDrop, closeTo(5.4, 1e-9));
      expect(result.secondsPerDrop, isNot(closeTo(60 / 11, 1e-9)));
    });

    test('실제 챔버와 목표 속도를 비교한다', () {
      const result = InfusionCalculationResult(
        mlPerHour: 100,
        gttPerMinute: 20,
        secondsPerDrop: 3,
      );
      expect(result.compareWith(17).pace, InfusionPace.tooSlow);
      expect(result.compareWith(19).pace, InfusionPace.onTarget);
      expect(result.compareWith(23).pace, InfusionPace.tooFast);
    });

    test('잘못된 입력을 거부한다', () {
      for (final volume in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          () => calculator.calculate(
            volumeMl: volume,
            hours: 1,
            minutes: 0,
            dropFactor: 20,
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => calculator.calculate(
          volumeMl: 100,
          hours: 0,
          minutes: 0,
          dropFactor: 20,
        ),
        throwsArgumentError,
      );
      expect(
        () => calculator.calculate(
          volumeMl: 100,
          hours: 1,
          minutes: 60,
          dropFactor: 20,
        ),
        throwsArgumentError,
      );
      expect(
        () => calculator.calculate(
          volumeMl: 100,
          hours: 1,
          minutes: 0,
          dropFactor: 12,
        ),
        throwsArgumentError,
      );
    });
  });
}
