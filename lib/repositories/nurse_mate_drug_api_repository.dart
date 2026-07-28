import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/drug.dart';
import 'drug_repository.dart';

class NurseMateDrugApiRepository implements DrugRepository {
  NurseMateDrugApiRepository({
    http.Client? client,
    Uri? endpoint,
    this.timeout = const Duration(seconds: 8),
  }) : _client = client ?? http.Client(),
       _endpoint = endpoint ?? Uri.base.resolve('/api/drugs');

  final http.Client _client;
  final Uri _endpoint;
  final Duration timeout;

  @override
  DrugDataSource get lastSource => DrugDataSource.officialApi;

  @override
  Future<List<Drug>> search(DrugSearchQuery query) async {
    if (query.isEmpty) return const [];
    final uri = _endpoint.replace(
      queryParameters: {
        'q': query.text.trim(),
        if (query.efficacy?.trim().isNotEmpty == true)
          'efficacy': query.efficacy!.trim(),
        if (query.dosageForm?.trim().isNotEmpty == true)
          'dosageForm': query.dosageForm!.trim(),
        if (query.atcCode?.trim().isNotEmpty == true)
          'atcCode': query.atcCode!.trim(),
        if (query.insuranceCode?.trim().isNotEmpty == true)
          'insuranceCode': query.insuranceCode!.trim(),
      },
    );
    final json = await _getJson(uri);
    final items = json['items'];
    if (items is! List<Object?>) return const [];
    return items
        .whereType<Map>()
        .map((item) => Drug.fromJson(item.cast<String, Object?>()))
        .where((drug) => drug.id.isNotEmpty)
        .toList();
  }

  @override
  Future<Drug?> getById(String id) async {
    final uri = _endpoint.replace(queryParameters: {'id': id});
    final json = await _getJson(uri);
    final item = json['item'];
    if (item is! Map) return null;
    final drug = Drug.fromJson(item.cast<String, Object?>());
    return drug.id.isEmpty ? null : drug;
  }

  Future<Map<String, Object?>> _getJson(Uri uri) async {
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DrugApiException(
        'NurseMate 약 검색 서버 오류',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) {
      throw const DrugApiException('약 검색 응답 형식이 올바르지 않습니다.');
    }
    return decoded.cast<String, Object?>();
  }
}

class DrugApiException implements Exception {
  const DrugApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class FallbackDrugRepository implements DrugRepository {
  FallbackDrugRepository({required this.primary, required this.fallback});

  final DrugRepository primary;
  final DrugRepository fallback;
  DrugDataSource _lastSource = DrugDataSource.unknown;

  @override
  DrugDataSource get lastSource => _lastSource;

  @override
  Future<List<Drug>> search(DrugSearchQuery query) async {
    try {
      final results = await primary.search(query);
      _lastSource = primary.lastSource;
      return results;
    } on Object {
      final results = await fallback.search(query);
      _lastSource = fallback.lastSource;
      return results;
    }
  }

  @override
  Future<Drug?> getById(String id) async {
    try {
      final result = await primary.getById(id);
      if (result != null) {
        _lastSource = primary.lastSource;
        return result;
      }
      final fallbackResult = await fallback.getById(id);
      _lastSource = fallback.lastSource;
      return fallbackResult;
    } on Object {
      final result = await fallback.getById(id);
      _lastSource = fallback.lastSource;
      return result;
    }
  }
}
