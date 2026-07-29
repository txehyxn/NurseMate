import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/screens/appearance_screen.dart';

void main() {
  testWidgets('배액 양상 시안의 주요 영역과 9개 양상을 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const AppearanceScreen(),
      ),
    );

    expect(find.text('배액 양상'), findsOneWidget);
    expect(find.text('배액의 색, 상태를 확인해요'), findsOneWidget);
    expect(find.text('소변 양상'), findsOneWidget);
    expect(find.text('배액관 양상'), findsNWidgets(2));
    expect(find.text('안내'), findsOneWidget);
    expect(find.text('참고'), findsOneWidget);

    for (final label in const [
      'serous',
      'serosanguineous',
      'sanguineous',
      'bloody',
      'fresh bloody',
      'dark(old) bloody',
      'brownish',
      'chyle',
      'bile',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();

    expect(find.text('참고').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('배액 양상 카드를 누르면 상세 BottomSheet를 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const AppearanceScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('appearanceCard-serous')));
    await tester.pumpAndSettle();

    expect(find.text('장액성'), findsNWidgets(2));
    expect(find.text('serous'), findsNWidgets(2));
    expect(find.text('색상'), findsOneWidget);
    expect(find.text('특징'), findsOneWidget);
    expect(find.text('주요 원인'), findsOneWidget);
    expect(find.text('간호 중재'), findsOneWidget);
    expect(find.text('맑고 투명한 연노란색'), findsOneWidget);
    expect(find.text('수술 후 정상적인 염증·회복 과정'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('appearanceDetailScrollView')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.text('갑작스러운 증가·감소 또는 혼탁해지는 변화는 보고해요.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('appearanceDetailCloseButton')));
    await tester.pumpAndSettle();
    expect(find.text('주요 원인'), findsNothing);
  });

  testWidgets('소변 양상 탭은 6개 카드와 기존 상세 BottomSheet를 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: const AppearanceScreen(),
      ),
    );

    expect(find.byType(AnimatedSwitcher), findsOneWidget);

    await tester.tap(find.byKey(const Key('urineAppearanceTab')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Pale Straw'), findsOneWidget);
    expect(find.text('serous'), findsOneWidget);

    await tester.pumpAndSettle();

    for (final label in const [
      'Pale Straw',
      'Straw',
      'Amber',
      'Clear',
      'Turbid',
      'Hematuria',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('serous'), findsNothing);
    expect(find.byKey(const Key('appearanceCard-pale-straw')), findsOneWidget);
    expect(find.byKey(const Key('appearanceCard-hematuria')), findsOneWidget);

    await tester.tap(find.byKey(const Key('appearanceCard-pale-straw')));
    await tester.pumpAndSettle();

    expect(find.text('연한 노란색'), findsNWidgets(2));
    expect(find.text('Pale Straw'), findsNWidgets(2));
    expect(find.text('매우 옅고 맑은 노란색'), findsOneWidget);
    expect(find.text('충분한 수분 섭취'), findsOneWidget);
    expect(find.text('간호 중재'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('appearanceDetailCloseButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('drainageAppearanceTab')));
    await tester.pumpAndSettle();

    expect(find.text('serous'), findsOneWidget);
    expect(find.text('Pale Straw'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
