import 'package:flutter_test/flutter_test.dart';
import 'package:nursemate/config/supabase_config.dart';

void main() {
  test('확장되지 않은 환경변수 플레이스홀더를 거부한다', () {
    expect(SupabaseConfig.isResolvedValue(r'$SUPABASE_URL'), isFalse);
    expect(
      SupabaseConfig.isResolvedValue(r'$SUPABASE_PUBLISHABLE_KEY'),
      isFalse,
    );
    expect(SupabaseConfig.isResolvedValue('%SUPABASE_URL%'), isFalse);
    expect(
      SupabaseConfig.isResolvedValue('https://YOUR_PROJECT.supabase.co'),
      isFalse,
    );
  });

  test('실제 형식의 Supabase 설정값을 허용한다', () {
    expect(
      SupabaseConfig.isResolvedValue('https://project.supabase.co'),
      isTrue,
    );
    expect(SupabaseConfig.isResolvedValue('sb_publishable_example'), isTrue);
  });
}
