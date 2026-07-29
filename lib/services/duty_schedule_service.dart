import 'package:shared_preferences/shared_preferences.dart';

import '../models/duty_calendar_day.dart';
import '../models/duty_schedule.dart';

class DutyScheduleService {
  DutyScheduleService(this.preferences);

  static const storageKey = 'duty.schedules.v1';

  final SharedPreferences preferences;

  static Future<DutyScheduleService> open() async {
    return DutyScheduleService(await SharedPreferences.getInstance());
  }

  Map<String, DutyDaySchedule> loadAll() {
    return decodeDutySchedules(preferences.getString(storageKey));
  }

  Map<String, DutyDaySchedule> loadMonth(DateTime month) {
    final prefix = '${month.year}-${month.month.toString().padLeft(2, '0')}-';
    return Map.fromEntries(
      loadAll().entries.where((entry) => entry.key.startsWith(prefix)),
    );
  }

  Future<bool> save(DateTime date, DutyDaySchedule schedule) {
    final schedules = Map<String, DutyDaySchedule>.from(loadAll());
    final key = dutyDateKey(date);
    if (schedule.isEmpty) {
      schedules.remove(key);
    } else {
      schedules[key] = schedule;
    }
    return preferences.setString(storageKey, encodeDutySchedules(schedules));
  }

  Future<bool> delete(DateTime date) {
    return save(date, const DutyDaySchedule());
  }
}
