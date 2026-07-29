import 'package:shared_preferences/shared_preferences.dart';

const favoriteNonCoveredExamsKey = 'favorite_non_covered_exams';
const recentNonCoveredExamsKey = 'recent_non_covered_exams';
const maxRecentNonCoveredExams = 10;

class NonCoveredExamHistoryService {
  NonCoveredExamHistoryService([this._preferences]);

  SharedPreferences? _preferences;

  Future<List<String>> loadFavorites() async {
    final preferences = await _getPreferences();
    return List<String>.unmodifiable(
      preferences.getStringList(favoriteNonCoveredExamsKey) ?? const <String>[],
    );
  }

  Future<bool> isFavorite(String examName) async {
    final favorites = await loadFavorites();
    return favorites.contains(examName);
  }

  Future<bool> toggleFavorite(String examName) async {
    final preferences = await _getPreferences();
    final favorites = List<String>.of(
      preferences.getStringList(favoriteNonCoveredExamsKey) ?? const <String>[],
    );
    final isNowFavorite = !favorites.remove(examName);

    if (isNowFavorite) {
      favorites.add(examName);
    }
    await preferences.setStringList(favoriteNonCoveredExamsKey, favorites);
    return isNowFavorite;
  }

  Future<List<String>> loadRecent() async {
    final preferences = await _getPreferences();
    return List<String>.unmodifiable(
      preferences.getStringList(recentNonCoveredExamsKey) ?? const <String>[],
    );
  }

  Future<void> addRecent(String examName) async {
    final preferences = await _getPreferences();
    final recent = List<String>.of(
      preferences.getStringList(recentNonCoveredExamsKey) ?? const <String>[],
    )..remove(examName);

    recent.insert(0, examName);
    if (recent.length > maxRecentNonCoveredExams) {
      recent.removeRange(maxRecentNonCoveredExams, recent.length);
    }
    await preferences.setStringList(recentNonCoveredExamsKey, recent);
  }

  Future<SharedPreferences> _getPreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }
}
