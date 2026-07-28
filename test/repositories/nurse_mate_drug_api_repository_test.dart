import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nursemate/repositories/drug_repository.dart';
import 'package:nursemate/repositories/nurse_mate_drug_api_repository.dart';

void main() {
  test('NurseMate API 검색 결과를 Drug 모델로 변환한다', () async {
    late Uri requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response(
        jsonEncode({
          'items': [
            {
              'id': 'drug-1',
              'productName': '테스트주',
              'ingredientKor': '테스트성분',
              'ingredientEng': 'Test Ingredient',
              'manufacturer': '테스트제약',
              'category': '테스트분류',
              'dosageForm': '주사제',
              'administrationRoute': '정맥',
              'efficacy': '테스트 효능',
              'dosage': '처방에 따라 투여',
              'nursingPoints': {
                'beforeAdministration': <String>[],
                'afterAdministration': <String>[],
                'commonAdverseEffects': <String>[],
                'cautionPatients': <String>[],
              },
              'contraindication': '테스트 금기',
              'precaution': '테스트 주의',
              'interaction': '테스트 상호작용',
              'adverseEffect': '테스트 부작용',
              'storage': '실온 보관',
              'insuranceCode': '123456789',
              'atcCode': 'A00AA00',
              'isPrescription': true,
              'imageUrl': 'https://example.com/drug.png',
              'source': '식품의약품안전처 의약품 허가정보',
              'sourceUrl': 'https://nedrug.mfds.go.kr/',
              'updatedAt': '2026-07-28T00:00:00.000Z',
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final repository = NurseMateDrugApiRepository(
      client: client,
      endpoint: Uri.parse('https://nursemate.example/api/drugs'),
    );

    final results = await repository.search(
      const DrugSearchQuery(text: '테스트', dosageForm: '주사'),
    );

    expect(requestedUri.queryParameters['q'], '테스트');
    expect(requestedUri.queryParameters['dosageForm'], '주사');
    expect(results, hasLength(1));
    expect(results.single.productName, '테스트주');
    expect(results.single.ingredientEng, 'Test Ingredient');
    expect(results.single.isPrescription, isTrue);
    expect(results.single.imageUrl, 'https://example.com/drug.png');
  });

  test('상세 조회는 품목코드를 id 파라미터로 전달한다', () async {
    late Uri requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response(
        jsonEncode({
          'item': {
            'id': 'drug-1',
            'productName': '테스트정',
            'ingredientKor': '테스트성분',
            'ingredientEng': 'Test Ingredient',
            'manufacturer': '테스트제약',
            'category': '테스트분류',
            'dosageForm': '정제',
            'administrationRoute': '경구',
            'efficacy': '정보 없음',
            'dosage': '정보 없음',
            'nursingPoints': <String, Object?>{},
            'contraindication': '정보 없음',
            'precaution': '정보 없음',
            'interaction': '정보 없음',
            'adverseEffect': '정보 없음',
            'storage': '정보 없음',
            'isPrescription': false,
            'source': '식품의약품안전처 의약품 허가정보',
            'sourceUrl': 'https://nedrug.mfds.go.kr/',
            'updatedAt': '2026-07-28T00:00:00.000Z',
          },
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final repository = NurseMateDrugApiRepository(
      client: client,
      endpoint: Uri.parse('https://nursemate.example/api/drugs'),
    );

    final result = await repository.getById('drug-1');

    expect(requestedUri.queryParameters, {'id': 'drug-1'});
    expect(result?.productName, '테스트정');
  });

  test('공식 API 오류 시 샘플 Repository로 대체한다', () async {
    final primary = NurseMateDrugApiRepository(
      client: MockClient((_) async => http.Response('unavailable', 503)),
      endpoint: Uri.parse('https://nursemate.example/api/drugs'),
    );
    final repository = FallbackDrugRepository(
      primary: primary,
      fallback: OfflineDrugRepository(),
    );

    final results = await repository.search(
      const DrugSearchQuery(text: '타이레놀'),
    );

    expect(results.map((drug) => drug.id), contains('tylenol-500'));
    expect(repository.lastSource, DrugDataSource.offlineSample);
  });
}
