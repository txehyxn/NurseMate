import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:url_launcher/link.dart';

void main() {
  testWidgets('메인 메뉴의 약 검색은 현재 탭에서 여는 실제 웹 링크다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

    final menu = find.byKey(const Key('drugSearchMenu'));
    await tester.ensureVisible(menu);

    final link = tester.widget<Link>(find.byType(Link));
    expect(link.uri, kKpicDrugSearchUri);
    expect(link.target, LinkTarget.self);
    expect(
      link.uri.toString(),
      'https://health.kr/searchDrug/search_detail.asp',
    );
    expect(menu, findsOneWidget);
  });
}
