import 'package:shared_preferences/shared_preferences.dart';

import '../models/dday_setting.dart';

const ddayTitleKey = 'dday.title';
const ddayDateKey = 'dday.date';
const ddayCalculationModeKey = 'dday.calculationMode';
const ddayCardColorKey = 'dday.cardColor';

class DDaySettingsService {
  const DDaySettingsService(this.preferences);

  final SharedPreferences preferences;

  static Future<DDaySettingsService> open() async {
    return DDaySettingsService(await SharedPreferences.getInstance());
  }

  DDaySetting load({required DateTime today}) {
    final fallback = DDaySetting.defaultFor(today);
    final savedDate = DateTime.tryParse(
      preferences.getString(ddayDateKey) ?? '',
    );
    final savedMode = _enumByName(
      DDayCalculationMode.values,
      preferences.getString(ddayCalculationModeKey),
    );
    final savedColor = _enumByName(
      DDayCardColor.values,
      preferences.getString(ddayCardColorKey),
    );

    return DDaySetting(
      title: preferences.getString(ddayTitleKey)?.trim().isNotEmpty == true
          ? preferences.getString(ddayTitleKey)!.trim()
          : fallback.title,
      date: savedDate ?? fallback.date,
      calculationMode: savedMode ?? fallback.calculationMode,
      cardColor: savedColor ?? fallback.cardColor,
    );
  }

  Future<bool> save(DDaySetting setting) async {
    final results = await Future.wait([
      preferences.setString(ddayTitleKey, setting.title.trim()),
      preferences.setString(ddayDateKey, setting.date.toIso8601String()),
      preferences.setString(
        ddayCalculationModeKey,
        setting.calculationMode.name,
      ),
      preferences.setString(ddayCardColorKey, setting.cardColor.name),
    ]);
    return results.every((didSave) => didSave);
  }

  T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
