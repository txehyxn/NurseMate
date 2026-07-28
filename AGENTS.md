# NurseMate UI 규칙

이 프로젝트의 모든 화면 작업은 반드시
`docs/NURSEMATE_DESIGN_SYSTEM.md`를 먼저 읽고 준수한다.

- 첨부 시안에서 확립된 Premium Medical Dashboard 디자인을 유지한다.
- UI 작업의 목표는 새 디자인 제안이 아니라 첨부 시안 복제이다.
- 새 색상, 반경, 그림자, 입력창 스타일을 임의로 만들지 않는다.
- `lib/design_system/`의 Theme, 토큰, 공통 Widget을 우선 재사용한다.
- 기본 Material 느낌이 그대로 드러나는 UI를 만들지 않는다.
- 기능 로직과 저장 구조는 UI 작업을 이유로 변경하지 않는다.
- 모바일 UX와 접근성을 우선하고 넓은 화면에도 반응형으로 대응한다.
- 구현 전 시안과 현재 화면의 차이를 정리하고 구현 후 다시 비교한다.
- `docs/UI_REPLICATION_CHECKLIST.md`의 항목을 검토하지 않고 UI 작업을
  완료 처리하지 않는다.
- 근거 없이 UI 유사도 퍼센트를 만들어내지 않는다. 실제 렌더링 비교 결과와
  남은 차이를 함께 기록한다.
- 변경 후 `flutter analyze`, `flutter test`, `flutter build web`을 실행한다.
