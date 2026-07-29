import 'package:shared_preferences/shared_preferences.dart';

const dayChecklistCompletedKey = 'day_checklist_completed_v1';
const eveningChecklistCompletedKey = 'evening_checklist_completed_v1';
const nightChecklistCompletedKey = 'night_checklist_completed_v1';

enum ChecklistShift { day, evening, night }

class ChecklistService {
  ChecklistService([this._preferences]);

  SharedPreferences? _preferences;

  Future<Set<String>> loadCompleted(ChecklistShift shift) async {
    final preferences = await _getPreferences();
    return (preferences.getStringList(_keyFor(shift)) ?? const <String>[])
        .toSet();
  }

  Future<void> saveCompleted(
    ChecklistShift shift,
    Iterable<String> completedIds,
  ) async {
    final preferences = await _getPreferences();
    await preferences.setStringList(_keyFor(shift), completedIds.toList());
  }

  Future<void> clearCompleted(ChecklistShift shift) async {
    final preferences = await _getPreferences();
    await preferences.setStringList(_keyFor(shift), const <String>[]);
  }

  Future<SharedPreferences> _getPreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  String _keyFor(ChecklistShift shift) {
    return switch (shift) {
      ChecklistShift.day => dayChecklistCompletedKey,
      ChecklistShift.evening => eveningChecklistCompletedKey,
      ChecklistShift.night => nightChecklistCompletedKey,
    };
  }
}
