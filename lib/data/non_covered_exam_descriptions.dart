/// 비급여 검사 설명과 비고를 검사명 기준으로 관리한다.
///
/// 키는 각 비급여 데이터 파일의 `NonCoveredExam.name`과 정확히 일치해야 한다.
const Map<String, ({String description, String note})> examDescriptions = {
  '경추 MRI': (
    description: '경추 부위를 촬영하여 디스크, 협착증 등을 확인하는 검사입니다.',
    note: '검사 전 금속류 제거가 필요합니다.',
  ),
};
