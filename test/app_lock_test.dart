import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/config/app_access_config.dart';
import 'package:nursemate/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester tester) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      NurseMateApp(
        initiallyUnlocked: preferences.getBool(nurseMateUnlockedKey) ?? false,
        preferences: preferences,
      ),
    );
  }

  testWidgets('앱 시작 시 잠금 화면을 표시한다', (tester) async {
    await pumpApp(tester);

    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('unlockButton')), findsOneWidget);
    expect(find.byKey(const Key('calculateButton')), findsNothing);
  });

  testWidgets('잘못된 비밀번호에는 오류 메시지를 표시한다', (tester) async {
    await pumpApp(tester);

    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'wrong-password',
    );
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pump();

    expect(find.text('비밀번호가 올바르지 않습니다.'), findsOneWidget);
    expect(find.byKey(const Key('calculateButton')), findsNothing);
  });

  testWidgets('올바른 비밀번호로 계산 화면을 연다', (tester) async {
    await pumpApp(tester);

    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'gPdnjs0518.',
    );
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('passwordField')), findsNothing);
    expect(find.byKey(const Key('calculateButton')), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(nurseMateUnlockedKey), isTrue);
  });

  testWidgets('잠금 해제 후 앱을 새로 시작하면 계산 화면을 바로 연다', (tester) async {
    await pumpApp(tester);
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'gPdnjs0518.',
    );
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calculateButton')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpApp(tester);

    expect(find.byKey(const Key('passwordField')), findsNothing);
    expect(find.byKey(const Key('calculateButton')), findsOneWidget);
  });

  testWidgets('저장 데이터가 삭제되면 잠금 화면을 다시 표시한다', (tester) async {
    SharedPreferences.setMockInitialValues({nurseMateUnlockedKey: true});
    await pumpApp(tester);
    expect(find.byKey(const Key('calculateButton')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    SharedPreferences.setMockInitialValues({});
    await pumpApp(tester);

    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('calculateButton')), findsNothing);
  });
}
