import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

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

  testWidgets('질환별 검색은 서울아산병원 질환백과를 기본 브라우저로 연다', (tester) async {
    Uri? launchedUri;
    LaunchMode? launchMode;
    await tester.pumpWidget(
      MaterialApp(
        home: MainMenuScreen(
          diseaseUrlLauncher: (uri, mode) async {
            launchedUri = uri;
            launchMode = mode;
            return true;
          },
        ),
      ),
    );

    final menu = find.byKey(const Key('diseaseSearchMenu'));
    await tester.ensureVisible(menu);
    final action = tester.widget<InkWell>(
      find.descendant(of: menu, matching: find.byType(InkWell)),
    );
    action.onTap!();
    await tester.pump();

    expect(launchedUri, kAsanDiseaseEncyclopediaUri);
    expect(
      launchedUri.toString(),
      'https://www.amc.seoul.kr/asan/main.do',
    );
    expect(launchMode, LaunchMode.externalApplication);
  });
}
