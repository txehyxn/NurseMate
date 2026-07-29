class NonCoveredExam {
  const NonCoveredExam({
    required this.name,
    required this.price,
    this.description = '',
    this.note = '',
  });

  final String name;
  final int price;
  final String description;
  final String note;
}
