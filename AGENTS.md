# NurseMate UI 규칙

이 프로젝트의 모든 화면 작업은 반드시
`docs/NURSEMATE_DESIGN_SYSTEM.md`를 먼저 읽고 준수한다.

- 첨부 시안에서 확립된 Premium Medical Dashboard 디자인을 유지한다.
- 새 색상, 반경, 그림자, 입력창 스타일을 임의로 만들지 않는다.
- `lib/design_system/`의 Theme, 토큰, 공통 Widget을 우선 재사용한다.
- 기본 Material 느낌이 그대로 드러나는 UI를 만들지 않는다.
- 기능 로직과 저장 구조는 UI 작업을 이유로 변경하지 않는다.
- 모바일 UX와 접근성을 우선하고 넓은 화면에도 반응형으로 대응한다.
- 변경 후 `flutter analyze`와 `flutter test`를 실행한다.

