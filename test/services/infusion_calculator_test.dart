import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/services/infusion_calculator.dart';

void main() {
  const calculator = InfusionCalculator();
  const tolerance = 1e-9;

  group('InfusionCalculator 계산 정확도', () {
    final cases =
        <
          ({
            String name,
            double volumeMl,
            int hours,
            int minutes,
            int dropFactor,
            int totalMinutes,
            double expectedMlPerHour,
            double expectedGttPerMinute,
            double expectedSecondsPerDrop,
          })
        >[
          (
            name: '100mL를 3시간 동안 20gtt 세트로 투여하면 5.4초마다 한 방울이다',
            volumeMl: 100,
            hours: 3,
            minutes: 0,
            dropFactor: 20,
            totalMinutes: 180,
            expectedMlPerHour: 33.333333333333336,
            expectedGttPerMinute: 11.11111111111111,
            expectedSecondsPerDrop: 5.4,
          ),
          (
            name: '1000mL를 8시간 동안 20gtt 세트로 투여한다',
            volumeMl: 1000,
            hours: 8,
            minutes: 0,
            dropFactor: 20,
            totalMinutes: 480,
            expectedMlPerHour: 125,
            expectedGttPerMinute: 41.666666666666664,
            expectedSecondsPerDrop: 1.44,
          ),
          (
            name: '500mL를 4시간 30분 동안 15gtt 세트로 투여한다',
            volumeMl: 500,
            hours: 4,
            minutes: 30,
            dropFactor: 15,
            totalMinutes: 270,
            expectedMlPerHour: 111.11111111111111,
            expectedGttPerMinute: 27.77777777777778,
            expectedSecondsPerDrop: 2.16,
          ),
          (
            name: '50mL를 30분 동안 60gtt 세트로 투여한다',
            volumeMl: 50,
            hours: 0,
            minutes: 30,
            dropFactor: 60,
            totalMinutes: 30,
            expectedMlPerHour: 100,
            expectedGttPerMinute: 100,
            expectedSecondsPerDrop: 0.6,
          ),
          (
            name: '1000mL를 24시간 동안 15gtt 세트로 투여한다',
            volumeMl: 1000,
            hours: 24,
            minutes: 0,
            dropFactor: 15,
            totalMinutes: 1440,
            expectedMlPerHour: 41.666666666666664,
            expectedGttPerMinute: 10.416666666666666,
            expectedSecondsPerDrop: 5.76,
          ),
          (
            name: '250mL를 1시간 30분 동안 10gtt 세트로 투여한다',
            volumeMl: 250,
            hours: 1,
            minutes: 30,
            dropFactor: 10,
            totalMinutes: 90,
            expectedMlPerHour: 166.66666666666666,
            expectedGttPerMinute: 27.77777777777778,
            expectedSecondsPerDrop: 2.16,
          ),
          (
            name: '500mL를 7시간 45분 동안 20gtt 세트로 투여한다',
            volumeMl: 500,
            hours: 7,
            minutes: 45,
            dropFactor: 20,
            totalMinutes: 465,
            expectedMlPerHour: 64.51612903225806,
            expectedGttPerMinute: 21.50537634408602,
            expectedSecondsPerDrop: 2.79,
          ),
          (
            name: '50mL를 15분 동안 10gtt 세트로 투여한다',
            volumeMl: 50,
            hours: 0,
            minutes: 15,
            dropFactor: 10,
            totalMinutes: 15,
            expectedMlPerHour: 200,
            expectedGttPerMinute: 33.333333333333336,
            expectedSecondsPerDrop: 1.8,
          ),
          (
            name: '100mL를 45분 동안 15gtt 세트로 투여한다',
            volumeMl: 100,
            hours: 0,
            minutes: 45,
            dropFactor: 15,
            totalMinutes: 45,
            expectedMlPerHour: 133.33333333333334,
            expectedGttPerMinute: 33.333333333333336,
            expectedSecondsPerDrop: 1.8,
          ),
          (
            name: '250mL를 1시간 동안 60gtt 세트로 투여한다',
            volumeMl: 250,
            hours: 1,
            minutes: 0,
            dropFactor: 60,
            totalMinutes: 60,
            expectedMlPerHour: 250,
            expectedGttPerMinute: 250,
            expectedSecondsPerDrop: 0.24,
          ),
          (
            name: '500mL를 2시간 30분 동안 10gtt 세트로 투여한다',
            volumeMl: 500,
            hours: 2,
            minutes: 30,
            dropFactor: 10,
            totalMinutes: 150,
            expectedMlPerHour: 200,
            expectedGttPerMinute: 33.333333333333336,
            expectedSecondsPerDrop: 1.8,
          ),
          (
            name: '1000mL를 12시간 동안 15gtt 세트로 투여한다',
            volumeMl: 1000,
            hours: 12,
            minutes: 0,
            dropFactor: 15,
            totalMinutes: 720,
            expectedMlPerHour: 83.33333333333333,
            expectedGttPerMinute: 20.833333333333332,
            expectedSecondsPerDrop: 2.88,
          ),
        ];

    for (final testCase in cases) {
      test(testCase.name, () {
        final totalMinutes = testCase.hours * 60 + testCase.minutes;
        final totalHours = totalMinutes / 60;
        final result = calculator.calculate(
          volumeMl: testCase.volumeMl,
          hours: testCase.hours,
          minutes: testCase.minutes,
          dropFactor: testCase.dropFactor,
        );

        expect(totalMinutes, testCase.totalMinutes);
        expect(
          result.mlPerHour,
          closeTo(testCase.expectedMlPerHour, tolerance),
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
          closeTo(60, tolerance),
          reason: '한 방울 간격과 분당 점적 수의 단위 관계',
        );
        expect(
          result.mlPerHour * totalHours,
          closeTo(testCase.volumeMl, tolerance),
          reason: '시간당 주입량과 전체 시간의 단위 관계',
        );
        expect(
          result.gttPerMinute * totalMinutes,
          closeTo(testCase.volumeMl * testCase.dropFactor, tolerance),
          reason: '분당 점적 수와 총 방울 수의 단위 관계',
        );
      });
    }

    test('표시용 정수 점적 수를 방울 간격 계산에 재사용하지 않는다', () {
      final result = calculator.calculate(
        volumeMl: 100,
        hours: 3,
        minutes: 0,
        dropFactor: 20,
      );

      expect(result.roundedDropsPerMinute, 11);
      expect(result.secondsPerDrop, closeTo(5.4, tolerance));
      expect(result.secondsPerDrop, isNot(closeTo(60 / 11, 1e-6)));
    });
  });

  group('InfusionCalculator 입력 검증', () {
    test('0, 음수, NaN, Infinity 수액량을 거부한다', () {
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
    });

    test('0시간 0분과 음수 시간 및 범위를 벗어난 분을 거부한다', () {
      for (final time in [
        (hours: 0, minutes: 0),
        (hours: -1, minutes: 0),
        (hours: 1, minutes: -1),
        (hours: 1, minutes: 60),
      ]) {
        expect(
          () => calculator.calculate(
            volumeMl: 100,
            hours: time.hours,
            minutes: time.minutes,
            dropFactor: 20,
          ),
          throwsArgumentError,
        );
      }
    });

    test('허용되지 않은 점적계수를 거부한다', () {
      for (final dropFactor in [0, -10, 1, 12, 30, 100]) {
        expect(
          () => calculator.calculate(
            volumeMl: 100,
            hours: 1,
            minutes: 0,
            dropFactor: dropFactor,
          ),
          throwsArgumentError,
        );
      }
    });

    test('10, 15, 20, 60 gtt/mL 점적계수를 허용한다', () {
      for (final dropFactor in [10, 15, 20, 60]) {
        expect(
          () => calculator.calculate(
            volumeMl: 100,
            hours: 1,
            minutes: 0,
            dropFactor: dropFactor,
          ),
          returnsNormally,
        );
      }
    });
  });
}
