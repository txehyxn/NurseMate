import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_design_system.dart';

void main() {
  test('공식 Theme에 NurseMate 브랜드 토큰을 적용한다', () {
    final theme = NurseMateTheme.light();

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, NurseMateColors.primary);
    expect(theme.scaffoldBackgroundColor, NurseMateColors.background);
    expect(theme.inputDecorationTheme.enabledBorder, isA<OutlineInputBorder>());
  });

  testWidgets('공통 카드, 버튼, 입력창, 섹션 제목을 함께 사용할 수 있다', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: Scaffold(
          body: NurseMateCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const NurseMateSectionTitle(
                  title: '처방 정보 입력',
                  icon: Icons.assignment_outlined,
                ),
                NurseMateTextField(
                  controller: controller,
                  label: '용량',
                  suffixText: 'mL',
                ),
                NurseMatePrimaryButton(
                  label: '계산하기',
                  onPressed: () => pressed = true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('처방 정보 입력'), findsOneWidget);
    expect(find.text('용량'), findsOneWidget);
    expect(find.text('계산하기'), findsOneWidget);

    await tester.tap(find.text('계산하기'));
    expect(pressed, isTrue);
  });
}
