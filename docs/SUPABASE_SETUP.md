# NurseMate Supabase 연결

로그인, 회원가입, 사용자별 메모·이미지·듀티표 복구 기능은 Supabase Auth,
Postgres, private Storage를 사용한다. Supabase가 연결되지 않은 빌드에서도 기존 Hive
오프라인 기능은 그대로 동작한다.

## 1. Supabase 프로젝트 생성

Supabase Dashboard에서 새 프로젝트를 만든다. 프로젝트의 **Connect** 화면에서 다음
두 값을 확인한다.

- Project URL
- Publishable key

`service_role` 또는 secret key는 Flutter 앱에 절대 넣지 않는다.

## 2. 데이터베이스와 Storage 구성

Supabase SQL Editor에서 아래 파일 전체를 실행한다.

`supabase/migrations/202607280001_nursemate_user_data.sql`

이 migration은 다음을 구성한다.

- `profiles`, `memos`, `duties`
- 사용자 본인 행만 접근할 수 있는 RLS 정책
- 비공개 `memo-images` Storage bucket
- 사용자 본인 폴더만 접근할 수 있는 Storage 정책
- 회원가입 시 profile을 생성하는 trigger

## 3. Auth 설정

Authentication에서 Email provider를 활성화한다. 이메일 확인을 사용할 경우 운영
주소를 Site URL과 Redirect URLs에 등록한다.

`https://nursemate-seven.vercel.app`

## 4. 로컬 실행

```powershell
C:\dev\flutter\bin\flutter.bat run -d chrome `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

## 5. 웹 빌드

```powershell
C:\dev\flutter\bin\flutter.bat build web `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Flutter 웹은 컴파일 시 환경값을 포함하므로, 일반 `flutter build web`만 실행하면
로그인 UI는 표시되지만 클라우드 연결은 비활성화된다. Publishable key는 RLS와 함께
클라이언트에서 사용하도록 설계된 키이며, secret/service role key와 다르다.

## 데이터 처리 주의

NurseMate 메모에는 환자 이름, 주민등록번호, 병원 등록번호 등 환자를 식별할 수 있는
정보를 저장하지 않는 것을 기본 정책으로 한다. 실제 병원 업무에서 민감정보를
저장하려면 배포 전 기관 보안 정책, 개인정보보호법, 접근기록, 보존·파기 정책과
서비스 제공자의 의료 데이터 처리 계약을 별도로 검토해야 한다.
