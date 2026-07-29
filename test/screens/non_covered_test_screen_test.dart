import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/models/non_covered_exam.dart';
import 'package:nursemate/repositories/non_covered_exam_repository.dart';
import 'package:nursemate/screens/non_covered_exam_detail_screen.dart';
import 'package:nursemate/screens/non_covered_exam_screen.dart';
import 'package:nursemate/screens/non_covered_test_screen.dart';
import 'package:nursemate/services/non_covered_exam_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Size size = const Size(430, 900),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const NonCoveredTestScreen(),
      ),
    );
  }

  testWidgets('비급여 검사 카테고리 5개를 모바일에 표시한다', (tester) async {
    await pumpScreen(tester);

    expect(find.text('비급여 검사'), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.text('검사명을 검색하세요'), findsOneWidget);

    for (final id in const ['ultrasound', 'mri', 'procedure', 'etc', 'ct']) {
      expect(find.byKey(Key('nonCoveredCategory-$id')), findsOneWidget);
    }

    final ultrasound = tester.getTopLeft(
      find.byKey(const Key('nonCoveredCategory-ultrasound')),
    );
    final mri = tester.getTopLeft(
      find.byKey(const Key('nonCoveredCategory-mri')),
    );
    final procedure = tester.getTopLeft(
      find.byKey(const Key('nonCoveredCategory-procedure')),
    );
    expect(mri.dy, greaterThan(ultrasound.dy));
    expect(procedure.dy, greaterThan(mri.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('전체 검사명을 contains 방식으로 실시간 검색한다', (tester) async {
    await pumpScreen(tester);

    final searchBar = find.byKey(const Key('nonCoveredTestSearchBar'));
    await tester.enterText(searchBar, 'mri');
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('nonCoveredGlobalSearchResults')),
      findsOneWidget,
    );
    expect(find.textContaining('MRI'), findsWidgets);
    expect(
      find.byKey(const Key('nonCoveredCategory-ultrasound')),
      findsNothing,
    );

    await tester.enterText(searchBar, 'staphylococcus pcr');
    await tester.pumpAndSettle();
    expect(find.text('Staphylococcus PCR'), findsOneWidget);
    expect(find.textContaining('MRI'), findsNothing);

    await tester.enterText(searchBar, '');
    await tester.pumpAndSettle();
    for (final id in const ['ultrasound', 'mri', 'procedure', 'etc', 'ct']) {
      expect(find.byKey(Key('nonCoveredCategory-$id')), findsOneWidget);
    }
  });

  testWidgets('카테고리 검색 결과가 없으면 빈 결과 안내를 표시한다', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('nonCoveredTestSearchBar')),
      'PET',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('nonCoveredEmptySearchResult')),
      findsOneWidget,
    );
    expect(find.text('검색 결과가 없습니다.'), findsOneWidget);
  });

  testWidgets('각 카테고리를 해당 검사 데이터 목록 화면에 연결한다', (tester) async {
    const repository = LocalNonCoveredExamRepository();
    final cases = <({String id, String title, List<NonCoveredExam> exams})>[
      (id: 'ultrasound', title: '초음파', exams: repository.getUltrasound()),
      (id: 'mri', title: 'MRI', exams: repository.getMRI()),
      (id: 'procedure', title: '시술', exams: repository.getProcedure()),
      (id: 'etc', title: '기타', exams: repository.getEtc()),
      (id: 'ct', title: 'CT', exams: repository.getCT()),
    ];

    for (final testCase in cases) {
      await pumpScreen(tester);
      final category = find.byKey(Key('nonCoveredCategory-${testCase.id}'));
      await tester.ensureVisible(category);
      await tester.tap(category);
      await tester.pumpAndSettle();

      final destination = tester.widget<NonCoveredExamScreen>(
        find.byType(NonCoveredExamScreen),
      );
      expect(destination.title, testCase.title);
      expect(destination.exams, same(testCase.exams));

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('태블릿에서는 카테고리 카드를 2열로 배치한다', (tester) async {
    await pumpScreen(tester, size: const Size(900, 900));

    final first = tester.getTopLeft(
      find.byKey(const Key('nonCoveredCategory-ultrasound')),
    );
    final second = tester.getTopLeft(
      find.byKey(const Key('nonCoveredCategory-mri')),
    );
    final third = tester.getTopLeft(
      find.byKey(const Key('nonCoveredCategory-procedure')),
    );

    expect(second.dy, closeTo(first.dy, 0.1));
    expect(second.dx, greaterThan(first.dx));
    expect(third.dy, greaterThan(first.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('저장된 최근 조회와 즐겨찾기 섹션에서 상세 화면을 연다', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      recentNonCoveredExamsKey: <String>['단순초음파(guided)'],
      favoriteNonCoveredExamsKey: <String>[
        '두경부 MRI (Brain/Facial/Orbital/Temporal/Neck 등)',
      ],
    });
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('nonCoveredRecentSection')), findsOneWidget);
    expect(find.byKey(const Key('nonCoveredFavoriteSection')), findsOneWidget);
    expect(find.text('최근 조회'), findsOneWidget);
    expect(find.text('즐겨찾기'), findsOneWidget);

    await tester.tap(find.text('단순초음파(guided)'));
    await tester.pumpAndSettle();
    expect(find.byType(NonCoveredExamDetailScreen), findsOneWidget);
    expect(find.text('120,000원'), findsOneWidget);
  });
}
