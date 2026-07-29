import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/services/auth_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('자동 로그인 선택을 저장하고 다시 불러온다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = AuthSessionService(preferences);

    expect(service.shouldRememberLogin, isFalse);

    await service.setRememberLogin(true);
    expect(service.shouldRememberLogin, isTrue);

    await service.setRememberLogin(false);
    expect(service.shouldRememberLogin, isFalse);
  });
}
