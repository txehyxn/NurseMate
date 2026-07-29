import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/services/checklist_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('DAY, EVENING, NIGHT 체크 상태를 각각 독립적으로 저장한다', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = ChecklistService(preferences);

    await service.saveCompleted(ChecklistShift.day, const ['day_item']);
    await service.saveCompleted(ChecklistShift.evening, const ['evening_item']);
    await service.saveCompleted(ChecklistShift.night, const ['night_item']);

    expect(await service.loadCompleted(ChecklistShift.day), {'day_item'});
    expect(await service.loadCompleted(ChecklistShift.evening), {
      'evening_item',
    });
    expect(await service.loadCompleted(ChecklistShift.night), {'night_item'});
  });

  test('특정 근무의 체크만 전체 해제한다', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = ChecklistService(preferences);

    await service.saveCompleted(ChecklistShift.day, const ['day_item']);
    await service.saveCompleted(ChecklistShift.evening, const ['evening_item']);
    await service.clearCompleted(ChecklistShift.day);

    expect(await service.loadCompleted(ChecklistShift.day), isEmpty);
    expect(await service.loadCompleted(ChecklistShift.evening), {
      'evening_item',
    });
  });
}
