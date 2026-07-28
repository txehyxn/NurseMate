import '../models/infusion_calculation_result.dart';

const double adultDropFactor = 20.0;

class InfusionCalculator {
  const InfusionCalculator();

  InfusionCalculationResult calculate({
    required double volumeMl,
    required double hours,
  }) {
    if (!volumeMl.isFinite || volumeMl <= 0) {
      throw ArgumentError.value(
        volumeMl,
        'volumeMl',
        '수액량은 0보다 큰 유한한 값이어야 합니다.',
      );
    }
    if (!hours.isFinite || hours <= 0) {
      throw ArgumentError.value(hours, 'hours', '시간은 0보다 큰 유한한 값이어야 합니다.');
    }

    final totalMinutes = hours * 60.0;
    final mlPerHour = volumeMl / hours;
    final gttPerMinute = (volumeMl * adultDropFactor) / totalMinutes;
    final secondsPerDrop = 60.0 / gttPerMinute;

    if (![mlPerHour, gttPerMinute, secondsPerDrop].every((v) => v.isFinite)) {
      throw StateError('계산할 수 없는 입력값입니다.');
    }

    return InfusionCalculationResult(
      mlPerHour: mlPerHour,
      gttPerMinute: gttPerMinute,
      secondsPerDrop: secondsPerDrop,
    );
  }
}
