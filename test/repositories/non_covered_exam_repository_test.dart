import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/repositories/non_covered_exam_repository.dart';

void main() {
  const repository = LocalNonCoveredExamRepository();

  test('각 비급여 검사 카테고리 개수를 반환한다', () {
    expect(repository.getUltrasound(), hasLength(16));
    expect(repository.getMRI(), hasLength(17));
    expect(repository.getCT(), isEmpty);
    expect(repository.getProcedure(), hasLength(15));
    expect(repository.getEtc(), hasLength(35));
  });

  test('전체 비급여 검사 83개를 반환한다', () {
    expect(repository.getAll(), hasLength(83));
    expect(
      repository.getAll().length,
      repository.getUltrasound().length +
          repository.getMRI().length +
          repository.getCT().length +
          repository.getProcedure().length +
          repository.getEtc().length,
    );
  });
}
