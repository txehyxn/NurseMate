import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/controllers/highlighting_text_editing_controller.dart';
import 'package:nursemate/models/memo.dart';
import 'package:nursemate/repositories/memo_repository.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:nursemate/screens/memo_editor_screen.dart';
import 'package:nursemate/screens/memo_list_screen.dart';

void main() {
  testWidgets('메인 메뉴에서 메모장에 진입하면 빈 메모 안내를 표시한다', (tester) async {
    final repository = _MemoryMemoRepository();
    await tester.pumpWidget(
      MaterialApp(home: MainMenuScreen(memoRepository: repository)),
    );

    expect(find.text('메모장'), findsOneWidget);
    final memoAction = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const Key('memoMenu')),
        matching: find.byType(InkWell),
      ),
    );
    memoAction.onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(MemoListScreen), findsOneWidget);
    expect(
      find.text(
        '작성된 메모가 없습니다.\n\n'
        '오른쪽 위 + 버튼을 눌러\n'
        '첫 번째 메모를 작성해보세요.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('새 메모를 생성하고 목록에 표시한다', (tester) async {
    final repository = _MemoryMemoRepository();
    await _pumpMemoList(tester, repository);

    await tester.tap(find.byKey(const Key('addMemoButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('memoTitleField')),
      '오늘 공부할 내용',
    );
    await tester.enterText(
      find.byKey(const Key('memoContentField')),
      '수액 계산 다시 보기',
    );
    await tester.tap(find.byKey(const Key('saveMemoButton')));
    await tester.pumpAndSettle();

    expect(repository.memos, hasLength(1));
    expect(repository.memos.single.title, '오늘 공부할 내용');
    expect(repository.memos.single.content, '수액 계산 다시 보기');
    expect(find.text('오늘 공부할 내용'), findsOneWidget);
    expect(find.text('수액 계산 다시 보기'), findsOneWidget);
  });

  testWidgets('기존 메모를 수정하면 내용과 수정 시간이 갱신된다', (tester) async {
    final originalUpdatedAt = DateTime(2026, 7, 28, 10);
    final repository = _MemoryMemoRepository([
      Memo(
        id: 'memo-1',
        title: '기존 제목',
        content: '기존 내용',
        createdAt: DateTime(2026, 7, 27),
        updatedAt: originalUpdatedAt,
      ),
    ]);
    await _pumpMemoList(tester, repository);

    await tester.tap(find.byKey(const Key('memoCard_memo-1')));
    await tester.pumpAndSettle();
    expect(_fieldText(tester, const Key('memoTitleField')), '기존 제목');
    expect(_fieldText(tester, const Key('memoContentField')), '기존 내용');

    await tester.enterText(find.byKey(const Key('memoTitleField')), '수정한 제목');
    await tester.enterText(find.byKey(const Key('memoContentField')), '수정한 내용');
    await tester.tap(find.byKey(const Key('saveMemoButton')));
    await tester.pumpAndSettle();

    expect(repository.memos.single.title, '수정한 제목');
    expect(repository.memos.single.content, '수정한 내용');
    expect(
      repository.memos.single.updatedAt.isAfter(originalUpdatedAt),
      isTrue,
    );
    expect(find.text('수정한 제목'), findsOneWidget);
  });

  testWidgets('삭제 확인 후 메모를 삭제하고 빈 상태로 돌아간다', (tester) async {
    final repository = _MemoryMemoRepository([
      Memo(
        id: 'memo-delete',
        title: '삭제할 메모',
        content: '삭제할 내용',
        createdAt: DateTime(2026, 7, 28),
        updatedAt: DateTime(2026, 7, 28),
      ),
    ]);
    await _pumpMemoList(tester, repository);

    await tester.tap(find.byKey(const Key('memoCard_memo-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteMemoButton')));
    await tester.pumpAndSettle();

    expect(find.text('정말 삭제하시겠습니까?'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmDeleteMemoButton')));
    await tester.pumpAndSettle();

    expect(repository.memos, isEmpty);
    expect(find.textContaining('작성된 메모가 없습니다.'), findsOneWidget);
  });

  testWidgets('제목과 내용으로 메모를 실시간 검색한다', (tester) async {
    final repository = _MemoryMemoRepository([
      Memo(
        id: 'memo-infusion',
        title: '수액 공부',
        content: '계산 공식을 복습한다.',
        createdAt: DateTime(2026, 7, 28, 10),
        updatedAt: DateTime(2026, 7, 28, 10),
      ),
      Memo(
        id: 'memo-round',
        title: '병동 메모',
        content: '환자 상태 관찰',
        createdAt: DateTime(2026, 7, 28, 11),
        updatedAt: DateTime(2026, 7, 28, 11),
      ),
    ]);
    await _pumpMemoList(tester, repository);

    final searchField = find.descendant(
      of: find.byKey(const Key('memoSearchBar')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(searchField, '수액');
    await tester.pump();

    expect(find.byKey(const Key('memoCard_memo-infusion')), findsOneWidget);
    expect(find.byKey(const Key('memoCard_memo-round')), findsNothing);

    await tester.enterText(searchField, '관찰');
    await tester.pump();

    expect(find.byKey(const Key('memoCard_memo-infusion')), findsNothing);
    expect(find.byKey(const Key('memoCard_memo-round')), findsOneWidget);
  });

  testWidgets('선택한 사진을 메모에서 바로 보여주고 저장한다', (tester) async {
    final repository = _MemoryMemoRepository();
    const photo = MemoPhoto(
      id: 'photo-1',
      mimeType: 'image/png',
      base64Data:
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
          '+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    await _pumpMemoList(tester, repository, photoPicker: () async => photo);

    await tester.tap(find.byKey(const Key('addMemoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addMemoPhotoButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('memoPhoto_photo-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('saveMemoButton')));
    await tester.pumpAndSettle();

    expect(repository.memos.single.photos, [photo]);
    expect(
      find.byKey(Key('memoCardPhoto_${repository.memos.single.id}')),
      findsOneWidget,
    );
  });

  testWidgets('선택한 본문에 형광펜을 적용하고 다시 열어도 유지한다', (tester) async {
    final repository = _MemoryMemoRepository();
    await _pumpMemoList(tester, repository);

    await tester.tap(find.byKey(const Key('addMemoButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('memoContentField')),
      '투약 전 알레르기를 확인한다.',
    );

    final field = tester.widget<TextField>(
      find.byKey(const Key('memoContentField')),
    );
    final controller = field.controller! as HighlightingTextEditingController;
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 12);
    await tester.tap(find.byKey(const Key('applyMemoHighlightButton')));
    await tester.pump();

    expect(controller.highlights, [const MemoHighlight(start: 0, end: 12)]);
    final highlightedSpan = controller.buildTextSpan(
      context: tester.element(find.byKey(const Key('memoContentField'))),
      style: const TextStyle(),
      withComposing: true,
    );
    expect(
      highlightedSpan.children!.first.style!.backgroundColor,
      HighlightingTextEditingController.highlightColor,
    );

    await tester.tap(find.byKey(const Key('saveMemoButton')));
    await tester.pumpAndSettle();
    expect(repository.memos.single.highlights, [
      const MemoHighlight(start: 0, end: 12),
    ]);

    await tester.tap(find.byKey(Key('memoCard_${repository.memos.single.id}')));
    await tester.pumpAndSettle();
    final reopenedField = tester.widget<TextField>(
      find.byKey(const Key('memoContentField')),
    );
    final reopenedController =
        reopenedField.controller! as HighlightingTextEditingController;
    expect(reopenedController.highlights, [
      const MemoHighlight(start: 0, end: 12),
    ]);
  });

  test('기존 저장 데이터는 사진과 형광펜 없이도 정상 복원된다', () {
    final memo = Memo.fromJson({
      'id': 'legacy',
      'title': '기존 메모',
      'content': '기존 내용',
      'createdAt': '2026-07-28T10:00:00.000',
      'updatedAt': '2026-07-28T11:00:00.000',
    });

    expect(memo.photos, isEmpty);
    expect(memo.highlights, isEmpty);
  });

  test('사진과 형광펜 데이터가 JSON 저장 후 그대로 복원된다', () {
    const photo = MemoPhoto(
      id: 'photo-json',
      base64Data: 'AQID',
      mimeType: 'image/jpeg',
    );
    final original = Memo(
      id: 'memo-json',
      title: '저장 테스트',
      content: '중요한 내용',
      createdAt: DateTime(2026, 7, 28, 10),
      updatedAt: DateTime(2026, 7, 28, 11),
      highlights: const [MemoHighlight(start: 0, end: 3)],
      photos: const [photo],
    );

    final decoded = (jsonDecode(jsonEncode(original.toJson())) as Map)
        .cast<String, Object?>();
    final restored = Memo.fromJson(decoded);

    expect(restored.highlights, original.highlights);
    expect(restored.photos, original.photos);
  });
}

Future<void> _pumpMemoList(
  WidgetTester tester,
  MemoRepository repository, {
  MemoPhotoPicker? photoPicker,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MemoListScreen(repository: repository, photoPicker: photoPicker),
    ),
  );
  await tester.pumpAndSettle();
}

String _fieldText(WidgetTester tester, Key key) {
  return tester.widget<TextField>(find.byKey(key)).controller!.text;
}

class _MemoryMemoRepository implements MemoRepository {
  _MemoryMemoRepository([List<Memo>? initial]) : memos = [...?initial];

  final List<Memo> memos;

  @override
  Future<List<Memo>> getAll() async {
    return [...memos]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<void> save(Memo memo) async {
    final index = memos.indexWhere((item) => item.id == memo.id);
    if (index == -1) {
      memos.add(memo);
    } else {
      memos[index] = memo;
    }
  }

  @override
  Future<void> delete(String id) async {
    memos.removeWhere((memo) => memo.id == id);
  }
}
