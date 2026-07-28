import 'package:hive_flutter/hive_flutter.dart';

import '../models/duty_calendar_day.dart';
import '../models/duty_type.dart';

abstract interface class DutyRepository {
  Future<Map<String, DutyType>> getForMonth(DateTime month);

  Future<void> save(DateTime date, DutyType type);

  Future<void> delete(DateTime date);
}

class HiveDutyRepository implements DutyRepository {
  HiveDutyRepository._(this._box);

  static const String boxName = 'nurseMateDuties';

  final Box<String> _box;

  static Future<HiveDutyRepository> open() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.initFlutter();
    }
    final box = await Hive.openBox<String>(boxName);
    return HiveDutyRepository._(box);
  }

  @override
  Future<Map<String, DutyType>> getForMonth(DateTime month) async {
    final prefix = '${month.year}-${month.month.toString().padLeft(2, '0')}-';
    final duties = <String, DutyType>{};
    for (final key in _box.keys.whereType<String>()) {
      if (!key.startsWith(prefix)) continue;
      final type = DutyType.fromStorage(_box.get(key) ?? '');
      if (type != null) duties[key] = type;
    }
    return duties;
  }

  @override
  Future<void> save(DateTime date, DutyType type) {
    return _box.put(dutyDateKey(date), type.name);
  }

  @override
  Future<void> delete(DateTime date) {
    return _box.delete(dutyDateKey(date));
  }
}
