import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/services/non_covered_exam_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('즐겨찾기를 등록하고 해제한다', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = NonCoveredExamHistoryService(preferences);

    expect(await service.toggleFavorite('MRI'), isTrue);
    expect(await service.loadFavorites(), <String>['MRI']);
    expect(preferences.getStringList(favoriteNonCoveredExamsKey), <String>[
      'MRI',
    ]);

    expect(await service.toggleFavorite('MRI'), isFalse);
    expect(await service.loadFavorites(), isEmpty);
  });

  test('최근 조회는 최대 10개만 최신순으로 유지한다', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = NonCoveredExamHistoryService(preferences);

    for (var index = 0; index < 12; index++) {
      await service.addRecent('검사 $index');
    }

    final recent = await service.loadRecent();
    expect(recent, hasLength(maxRecentNonCoveredExams));
    expect(recent.first, '검사 11');
    expect(recent.last, '검사 2');
  });

  test('최근 조회 중복 항목은 제거한 뒤 맨 앞으로 이동한다', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = NonCoveredExamHistoryService(preferences);

    await service.addRecent('MRI');
    await service.addRecent('CT');
    await service.addRecent('초음파');
    await service.addRecent('MRI');

    expect(await service.loadRecent(), <String>['MRI', '초음파', 'CT']);
  });
}
