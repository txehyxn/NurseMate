import '../data/drug_catalog.dart';
import '../models/drug.dart';

enum DrugDataSource { unknown, officialApi, offlineSample }

class DrugSearchQuery {
  const DrugSearchQuery({
    this.text = '',
    this.efficacy,
    this.dosageForm,
    this.atcCode,
    this.insuranceCode,
  });

  final String text;
  final String? efficacy;
  final String? dosageForm;
  final String? atcCode;
  final String? insuranceCode;

  bool get isEmpty {
    return text.trim().isEmpty &&
        _isBlank(efficacy) &&
        _isBlank(dosageForm) &&
        _isBlank(atcCode) &&
        _isBlank(insuranceCode);
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;
}

abstract interface class DrugRepository {
  DrugDataSource get lastSource;

  Future<List<Drug>> search(DrugSearchQuery query);

  Future<Drug?> getById(String id);
}

class OfflineDrugRepository implements DrugRepository {
  OfflineDrugRepository({List<Drug>? drugs})
    : _drugs = List.unmodifiable(drugs ?? verifiedDrugCatalog);

  final List<Drug> _drugs;

  @override
  DrugDataSource get lastSource => DrugDataSource.offlineSample;

  @override
  Future<List<Drug>> search(DrugSearchQuery query) async {
    if (query.isEmpty) return const [];
    final text = _normalize(query.text);
    return _drugs.where((drug) {
      final matchesText =
          text.isEmpty ||
          [
            drug.productName,
            drug.ingredientKor,
            drug.ingredientEng,
            drug.manufacturer,
          ].any((value) => _normalize(value).contains(text));
      return matchesText &&
          _contains(drug.efficacy, query.efficacy) &&
          _contains(drug.dosageForm, query.dosageForm) &&
          _contains(drug.atcCode ?? '', query.atcCode) &&
          _contains(drug.insuranceCode ?? '', query.insuranceCode);
    }).toList();
  }

  @override
  Future<Drug?> getById(String id) async {
    for (final drug in _drugs) {
      if (drug.id == id) return drug;
    }
    return null;
  }

  static bool _contains(String value, String? query) {
    if (query == null || query.trim().isEmpty) return true;
    return _normalize(value).contains(_normalize(query));
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }
}
