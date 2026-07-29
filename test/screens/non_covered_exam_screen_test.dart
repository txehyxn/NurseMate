import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/models/non_covered_exam.dart';
import 'package:nursemate/screens/non_covered_exam_detail_screen.dart';
import 'package:nursemate/screens/non_covered_exam_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  const exams = <NonCoveredExam>[
    NonCoveredExam(name: 'Brain MRI', price: 1200000),
    NonCoveredExam(name: '척추 MRI', price: 98000),
    NonCoveredExam(name: '혈액검사', price: 700),
  ];

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<NonCoveredExam> data = exams,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: NonCoveredExamScreen(title: 'MRI', exams: data),
      ),
    );
  }

  testWidgets('제목과 검사명, 천 단위 콤마 가격을 표시한다', (tester) async {
    await pumpScreen(tester);

    expect(find.text('MRI'), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.text('Brain MRI'), findsOneWidget);
    expect(find.text('1,200,000원'), findsOneWidget);
    expect(find.text('98,000원'), findsOneWidget);
    expect(find.text('700원'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('검사명을 대소문자 구분 없이 실시간 필터링한다', (tester) async {
    await pumpScreen(tester);

    final searchBar = find.byKey(const Key('nonCoveredExamSearchBar'));
    await tester.enterText(searchBar, 'mri');
    await tester.pumpAndSettle();

    expect(find.text('Brain MRI'), findsOneWidget);
    expect(find.text('척추 MRI'), findsOneWidget);
    expect(find.text('혈액검사'), findsNothing);

    await tester.enterText(searchBar, '척추');
    await tester.pumpAndSettle();
    expect(find.text('Brain MRI'), findsNothing);
    expect(find.text('척추 MRI'), findsOneWidget);

    await tester.enterText(searchBar, '');
    await tester.pumpAndSettle();
    expect(find.text('Brain MRI'), findsOneWidget);
    expect(find.text('혈액검사'), findsOneWidget);
  });

  testWidgets('검색 결과가 없으면 빈 결과 문구를 표시한다', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('nonCoveredExamSearchBar')),
      '초음파',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('nonCoveredExamEmptyResult')), findsOneWidget);
    expect(find.text('검색 결과가 없습니다.'), findsOneWidget);
    expect(find.byKey(const Key('nonCoveredExamList')), findsNothing);
  });

  testWidgets('전달된 검사 목록이 비어 있으면 빈 결과 문구를 표시한다', (tester) async {
    await pumpScreen(tester, data: const <NonCoveredExam>[]);

    expect(find.text('검색 결과가 없습니다.'), findsOneWidget);
    expect(find.byKey(const Key('nonCoveredExamList')), findsNothing);
  });

  testWidgets('검사 카드를 누르면 해당 검사 상세 화면으로 이동한다', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Brain MRI'));
    await tester.pumpAndSettle();

    final detail = tester.widget<NonCoveredExamDetailScreen>(
      find.byType(NonCoveredExamDetailScreen),
    );
    expect(detail.exam, same(exams.first));
    expect(find.text('1,200,000원'), findsOneWidget);
  });
}
