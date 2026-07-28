# NurseMate Design System

NurseMate의 모든 신규 화면과 UI 수정 작업에 적용하는 공식 디자인 기준이다.
기능 구현 전에 이 문서와 `lib/design_system/`의 기존 컴포넌트를 먼저 확인한다.

## 제품 방향

NurseMate는 간호사를 위한 프리미엄 모바일 앱이다. 병원 EMR처럼 딱딱한
인상보다 Apple Health, Notion, Linear와 현대적인 Medical Dashboard의
깔끔함·신뢰감·부드러움을 지향한다.

우선순위는 다음과 같다.

1. Premium: 고급스럽고 단순하며 불필요한 장식이 없다.
2. Medical: 정보가 명확하고 차분하며 안전한 인상을 준다.
3. Soft: 둥근 카드, 파스텔 색상, 넓은 여백을 사용한다.
4. Consistent: 모든 화면이 하나의 제품처럼 보인다.
5. Mobile First: 한 손 사용과 빠른 정보 확인을 우선한다.

## 디자인 토큰

코드에서는 임의의 색상값 대신 `NurseMateColors`와
`NurseMateRadii`, `NurseMateSpacing`, `NurseMateShadows`를 사용한다.

| 용도 | 토큰 | 값 |
|---|---|---|
| 브랜드 Primary | `NurseMateColors.primary` | `#6554C0` |
| 진한 Primary | `NurseMateColors.primaryDark` | `#4939A8` |
| Blue Accent | `NurseMateColors.blue` | `#3D7BF2` |
| Mint Accent | `NurseMateColors.mint` | `#30B89D` |
| Pink Accent | `NurseMateColors.pink` | `#F35A88` |
| Orange Accent | `NurseMateColors.orange` | `#F3A33C` |
| Yellow Accent | `NurseMateColors.yellow` | `#F4C94A` |
| 앱 배경 | `NurseMateColors.background` | `#FBFAFE` |
| 카드 | `NurseMateColors.surface` | `#FFFFFF` |
| 제목 | `NurseMateColors.navy` | `#172440` |
| 설명 | `NurseMateColors.textSecondary` | `#6E758C` |
| 연한 경계 | `NurseMateColors.border` | `#E9E8F2` |

강한 원색과 검은색 그림자를 사용하지 않는다. 의미 색상이 필요해도 파스텔
배경과 읽기 쉬운 진한 전경색을 한 쌍으로 사용한다.

## 레이아웃

- 기본 화면 좌우 여백: 모바일 20px, 태블릿·웹 24~32px
- 섹션 간격: 28~36px
- 카드 내부 여백: 20~24px
- 카드 사이 간격: 14~18px
- 콘텐츠 최대 너비: 대시보드 1120px, 폼 720px
- 모바일 열 구성은 첨부 시안을 그대로 따른다. 시안이 3열이면 임의로
  1열이나 2열로 재해석하지 않는다.

대부분의 화면은 `Header → Title/Description → Main Card → Supporting Card
→ Bottom Navigation` 순서를 따른다.

## 카드와 그림자

- 기본 반경: 24px
- 큰 대시보드 카드: 28px
- 입력창·버튼: 18~22px
- 카드 배경: 순백색
- 경계: 아주 연한 보라 회색 1px
- 그림자: 보라색 계열 5~8% 불투명도, blur 20~28px

강한 elevation이나 검은 그림자는 금지한다.

## 타이포그래피

- 화면 제목: 28~32px, Bold/ExtraBold
- 섹션 제목: 20~24px, Bold
- 카드 제목: 16~20px, Bold
- 본문: 14~16px, Regular, line height 1.4~1.55
- 설명: 12~14px, 회색
- 주요 결과 숫자: 36px 이상, ExtraBold
- 한글 자간은 제목에서 약간 좁게 사용한다.

## 버튼

- Primary: 보라색 Gradient, 반경 20px, 높이 52~58px
- Secondary: 흰색 또는 연한 보라 배경, 연한 Border
- Icon: 원형 또는 16px 이상 반경, 아주 약한 Shadow
- 터치 영역은 최소 44×44px를 확보한다.
- 기본 애니메이션은 250~350ms와 `easeOutCubic`을 사용한다.

## 입력창

- 흰색 또는 아주 연한 보라 회색 배경
- 반경 18px 이상
- 16~20px 수평 Padding
- 연한 Border, Focus 시 Primary 1.5~2px
- Material 기본 underline 스타일은 사용하지 않는다.
- 라벨, 단위, 예시, 오류 메시지의 계층을 명확히 구분한다.

## 아이콘과 일러스트

의료 일러스트가 정보의 중심이 되도록 한다. 수액백, 약, 간호사, 메모,
혈액검사, 체크리스트 등의 Soft Gradient 또는 3D Illustration을 우선한다.
Material Icon은 탐색·설정·뒤로가기처럼 보편적인 보조 동작에만 최소한으로
사용한다.

## 공통 컴포넌트

새 화면에서 먼저 확인할 공통 Widget:

- `NurseMateCard`
- `NurseMatePrimaryButton`
- `NurseMateSectionTitle`
- `NurseMateTextField`
- `NurseMateInfoCard`
- `NurseMatePageHeader`

