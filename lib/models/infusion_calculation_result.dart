enum InfusionPace { tooSlow, onTarget, tooFast }

class InfusionCalculationResult {
  const InfusionCalculationResult({
    required this.mlPerHour,
    required this.gttPerMinute,
    required this.secondsPerDrop,
  });

  final double mlPerHour;
  final double gttPerMinute;
  final double secondsPerDrop;

  int get roundedDropsPerMinute => gttPerMinute.round();

  InfusionComparison compareWith(double actualGttPerMinute) {
    if (!actualGttPerMinute.isFinite || actualGttPerMinute < 0) {
      throw ArgumentError.value(
        actualGttPerMinute,
        'actualGttPerMinute',
        '실제 방울 수는 0 이상의 유한한 값이어야 합니다.',
      );
    }
    final difference = actualGttPerMinute - gttPerMinute;
    final differencePercent = difference / gttPerMinute * 100;
    final pace = differencePercent < -10
        ? InfusionPace.tooSlow
        : differencePercent > 10
        ? InfusionPace.tooFast
        : InfusionPace.onTarget;

    return InfusionComparison(
      actualGttPerMinute: actualGttPerMinute,
      targetGttPerMinute: gttPerMinute,
      differenceGttPerMinute: difference,
      differencePercent: differencePercent,
      pace: pace,
    );
  }
}

class InfusionComparison {
  const InfusionComparison({
    required this.actualGttPerMinute,
    required this.targetGttPerMinute,
    required this.differenceGttPerMinute,
    required this.differencePercent,
    required this.pace,
  });

  final double actualGttPerMinute;
  final double targetGttPerMinute;
  final double differenceGttPerMinute;
  final double differencePercent;
  final InfusionPace pace;
}
