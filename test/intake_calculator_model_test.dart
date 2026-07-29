import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/models/intake_calculator_model.dart';

void main() {
  test('일반식 섭취 비율을 cc로 환산해 합산한다', () {
    final percentages = const {
      'main': 50,
      'soup': 50,
      'vegetable': 100,
      'protein': 50,
    };
    final amounts = IntakeCalculatorModel.calculateItems(
      mealType: MealType.regular,
      percentages: percentages,
    );
    final total = IntakeCalculatorModel.calculateTotal(
      mealType: MealType.regular,
      percentages: percentages,
    );

    expect(amounts, {'main': 100, 'soup': 100, 'vegetable': 50, 'protein': 20});
    expect(total, 270);
  });

  test('식사 종류에 따라 첫 번째 음식과 기준량만 변경된다', () {
    final regular = IntakeCalculatorModel.itemsFor(MealType.regular);
    final porridge = IntakeCalculatorModel.itemsFor(MealType.porridge);
    final thinPorridge = IntakeCalculatorModel.itemsFor(MealType.thinPorridge);

    expect((regular.first.name, regular.first.standardVolumeCc), ('밥', 200));
    expect((porridge.first.name, porridge.first.standardVolumeCc), ('죽', 250));
    expect(
      (thinPorridge.first.name, thinPorridge.first.standardVolumeCc),
      ('미음', 200),
    );
    expect(regular.skip(1).map((item) => item.standardVolumeCc), [200, 50, 40]);
    expect(porridge.skip(1).map((item) => item.standardVolumeCc), [
      200,
      50,
      40,
    ]);
  });

  test('지원하는 비율은 0부터 100까지 10 단위다', () {
    expect(IntakeCalculatorModel.percentages, [
      0,
      10,
      20,
      30,
      40,
      50,
      60,
      70,
      80,
      90,
      100,
    ]);
  });
}
