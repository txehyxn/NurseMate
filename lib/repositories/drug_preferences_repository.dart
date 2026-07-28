import 'package:hive_flutter/hive_flutter.dart';

abstract interface class DrugPreferencesRepository {
  Future<List<String>> getRecentSearches();

  Future<void> addRecentSearch(String query);

  Future<Set<String>> getFavoriteIds();

  Future<void> setFavorite(String drugId, {required bool isFavorite});

  Future<List<String>> getRecentDrugIds();

  Future<void> addRecentDrug(String drugId);
}

class HiveDrugPreferencesRepository implements DrugPreferencesRepository {
  HiveDrugPreferencesRepository._(this._box);

  static const String _boxName = 'nurseMateDrugPreferences';
  static const String _recentSearchesKey = 'recentSearches';
  static const String _favoriteIdsKey = 'favoriteIds';
  static const String _recentDrugIdsKey = 'recentDrugIds';

  final Box<List<dynamic>> _box;

  static Future<HiveDrugPreferencesRepository> open() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.initFlutter();
    }
    final box = await Hive.openBox<List<dynamic>>(_boxName);
    return HiveDrugPreferencesRepository._(box);
  }

  @override
  Future<List<String>> getRecentSearches() async {
    return _readStrings(_recentSearchesKey);
  }

  @override
  Future<void> addRecentSearch(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    final values = _readStrings(_recentSearchesKey)
      ..removeWhere((value) => value.toLowerCase() == normalized.toLowerCase())
      ..insert(0, normalized);
    await _box.put(_recentSearchesKey, values.take(10).toList());
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    return _readStrings(_favoriteIdsKey).toSet();
  }

  @override
  Future<void> setFavorite(String drugId, {required bool isFavorite}) async {
    final values = _readStrings(_favoriteIdsKey).toSet();
    if (isFavorite) {
      values.add(drugId);
    } else {
      values.remove(drugId);
    }
    await _box.put(_favoriteIdsKey, values.toList());
  }

  @override
  Future<List<String>> getRecentDrugIds() async {
    return _readStrings(_recentDrugIdsKey);
  }

  @override
  Future<void> addRecentDrug(String drugId) async {
    final values = _readStrings(_recentDrugIdsKey)
      ..remove(drugId)
      ..insert(0, drugId);
    await _box.put(_recentDrugIdsKey, values.take(20).toList());
  }

  List<String> _readStrings(String key) {
    return (_box.get(key) ?? const []).whereType<String>().toList();
  }
}
