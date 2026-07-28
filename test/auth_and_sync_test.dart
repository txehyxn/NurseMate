import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/design_system/nursemate_theme.dart';
import 'package:nursemate/models/app_user.dart';
import 'package:nursemate/models/duty_type.dart';
import 'package:nursemate/models/memo.dart';
import 'package:nursemate/repositories/cloud_memo_repository.dart';
import 'package:nursemate/repositories/duty_repository.dart';
import 'package:nursemate/repositories/memo_repository.dart';
import 'package:nursemate/screens/main_menu_screen.dart';
import 'package:nursemate/screens/my_page_screen.dart';
import 'package:nursemate/services/auth_service.dart';

void main() {
  testWidgets('상단 프로필을 누르면 로그인 및 회원가입 화면을 연다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = _FakeAuthService();

    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: MainMenuScreen(
          authService: auth,
          memoRepository: _MemoryMemoRepository(),
          dutyRepository: _MemoryDutyRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homeProfileButton')));
    await tester.pumpAndSettle();

    expect(find.byType(MyPageScreen), findsOneWidget);
    expect(find.text('로그인'), findsWidgets);

    await tester.tap(find.byKey(const Key('toggleAuthModeButton')));
    await tester.pump();
    expect(find.text('회원가입'), findsWidgets);
    expect(find.byKey(const Key('authDisplayNameField')), findsOneWidget);
  });

  testWidgets('이메일 회원가입 후 로그인 사용자 정보를 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = _FakeAuthService();
    await tester.pumpWidget(
      MaterialApp(
        theme: NurseMateTheme.light(),
        home: MyPageScreen(authService: auth),
      ),
    );

    await tester.tap(find.byKey(const Key('toggleAuthModeButton')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('authDisplayNameField')),
      '신규 간호사',
    );
    await tester.enterText(
      find.byKey(const Key('authEmailField')),
      'nurse@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('authPasswordField')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('authPasswordConfirmField')),
      'password123',
    );
    final signUpButton = find.widgetWithText(FilledButton, '회원가입');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    expect(auth.signUpCount, 1);
    expect(find.text('신규 간호사'), findsOneWidget);
    expect(find.text('nurse@example.com'), findsOneWidget);
    expect(find.byKey(const Key('signOutButton')), findsOneWidget);
  });

  test('재설치처럼 로컬 데이터가 비어 있어도 클라우드 메모를 복원한다', () async {
    final local = _MemoryMemoRepository();
    final cloudMemo = Memo(
      id: 'cloud-memo',
      title: '복구된 메모',
      content: '클라우드에서 다시 불러온 내용',
      createdAt: DateTime(2026, 7, 28, 10),
      updatedAt: DateTime(2026, 7, 28, 11),
      isFavorite: true,
    );
    final cloud = _MemoryMemoRepository([cloudMemo]);
    final repository = SyncedMemoRepository(local: local, cloud: cloud);

    final restored = await repository.getAll();

    expect(restored, [cloudMemo]);
    expect(local.memos, [cloudMemo]);
  });
}

class _FakeAuthService implements AuthService {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;
  int signUpCount = 0;

  @override
  AppUser? get currentUser => _user;

  @override
  bool get isAvailable => true;

  @override
  Stream<AppUser?> get userChanges => _controller.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    _user = AppUser(id: 'user-1', email: email);
    _controller.add(_user);
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    signUpCount++;
    _user = AppUser(id: 'user-1', email: email, displayName: displayName);
    _controller.add(_user);
    return true;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}

class _MemoryMemoRepository implements MemoRepository {
  _MemoryMemoRepository([List<Memo>? initial]) : memos = [...?initial];

  final List<Memo> memos;

  @override
  Future<void> delete(String id) async {
    memos.removeWhere((memo) => memo.id == id);
  }

  @override
  Future<List<Memo>> getAll() async => [...memos];

  @override
  Future<void> save(Memo memo) async {
    final index = memos.indexWhere((item) => item.id == memo.id);
    if (index < 0) {
      memos.add(memo);
    } else {
      memos[index] = memo;
    }
  }
}

class _MemoryDutyRepository implements DutyRepository {
  final Map<String, DutyType> _duties = {};

  @override
  Future<void> delete(DateTime date) async {
    _duties.remove(_key(date));
  }

  @override
  Future<Map<String, DutyType>> getForMonth(DateTime month) async {
    return Map.of(_duties);
  }

  @override
  Future<void> save(DateTime date, DutyType type) async {
    _duties[_key(date)] = type;
  }

  String _key(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