사용 예:

```dart
NurseMateCard(
  child: Column(
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
        icon: Icons.calculate_outlined,
        onPressed: calculate,
      ),
    ],
  ),
)
```

## Bottom Navigation

- 흰색 배경과 상단의 아주 연한 구분선
- 선택 항목은 연한 보라 배경과 Primary 아이콘
- 홈, 계산, 기록, 지식, 마이 구조를 유지
- 아이콘 중심이며 라벨은 짧게 유지

## Flutter 구현 규칙

- Material 3와 `NurseMateTheme.light()`를 사용한다.
- `const`와 작은 Widget 분리를 적극 사용한다.
- 새 스타일을 화면 안에 하드코딩하지 않는다.
- 기존 공통 컴포넌트로 표현할 수 없을 때만 컴포넌트를 확장한다.
- 모바일과 넓은 화면의 overflow를 테스트한다.
- UI 변경으로 계산, 애니메이션, 저장, 잠금 로직을 수정하지 않는다.
- `flutter analyze` 오류 0개와 전체 테스트 통과를 유지한다.

## 시안 복제 작업 절차

모든 UI 작업은 다음 순서를 지킨다.

1. 첨부 시안을 화면 영역별로 분석한다.
2. 현재 Flutter 렌더링과 비교한다.
3. 위치, 크기, 비율, 여백, 색상, 타이포그래피 차이를 기록한다.
4. 기존 Design System 컴포넌트를 재사용해 차이를 수정한다.
5. 동일한 화면 크기에서 다시 렌더링한다.
6. `docs/UI_REPLICATION_CHECKLIST.md`를 기준으로 재비교한다.
7. 남은 차이가 설명 가능한 수준일 때만 완료 처리한다.

기능이 동작한다는 이유만으로 UI 작업을 완료하지 않는다. 새 디자인을
제안하거나 시안을 더 낫게 재해석하지 않는다.

## 금지되는 기본 Material 표현

아래 요소를 기본 모양 그대로 노출하지 않는다.

- `Card`
- `FilledButton`, `ElevatedButton`, `OutlinedButton`
- `TextField`
- `Dialog`
- `FloatingActionButton`
- Material Calendar

Flutter 위젯 자체의 사용을 금지하는 것은 아니다. 반드시 NurseMate Theme,
공통 컴포넌트, 커스텀 Decoration을 적용해 시안의 형태로 표현한다.

## 기능 보호

다음 기능은 UI 작업 중 절대 깨뜨리지 않는다.

- 수액 계산
- 수액속도 확인
- 메모장
- 사진 첨부
- 형광펜
- 잠금 기능
- 약 검색
- 듀티표

## 모든 UI 작업에 사용하는 공통 프롬프트

> 이번 작업의 최우선 목표는 기능 구현이 아니라 첨부 UI 시안을 Flutter에서
> 최대한 동일하게 복제하는 것입니다. 디자인을 새롭게 제안하거나 재해석하지
> 마세요. 기능 구현 전에 현재 화면과 시안의 차이를 분석하고,
> `NURSEMATE_DESIGN_SYSTEM.md`, `AGENTS.md`, `nursemate_tokens.dart`,
> `nursemate_theme.dart`, `nursemate_components.dart`의 기존 Theme와
> 컴포넌트를 우선 재사용하세요. Header, Calendar, Card, Feature Card,
> Typography, Bottom Navigation, Color, Animation, Spacing을 동일한
> 화면 크기에서 하나씩 비교하고 수정 후 다시 검증하세요. Material 기본
> 느낌을 노출하지 말고 기존 비즈니스 로직은 변경하지 마세요. 기능이
> 동작한다는 이유만으로 완료하지 말고 시안과의 시각적 차이가 충분히 해소된
> 뒤 `flutter analyze`, `flutter test`, `flutter build web`을 실행하세요.
>
> 당신은 Flutter 개발자가 아니라 Senior Product Designer + Senior Flutter
> Engineer입니다. 간격, 크기, 비율, 아이콘 위치, 그림자, Radius,
> Typography까지 픽셀 단위로 최대한 재현하고 기능보다 UI 완성도를
> 우선하세요.

## UI 작업 완료 보고 형식

UI 작업 완료 시 아래 형식을 사용한다.

```text
## 시안과 비교 결과

Header
- 일치도: 검증된 범위와 근거
- 남은 차이: 없음 또는 구체적인 차이

Calendar
- 일치도: 검증된 범위와 근거
- 남은 차이: 없음 또는 구체적인 차이

Feature Card
- 일치도: 검증된 범위와 근거
- 남은 차이: 없음 또는 구체적인 차이

Bottom Navigation / Spacing / Typography / Animation
- 동일한 형식으로 기록

전체 UI 유사도
- 실제 렌더링 비교가 수행된 경우에만 백분율과 산정 근거 기록
- 비교할 수 없었다면 퍼센트 대신 "정량 측정 안 됨"으로 기록
```

유사도 백분율은 객관적 측정값이 아니라면 임의로 작성하지 않는다. 반드시
검증한 화면 크기, 비교 방법, 확인한 차이를 함께 보고한다.

