import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/models/non_covered_exam.dart';
import 'package:nursemate/widgets/app_search_bar.dart';
import 'package:nursemate/widgets/empty_state.dart';
import 'package:nursemate/widgets/exam_list_tile.dart';
import 'package:nursemate/widgets/price_text.dart';
import 'package:nursemate/widgets/section_header.dart';

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      theme: NurseMateTheme.light(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('공통 검색창이 입력 변경을 전달한다', (tester) async {
    var query = '';
    await tester.pumpWidget(
      app(
        AppSearchBar(
          text: query,
          hintText: '검사명을 검색하세요',
          onChanged: (value) => query = value,
        ),
      ),
    );

    await tester.enterText(find.byType(SearchBar), 'MRI');
    expect(query, 'MRI');
  });

  testWidgets('섹션·가격·빈 상태 공통 위젯을 표시한다', (tester) async {
    await tester.pumpWidget(
      app(
        const Column(
          children: [
            SectionHeader(title: '즐겨찾기', icon: Icons.star_rounded),
            PriceText(120000),
            EmptyState(
              icon: Icons.search_rounded,
              title: '검색 결과가 없습니다.',
              description: '다른 검색어를 입력해보세요.',
            ),
          ],
        ),
      ),
    );

    expect(find.text('즐겨찾기'), findsOneWidget);
    expect(find.text('120,000원'), findsOneWidget);
    expect(find.text('검색 결과가 없습니다.'), findsOneWidget);
    expect(find.text('다른 검색어를 입력해보세요.'), findsOneWidget);
  });

  testWidgets('검사 카드가 가격과 즐겨찾기 상태를 표시하고 동작한다', (tester) async {
    var tapped = false;
    var favoriteTapped = false;

    await tester.pumpWidget(
      app(
        ExamListTile(
          exam: const NonCoveredExam(name: 'MRI', price: 550000),
          favorite: true,
          onTap: () => tapped = true,
          onFavorite: () => favoriteTapped = true,
        ),
      ),
    );

    expect(find.text('MRI'), findsOneWidget);
    expect(find.text('550,000원'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);

    await tester.tap(find.text('MRI'));
    expect(tapped, isTrue);

    await tester.tap(find.byIcon(Icons.star_rounded));
    expect(favoriteTapped, isTrue);
  });
}
