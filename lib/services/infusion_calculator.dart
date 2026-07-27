import '../models/infusion_calculation_result.dart';

class InfusionCalculator {
  static const supportedDropFactors = <int>{10, 15, 20, 60};

  const InfusionCalculator();

  InfusionCalculationResult calculate({
    required double volumeMl,
    required int hours,
    required int minutes,
    required int dropFactor,
  }) {
    if (!volumeMl.isFinite || volumeMl <= 0) {
      throw ArgumentError.value(
        volumeMl,
        'volumeMl',
        '수액량은 0보다 큰 유한한 값이어야 합니다.',
      );
    }
    if (hours < 0) {
      throw ArgumentError.value(hours, 'hours', '시간은 0 이상이어야 합니다.');
    }
    if (minutes < 0 || minutes > 59) {
      throw ArgumentError.value(minutes, 'minutes', '분은 0~59 사이여야 합니다.');
    }
    if (hours == 0 && minutes == 0) {
      throw ArgumentError('주입 시간은 1분 이상이어야 합니다.');
    }
    if (!supportedDropFactors.contains(dropFactor)) {
      throw ArgumentError.value(
        dropFactor,
        'dropFactor',
        '지원하지 않는 수액세트 점적계수입니다.',
      );
    }

    final totalMinutes = hours * 60 + minutes;
    final mlPerHour = volumeMl * 60 / totalMinutes;
    final gttPerMinute = volumeMl * dropFactor / totalMinutes;
    final secondsPerDrop = totalMinutes * 60 / (volumeMl * dropFactor);

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
