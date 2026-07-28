import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/data/drug_catalog.dart';
import 'package:nursemate/repositories/drug_preferences_repository.dart';
import 'package:nursemate/repositories/drug_repository.dart';
import 'package:nursemate/screens/drug_detail_screen.dart';
import 'package:nursemate/screens/drug_search_screen.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:nursemate/widgets/drug_image.dart';

void main() {
  testWidgets('메인 메뉴에서 약 검색 화면에 진입한다', (tester) async {
    final preferences = _MemoryDrugPreferencesRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(
          drugRepository: OfflineDrugRepository(),
          drugPreferencesRepository: preferences,
        ),
      ),
    );

    final menu = find.byKey(const Key('drugSearchMenu'));
    await tester.ensureVisible(menu);
    await tester.tap(menu);
    await tester.pumpAndSettle();

    expect(find.byType(DrugSearchScreen), findsOneWidget);
    expect(find.text('제품명, 성분명, 제조사를 입력하세요.'), findsOneWidget);
  });

  testWidgets('제품명과 한글·영문 성분명으로 즉시 검색한다', (tester) async {
    final preferences = _MemoryDrugPreferencesRepository();
    await _pumpSearch(tester, preferences);

    await tester.enterText(find.byKey(const Key('drugSearchField')), '타이레놀');
    await tester.pumpAndSettle();

    expect(find.text('타이레놀정 500mg'), findsOneWidget);
    expect(find.text('타이레놀8시간이알서방정 650mg'), findsOneWidget);
    expect(find.byKey(const Key('offlineDrugDataNotice')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('drugSearchField')),
      'ceftriaxone',
    );
    await tester.pumpAndSettle();

    expect(find.text('로세핀주사 1g'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('drugSearchField')), '아세트');
    await tester.pumpAndSettle();
    expect(find.text('타이레놀정 500mg'), findsOneWidget);
  });

  testWidgets('제조사 일부 입력으로 검색한다', (tester) async {
    final preferences = _MemoryDrugPreferencesRepository();
    await _pumpSearch(tester, preferences);

    await tester.enterText(find.byKey(const Key('drugSearchField')), '존슨');
    await tester.pumpAndSettle();

    expect(find.text('타이레놀정 500mg'), findsOneWidget);
    expect(find.text('한국존슨앤드존슨판매(유)'), findsWidgets);
  });

  testWidgets('검색 결과를 누르면 상세 정보와 간호 포인트를 표시한다', (tester) async {
    final preferences = _MemoryDrugPreferencesRepository();
    await _pumpSearch(tester, preferences);
    await _searchFor(tester, '타이레놀정 500');

    await tester.tap(find.byKey(const Key('drugCard_tylenol-500')));
    await tester.pumpAndSettle();

    expect(find.byType(DrugDetailScreen), findsOneWidget);
    expect(find.byType(DrugImage), findsOneWidget);
    expect(find.text('간호 포인트'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('효능·효과'), 250);
    expect(find.text('효능·효과'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('contraindicationSection')),
      300,
    );
    expect(find.text('금기사항'), findsOneWidget);
    expect(preferences.recentDrugIds, ['tylenol-500']);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('drugSearchField')), '');
    await tester.pumpAndSettle();

    expect(find.text('최근 조회'), findsOneWidget);
    expect(find.byKey(const Key('drugCard_tylenol-500')), findsOneWidget);
  });

  testWidgets('상세 화면에서 즐겨찾기를 저장하고 해제한다', (tester) async {
    final preferences = _MemoryDrugPreferencesRepository();
    await _pumpSearch(tester, preferences);
    await _searchFor(tester, '타이레놀정 500');
    await tester.tap(find.byKey(const Key('drugCard_tylenol-500')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('favoriteDrugButton')));
    await tester.pump();
    expect(preferences.favoriteIds, contains('tylenol-500'));
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('favoriteDrugButton')));
    await tester.pump();
    expect(preferences.favoriteIds, isNot(contains('tylenol-500')));
  });

  testWidgets('최근 검색어를 저장하고 누르면 즉시 다시 검색한다', (tester) async {
    final preferences = _MemoryDrugPreferencesRepository();
    await _pumpSearch(tester, preferences);
    await _searchFor(tester, '아세트아미노펜');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(preferences.recentSearches, ['아세트아미노펜']);

    await _pumpSearch(tester, preferences);
    final chip = find.byKey(const Key('recentSearch_아세트아미노펜'));
    expect(chip, findsOneWidget);
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.text('타이레놀정 500mg'), findsOneWidget);
  });

  test('최근 검색 10개와 최근 조회 20개 제한을 유지한다', () async {
    final preferences = _MemoryDrugPreferencesRepository();
    for (var index = 0; index < 12; index++) {
      await preferences.addRecentSearch('검색$index');
    }
    for (var index = 0; index < 22; index++) {
      await preferences.addRecentDrug('drug-$index');
    }

    expect(await preferences.getRecentSearches(), hasLength(10));
    expect(await preferences.getRecentDrugIds(), hasLength(20));
    expect((await preferences.getRecentSearches()).first, '검색11');
    expect((await preferences.getRecentDrugIds()).first, 'drug-21');
  });

  test('Repository는 확장 검색 필드를 지원하고 UI와 비동기로 분리된다', () async {
    final repository = OfflineDrugRepository(drugs: verifiedDrugCatalog);

    final byForm = await repository.search(
      const DrugSearchQuery(dosageForm: '주사'),
    );
    final byAtc = await repository.search(
      const DrugSearchQuery(atcCode: 'J01DD'),
    );
    final byEfficacy = await repository.search(
      const DrugSearchQuery(efficacy: '패혈증'),
    );

    expect(byForm.map((drug) => drug.id), contains('rocephin-1g'));
    expect(byAtc.map((drug) => drug.id), contains('rocephin-1g'));
    expect(byEfficacy.map((drug) => drug.id), contains('rocephin-1g'));
  });
}

Future<void> _pumpSearch(
  WidgetTester tester,
  DrugPreferencesRepository preferences,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DrugSearchScreen(
        key: UniqueKey(),
        drugRepository: OfflineDrugRepository(drugs: verifiedDrugCatalog),
        preferencesRepository: preferences,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _searchFor(WidgetTester tester, String query) async {
  await tester.enterText(find.byKey(const Key('drugSearchField')), query);
  await tester.pumpAndSettle();
}

class _MemoryDrugPreferencesRepository implements DrugPreferencesRepository {
  final List<String> recentSearches = [];
  final Set<String> favoriteIds = {};
  final List<String> recentDrugIds = [];

  @override
  Future<void> addRecentSearch(String query) async {
    final normalized = query.trim();
    recentSearches
      ..removeWhere((value) => value.toLowerCase() == normalized.toLowerCase())
      ..insert(0, normalized);
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
  }

  @override
  Future<List<String>> getRecentSearches() async => [...recentSearches];

  @override
  Future<Set<String>> getFavoriteIds() async => {...favoriteIds};

  @override
  Future<void> setFavorite(String drugId, {required bool isFavorite}) async {
    if (isFavorite) {
      favoriteIds.add(drugId);
    } else {
      favoriteIds.remove(drugId);
    }
  }

  @override
  Future<void> addRecentDrug(String drugId) async {
    recentDrugIds
      ..remove(drugId)
      ..insert(0, drugId);
    if (recentDrugIds.length > 20) {
      recentDrugIds.removeRange(20, recentDrugIds.length);
    }
  }

  @override
  Future<List<String>> getRecentDrugIds() async => [...recentDrugIds];
}
