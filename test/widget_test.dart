import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/main.dart';

void main() {
  testWidgets('입력 후 계산 결과와 챔버가 표시된다', (tester) async {
    await tester.pumpWidget(const NurseMateApp());

    expect(find.text('NurseMate'), findsOneWidget);
    expect(find.text('수액 정보를 입력한 뒤 계산하기를 눌러 주세요.'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('calculateButton')));
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pumpAndSettle();

    expect(find.text('33.3'), findsOneWidget);
    expect(find.text('계산값 11.1 gtt/min'), findsOneWidget);
    expect(find.text('약 11방울/분'), findsOneWidget);
    expect(find.text('5.4초'), findsOneWidget);
    expect(find.text('계산 챔버'), findsOneWidget);
  });

  testWidgets('실제 챔버가 빠른 경우 비교 결과를 표시한다', (tester) async {
    await tester.pumpWidget(const NurseMateApp());
    await tester.ensureVisible(find.byKey(const Key('calculateButton')));
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('actualDropsField')));
    await tester.enterText(find.byKey(const Key('actualDropsField')), '15');
    await tester.ensureVisible(find.byKey(const Key('compareButton')));
    await tester.tap(find.byKey(const Key('compareButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('comparisonBanner')), findsOneWidget);
    expect(find.text('목표보다 빨라요'), findsOneWidget);
    expect(find.text('실제 챔버'), findsOneWidget);
  });

  testWidgets('잘못된 입력에 필드 오류를 표시한다', (tester) async {
    await tester.pumpWidget(const NurseMateApp());
    await tester.enterText(find.byKey(const Key('volumeField')), '0');
    await tester.enterText(find.byKey(const Key('hoursField')), '0');
    await tester.enterText(find.byKey(const Key('minutesField')), '0');
    await tester.ensureVisible(find.byKey(const Key('calculateButton')));
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pump();

    expect(find.text('수액량은 0보다 커야 합니다.'), findsOneWidget);
    expect(find.text('1분 이상 입력해 주세요.'), findsOneWidget);
  });
}
