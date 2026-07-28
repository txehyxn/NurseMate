import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/models/memo.dart';
import 'package:nursemate/repositories/memo_repository.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:nursemate/screens/memo_list_screen.dart';

void main() {
  testWidgets('메인 메뉴에서 메모장에 진입하면 빈 메모 안내를 표시한다', (tester) async {
    final repository = _MemoryMemoRepository();
    await tester.pumpWidget(
      MaterialApp(home: MainMenuScreen(memoRepository: repository)),
    );

    expect(find.text('메모장'), findsOneWidget);
    await tester.tap(find.byKey(const Key('memoMenu')));
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
}

Future<void> _pumpMemoList(
  WidgetTester tester,
  MemoRepository repository,
) async {
  await tester.pumpWidget(
    MaterialApp(home: MemoListScreen(repository: repository)),
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
