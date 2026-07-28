import '../models/drug.dart';

/// 현재 버전의 검증된 샘플 카탈로그다.
///
/// 간호 포인트는 [source]에 표시된 공식 허가정보 또는 제조사 공식 복약
/// 안내에서 확인 가능한 내용만 짧게 재구성한다. 다음 버전에서
/// [DrugRepository] 구현만 API 기반으로 교체하고 UI는 그대로 유지한다.
final List<Drug> verifiedDrugCatalog = [
  Drug(
    id: 'tylenol-500',
    productName: '타이레놀정 500mg',
    ingredientKor: '아세트아미노펜 500mg',
    ingredientEng: 'Acetaminophen 500mg',
    manufacturer: '한국존슨앤드존슨판매(유)',
    category: '해열·진통·소염제',
    dosageForm: '정제',
    administrationRoute: '경구',
    efficacy:
        '감기로 인한 발열 및 동통, 두통, 신경통, 근육통, 월경통, '
        '염좌통 등의 통증 완화',
    dosage:
        '만 12세 이상 소아 및 성인: 1회 1~2정씩, 1일 3~4회 '
        '(4~6시간마다) 필요 시 복용합니다. 1일 최대 4,000mg을 넘지 않습니다.',
    nursingPoints: const NursingPoints(
      beforeAdministration: [
        '다른 아세트아미노펜 함유 약의 동시 복용 여부',
        '최근 음주 및 간질환 병력',
        '최근 투약 시간과 24시간 누적 용량',
      ],
      afterAdministration: [
        '통증 또는 발열의 변화',
        '발진 등 과민반응',
        '과량 투여가 의심되면 증상과 관계없이 즉시 보고',
      ],
      commonAdverseEffects: ['구역', '발진·피부 반응'],
      cautionPatients: ['간장애 환자', '신장장애 환자', '정기적으로 음주하는 환자'],
    ),
    contraindication: '이 약 또는 구성 성분에 과민반응이 있는 환자는 투여하지 않습니다.',
    precaution:
        '매일 세 잔 이상 정기적으로 술을 마시는 사람, 간장애 또는 신장장애 환자는 '
        '복용 전 의사·약사와 상의합니다. 권장량을 초과하면 간 손상 위험이 있습니다.',
    interaction: '아세트아미노펜을 포함한 다른 의약품과 동시에 복용하지 않습니다.',
    adverseEffect:
        '드물게 발진, 피부 반응, 구역 등이 나타날 수 있습니다. '
        '이상 반응이 나타나면 복용을 중단하고 전문가와 상의합니다.',
    storage: '밀폐용기, 실온(1~30℃) 보관',
    insuranceCode: null,
    atcCode: 'N02BE01',
    isPrescription: false,
    imageUrl: null,
    source: '식품의약품안전처 허가정보 및 타이레놀 공식 복약 안내',
    sourceUrl:
        'https://www.tylenol.co.kr/safety-dosing/usage/dosage-for-adults',
    updatedAt: DateTime(2026, 7, 28),
  ),
  Drug(
    id: 'tylenol-er-650',
    productName: '타이레놀8시간이알서방정 650mg',
    ingredientKor: '아세트아미노펜 650mg',
    ingredientEng: 'Acetaminophen 650mg',
    manufacturer: '한국존슨앤드존슨판매(유)',
    category: '해열·진통·소염제',
    dosageForm: '서방정',
    administrationRoute: '경구',
    efficacy: '해열 및 감기, 두통, 치통, 근육통, 허리 통증, 생리통, 관절통의 완화',
    dosage:
        '만 12세 이상 소아 및 성인: 매 8시간마다 2정씩 복용하며, '
        '24시간 동안 6정을 초과하지 않습니다.',
    nursingPoints: const NursingPoints(
      beforeAdministration: [
        '다른 아세트아미노펜 함유 약의 동시 복용 여부',
        '최근 투약 시간과 24시간 누적 용량',
        '환자가 정제를 그대로 삼킬 수 있는지 확인',
      ],
      afterAdministration: ['통증 또는 발열의 변화', '발진 등 과민반응'],
      commonAdverseEffects: ['구역', '발진·피부 반응'],
      cautionPatients: ['간장애 환자', '정기적으로 음주하는 환자'],
    ),
    contraindication: '이 약 또는 구성 성분에 과민반응이 있는 환자는 투여하지 않습니다.',
    precaution:
        '서방정이므로 쪼개거나 씹거나 녹이지 말고 그대로 삼킵니다. '
        '권장량을 초과하면 간 손상 위험이 있습니다.',
    interaction: '아세트아미노펜을 포함한 다른 의약품과 동시에 복용하지 않습니다.',
    adverseEffect:
        '드물게 발진, 피부 반응, 구역 등이 나타날 수 있습니다. '
        '이상 반응이 나타나면 복용을 중단하고 전문가와 상의합니다.',
    storage: '밀폐용기, 실온(1~30℃) 보관',
    insuranceCode: null,
    atcCode: 'N02BE01',
    isPrescription: false,
    imageUrl: null,
    source: '식품의약품안전처 허가정보 및 타이레놀 공식 제품 안내',
    sourceUrl: 'https://www.tylenol.co.kr/products/tylenol-er',
    updatedAt: DateTime(2026, 7, 28),
  ),
  Drug(
    id: 'rocephin-1g',
    productName: '로세핀주사 1g',
    ingredientKor: '세프트리악손나트륨수화물 1g',
    ingredientEng: 'Ceftriaxone Sodium Hydrate 1g',
    manufacturer: '한국로슈',
    category: '세팔로스포린계 항생제',
    dosageForm: '주사제',
    administrationRoute: '정맥·근육',
    efficacy:
        '감수성 균에 의한 호흡기계, 이비인후과계, 신장·요로계, '
        '생식기계 감염증과 패혈증 등의 치료',
    dosage:
        '감염 부위와 중증도, 연령, 체중 및 신장·간 기능에 따라 처방된 용량과 '
        '투여 간격을 확인하여 정맥 또는 근육 투여합니다.',
    nursingPoints: const NursingPoints(
      beforeAdministration: [
        '페니실린·세팔로스포린계 과민반응 병력',
        '처방 용량, 투여 경로, 배양검사 및 감수성 결과',
        '칼슘 함유 수액의 동시 투여 여부',
      ],
      afterAdministration: ['아나필락시스 등 즉시형 과민반응', '주사부위 통증·정맥염', '지속적이거나 심한 설사'],
      commonAdverseEffects: ['설사', '발진', '주사부위 반응'],
      cautionPatients: ['중증 신장·간 기능 저하 환자', '위장관 질환 병력 환자', '신생아'],
    ),
    contraindication:
        '세팔로스포린계 항생물질에 과민반응 병력이 있는 환자, '
        '칼슘 함유 정맥용액 투여가 필요한 신생아 등 허가사항상 금기 환자에게 투여하지 않습니다.',
    precaution:
        '투여 전 베타락탐계 항생제 과민반응 병력을 확인합니다. '
        '칼슘 함유 정맥용액과 혼합하거나 동일 투여경로로 동시에 투여하지 않습니다.',
    interaction:
        '칼슘 함유 정맥용액과의 배합 및 동시 투여를 피합니다. '
        '병용약과 수액의 배합 적합성을 투여 전에 확인합니다.',
    adverseEffect:
        '설사, 발진, 주사부위 반응 등이 나타날 수 있으며, '
        '중증 과민반응이나 지속적인 설사는 즉시 평가가 필요합니다.',
    storage: '밀봉용기, 실온 보관. 조제 후 안정성과 보관 조건은 제품 허가사항을 확인합니다.',
    insuranceCode: null,
    atcCode: 'J01DD04',
    isPrescription: true,
    imageUrl: null,
    source: '식품의약품안전처 의약품 제품 허가정보',
    sourceUrl: 'https://nedrug.mfds.go.kr/',
    updatedAt: DateTime(2026, 7, 28),
  ),
];
