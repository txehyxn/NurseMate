import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/screens/main_menu_screen.dart';

void main() {
  testWidgets('메인 메뉴의 약 검색을 누르면 약학정보원 상세검색을 연다', (tester) async {
    Uri? launchedUri;

    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(
          externalUrlLauncher: (uri) async {
            launchedUri = uri;
            return true;
          },
        ),
      ),
    );

    final menu = find.byKey(const Key('drugSearchMenu'));
    await tester.ensureVisible(menu);
    await tester.tap(menu);
    await tester.pump();

    expect(launchedUri, kKpicDrugSearchUri);
    expect(
      launchedUri.toString(),
      'https://health.kr/searchDrug/search_detail.asp',
    );
  });

  testWidgets('약학정보원 링크를 열지 못하면 오류 메시지를 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(externalUrlLauncher: (_) async => false),
      ),
    );

    final menu = find.byKey(const Key('drugSearchMenu'));
    await tester.ensureVisible(menu);
    await tester.tap(menu);
    await tester.pump();

    expect(find.text('약학정보원 페이지를 열지 못했습니다.'), findsOneWidget);
  });
}
