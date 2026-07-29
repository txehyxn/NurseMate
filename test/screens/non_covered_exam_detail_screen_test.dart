import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/models/non_covered_exam.dart';
import 'package:nursemate/screens/non_covered_exam_detail_screen.dart';
import 'package:nursemate/services/non_covered_exam_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('검사명과 가격, 설명·비고 기본 문구를 표시한다', (tester) async {
    const exam = NonCoveredExam(name: 'Brain MRI', price: 1200000);
    final preferences = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: NonCoveredExamDetailScreen(
          exam: exam,
          historyService: NonCoveredExamHistoryService(preferences),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Brain MRI'), findsNWidgets(2));
    expect(find.text('1,200,000원'), findsOneWidget);
    expect(find.text('설명'), findsOneWidget);
    expect(find.text('등록된 설명이 없습니다.'), findsOneWidget);
    expect(find.text('비고'), findsOneWidget);
    expect(find.text('등록된 비고가 없습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('검사명에 등록된 설명과 비고를 표시한다', (tester) async {
    const exam = NonCoveredExam(name: '경추 MRI', price: 550000);
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: NonCoveredExamDetailScreen(
          exam: exam,
          historyService: NonCoveredExamHistoryService(preferences),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('경추 부위를 촬영하여 디스크, 협착증 등을 확인하는 검사입니다.'), findsOneWidget);
    expect(find.text('검사 전 금속류 제거가 필요합니다.'), findsOneWidget);
    expect(find.text('등록된 설명이 없습니다.'), findsNothing);
    expect(find.text('등록된 비고가 없습니다.'), findsNothing);
  });

  testWidgets('즐겨찾기를 등록하고 다시 누르면 해제한다', (tester) async {
    const exam = NonCoveredExam(name: 'Brain MRI', price: 1200000);
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: NonCoveredExamDetailScreen(
          exam: exam,
          historyService: NonCoveredExamHistoryService(preferences),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final favoriteButton = find.byKey(const Key('nonCoveredFavoriteButton'));
    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);

    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(preferences.getStringList(favoriteNonCoveredExamsKey), <String>[
      'Brain MRI',
    ]);

    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    expect(preferences.getStringList(favoriteNonCoveredExamsKey), isEmpty);
  });
}
