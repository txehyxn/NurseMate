enum MealType {
  regular('일반식', '🍚'),
  porridge('죽', '🥣'),
  thinPorridge('미음', '🥣');

  const MealType(this.label, this.emoji);

  final String label;
  final String emoji;
}

class IntakeFoodItem {
  const IntakeFoodItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.standardVolumeCc,
    required this.referenceLabel,
  });

  final String id;
  final String name;
  final String emoji;
  final int standardVolumeCc;
  final String referenceLabel;
}

abstract final class IntakeCalculatorModel {
  static const percentages = <int>[0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  static List<IntakeFoodItem> itemsFor(MealType mealType) => [
    switch (mealType) {
      MealType.regular => const IntakeFoodItem(
        id: 'main',
        name: '밥',
        emoji: '🍚',
        standardVolumeCc: 200,
        referenceLabel: '300g · 계산기준 200cc',
      ),
      MealType.porridge => const IntakeFoodItem(
        id: 'main',
        name: '죽',
        emoji: '🥣',
        standardVolumeCc: 250,
        referenceLabel: '300g · 계산기준 250cc',
      ),
      MealType.thinPorridge => const IntakeFoodItem(
        id: 'main',
        name: '미음',
        emoji: '🥣',
        standardVolumeCc: 200,
        referenceLabel: '200cc · 계산기준 200cc',
      ),
    },
    const IntakeFoodItem(
      id: 'soup',
      name: '국',
      emoji: '🍲',
      standardVolumeCc: 200,
      referenceLabel: '계산기준 200cc',
    ),
    const IntakeFoodItem(
      id: 'vegetable',
      name: '채소반찬',
      emoji: '🥬',
      standardVolumeCc: 50,
      referenceLabel: '계산기준 50cc',
    ),
    const IntakeFoodItem(
      id: 'protein',
      name: '육류·생선반찬',
      emoji: '🥩',
      standardVolumeCc: 40,
      referenceLabel: '계산기준 40cc',
    ),
  ];

  static int calculateItem({
    required IntakeFoodItem item,
    required int percentage,
  }) {
    return (item.standardVolumeCc * percentage / 100).round();
  }

  static int calculateTotal({
    required MealType mealType,
    required Map<String, int> percentages,
  }) {
    return calculateItems(
      mealType: mealType,
      percentages: percentages,
    ).values.fold(0, (total, value) => total + value);
  }

  static Map<String, int> calculateItems({
    required MealType mealType,
    required Map<String, int> percentages,
  }) {
    return Map.unmodifiable({
      for (final item in itemsFor(mealType))
        item.id: calculateItem(
          item: item,
          percentage: percentages[item.id] ?? 0,
        ),
    });
  }
}
