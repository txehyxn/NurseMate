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
}
