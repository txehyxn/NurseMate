import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_design_system.dart';
import 'package:nursemate/models/duty_type.dart';
import 'package:nursemate/repositories/duty_repository.dart';
import 'package:nursemate/screens/disease_encyclopedia_screen.dart';
import 'package:nursemate/screens/main_menu_screen.dart';

void main() {
  testWidgets('질환별 메뉴에서 서울아산병원 질환백과 WebView를 연다', (tester) async {
    final client = _FakeDiseaseWebViewClient();

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: MainMenuScreen(
          dutyRepository: _EmptyDutyRepository(),
          diseaseWebViewClient: client,
        ),
      ),
    );
    await tester.pump();

    final menu = find.byKey(const Key('diseaseSearchMenu'));
    await tester.ensureVisible(menu);
    final action = tester.widget<InkWell>(
      find.descendant(of: menu, matching: find.byType(InkWell)),
    );
    action.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    client.finish();
    await tester.pumpAndSettle();

    expect(find.byType(DiseaseEncyclopediaScreen), findsOneWidget);
    expect(find.text('질환백과'), findsOneWidget);
    expect(client.loadedUri, kAsanDiseaseEncyclopediaUri);
    expect(
      client.loadedUri.toString(),
      'https://www.amc.seoul.kr/asan/main.do',
    );
  });

  testWidgets('페이지가 로드되는 동안 진행 표시 후 WebView를 표시한다', (tester) async {
    final client = _FakeDiseaseWebViewClient();

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: DiseaseEncyclopediaScreen(webViewClient: client),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('diseaseWebViewLoading')),
      findsOneWidget,
    );
    expect(client.loadedUri, kAsanDiseaseEncyclopediaUri);

    client.finish();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('diseaseWebViewLoading')), findsNothing);
    expect(find.byKey(const Key('fakeDiseaseWebView')), findsOneWidget);
  });

  testWidgets('로드 실패 시 오류 화면을 표시하고 다시 시도한다', (tester) async {
    final client = _FakeDiseaseWebViewClient();
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: DiseaseEncyclopediaScreen(webViewClient: client),
      ),
    );
    await tester.pump();

    client.fail();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('diseaseWebViewError')), findsOneWidget);
    expect(find.text('페이지를 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
    expect(tester.takeException(), isNull);

    client.finish();
    await tester.pump();
    expect(find.byKey(const Key('diseaseWebViewError')), findsOneWidget);

    await tester.tap(find.byKey(const Key('diseaseWebViewRetryButton')));
    await tester.pump();

    expect(client.reloadCount, 1);
    expect(
      find.byKey(const Key('diseaseWebViewLoading')),
      findsOneWidget,
    );

    client.finish();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('diseaseWebViewError')), findsNothing);
  });
}

class _FakeDiseaseWebViewClient implements DiseaseWebViewClient {
  VoidCallback? _onPageStarted;
  VoidCallback? _onPageFinished;
  DiseaseWebViewErrorCallback? _onError;
  Uri? loadedUri;
  int reloadCount = 0;

  @override
  Widget buildView() {
    return const ColoredBox(
      key: Key('fakeDiseaseWebView'),
      color: Colors.white,
    );
  }

  @override
  void configure({
    required VoidCallback onPageStarted,
    required VoidCallback onPageFinished,
    required DiseaseWebViewErrorCallback onError,
  }) {
    _onPageStarted = onPageStarted;
    _onPageFinished = onPageFinished;
    _onError = onError;
  }

  @override
  Future<void> load(Uri uri) async {
    loadedUri = uri;
    _onPageStarted?.call();
  }

  @override
  Future<void> reload() async {
    reloadCount++;
    _onPageStarted?.call();
  }

  void finish() => _onPageFinished?.call();

  void fail() => _onError?.call(Exception('offline'));
}

class _EmptyDutyRepository implements DutyRepository {
  @override
  Future<void> delete(DateTime date) async {}

  @override
  Future<Map<String, DutyType>> getForMonth(DateTime month) async => const {};

  @override
  Future<void> save(DateTime date, DutyType type) async {}
}
