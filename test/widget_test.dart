import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/main.dart';
import 'package:nursemate/widgets/drip_chamber_visual.dart';

void main() {
  testWidgets('계산 전에는 애니메이션 챔버가 표시되지 않는다', (tester) async {
    await tester.pumpWidget(const NurseMateApp());

    expect(find.text('NurseMate'), findsOneWidget);
    expect(find.byType(AnimatedDripChamber), findsNothing);
    expect(find.text('수액 정보를 입력한 뒤 계산하기를 눌러 주세요.'), findsOneWidget);
  });

  testWidgets('계산 후 결과와 움직이는 단일 챔버가 표시된다', (tester) async {
    await tester.pumpWidget(const NurseMateApp());
    await tester.ensureVisible(find.byKey(const Key('calculateButton')));
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pump();

    expect(find.text('33.3'), findsOneWidget);
    expect(find.text('11.1 gtt/min'), findsOneWidget);
    expect(find.text('약 11방울/분'), findsOneWidget);
    expect(find.text('5.4초'), findsOneWidget);
    expect(find.byType(AnimatedDripChamber), findsOneWidget);
    expect(find.byKey(const Key('dropCountdown')), findsOneWidget);
    expect(find.byKey(const Key('actualDropsField')), findsNothing);
    expect(find.text('실제 챔버'), findsNothing);
    expect(find.textContaining('목표보다'), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
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
    expect(find.byType(AnimatedDripChamber), findsNothing);
  });

  testWidgets('계산 후 입력이 잘못되면 기존 애니메이션을 제거한다', (tester) async {
    await tester.pumpWidget(const NurseMateApp());
    await tester.ensureVisible(find.byKey(const Key('calculateButton')));
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pump();
    expect(find.byType(AnimatedDripChamber), findsOneWidget);

    await tester.enterText(find.byKey(const Key('volumeField')), '0');
    await tester.ensureVisible(find.byKey(const Key('calculateButton')));
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pump();

    expect(find.byType(AnimatedDripChamber), findsNothing);
  });
}
