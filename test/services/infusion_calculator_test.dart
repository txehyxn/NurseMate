import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/services/infusion_calculator.dart';

void main() {
  const calculator = InfusionCalculator();
  const tolerance = 0.000001;

  group('InfusionCalculator 20 gtt/mL 고정 계산', () {
    final cases =
        <
          ({
            String name,
            double volumeMl,
            double hours,
            double expectedCcPerHour,
            double expectedGttPerMinute,
            double expectedSecondsPerDrop,
          })
        >[
          (
            name: '100mL를 4시간 동안 투여하면 7.2초마다 한 방울이다',
            volumeMl: 100,
            hours: 4,
            expectedCcPerHour: 25,
            expectedGttPerMinute: 8.333333333333334,
            expectedSecondsPerDrop: 7.2,
          ),
          (
            name: '100mL를 3시간 동안 투여하면 5.4초마다 한 방울이다',
            volumeMl: 100,
            hours: 3,
            expectedCcPerHour: 33.333333333333336,
            expectedGttPerMinute: 11.11111111111111,
            expectedSecondsPerDrop: 5.4,
          ),
          (
            name: '500mL를 8시간 동안 투여하면 2.88초마다 한 방울이다',
            volumeMl: 500,
            hours: 8,
            expectedCcPerHour: 62.5,
            expectedGttPerMinute: 20.833333333333332,
            expectedSecondsPerDrop: 2.88,
          ),
          (
            name: '소수 시간 1.5시간을 원본 double로 계산한다',
            volumeMl: 100,
            hours: 1.5,
            expectedCcPerHour: 66.66666666666667,
            expectedGttPerMinute: 22.22222222222222,
            expectedSecondsPerDrop: 2.7,
          ),
        ];

    for (final testCase in cases) {
      test(testCase.name, () {
        final result = calculator.calculate(
          volumeMl: testCase.volumeMl,
          hours: testCase.hours,
        );

        expect(
          result.mlPerHour,
          closeTo(testCase.expectedCcPerHour, tolerance),
        );
        expect(
          result.gttPerMinute,
          closeTo(testCase.expectedGttPerMinute, tolerance),
        );
        expect(
          result.secondsPerDrop,
          closeTo(testCase.expectedSecondsPerDrop, tolerance),
        );
        expect(
          result.secondsPerDrop * result.gttPerMinute,
          closeTo(60.0, tolerance),
          reason: '표시용 반올림 없이 원본 gtt/min으로 방울 간격을 계산해야 한다.',
        );
      });
    }

    test('성인 수액세트 점적계수는 20.0으로 고정한다', () {
      expect(adultDropFactor, 20.0);
    });

    test('표시용 정수 점적 수를 방울 간격 계산에 재사용하지 않는다', () {
      final result = calculator.calculate(volumeMl: 100, hours: 3);

      expect(result.roundedDropsPerMinute, 11);
      expect(result.secondsPerDrop, closeTo(5.4, tolerance));
      expect(result.secondsPerDrop, isNot(closeTo(60 / 11, tolerance)));
    });
  });

  group('InfusionCalculator 입력 검증', () {
    test('0, 음수, NaN, Infinity 용량을 거부한다', () {
      for (final volume in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          () => calculator.calculate(volumeMl: volume, hours: 1),
          throwsArgumentError,
        );
      }
    });

    test('0, 음수, NaN, Infinity 시간을 거부한다', () {
      for (final hours in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          () => calculator.calculate(volumeMl: 100, hours: hours),
          throwsArgumentError,
        );
      }
    });
  });
}
