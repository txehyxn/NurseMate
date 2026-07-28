class NursingPoints {
  const NursingPoints({
    this.beforeAdministration = const [],
    this.afterAdministration = const [],
    this.commonAdverseEffects = const [],
    this.cautionPatients = const [],
  });

  final List<String> beforeAdministration;
  final List<String> afterAdministration;
  final List<String> commonAdverseEffects;
  final List<String> cautionPatients;

  factory NursingPoints.fromJson(Map<String, Object?> json) {
    List<String> strings(String key) {
      return (json[key] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList();
    }

    return NursingPoints(
      beforeAdministration: strings('beforeAdministration'),
      afterAdministration: strings('afterAdministration'),
      commonAdverseEffects: strings('commonAdverseEffects'),
      cautionPatients: strings('cautionPatients'),
    );
  }
}

class Drug {
  const Drug({
    required this.id,
    required this.productName,
    required this.ingredientKor,
    required this.ingredientEng,
    required this.manufacturer,
    required this.category,
    required this.dosageForm,
    required this.administrationRoute,
    required this.efficacy,
    required this.dosage,
    required this.nursingPoints,
    required this.contraindication,
    required this.precaution,
    required this.interaction,
    required this.adverseEffect,
    required this.storage,
    this.insuranceCode,
    this.atcCode,
    required this.isPrescription,
    this.imageUrl,
    required this.source,
    required this.sourceUrl,
    required this.updatedAt,
  });

  final String id;
  final String productName;
  final String ingredientKor;
  final String ingredientEng;
  final String manufacturer;
  final String category;
  final String dosageForm;
  final String administrationRoute;
  final String efficacy;
  final String dosage;
  final NursingPoints nursingPoints;
  final String contraindication;
  final String precaution;
  final String interaction;
  final String adverseEffect;
  final String storage;
  final String? insuranceCode;
  final String? atcCode;
  final bool isPrescription;
  final String? imageUrl;
  final String source;
  final String sourceUrl;
  final DateTime updatedAt;

  String get prescriptionLabel => isPrescription ? '전문의약품' : '일반의약품';

  factory Drug.fromJson(Map<String, Object?> json) {
    String string(String key, [String fallback = '정보 없음']) {
      final value = json[key];
      return value is String && value.trim().isNotEmpty
          ? value.trim()
          : fallback;
    }

    String? nullableString(String key) {
      final value = json[key];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    }

    final nursingPointsJson = json['nursingPoints'];
    return Drug(
      id: string('id', ''),
      productName: string('productName'),
      ingredientKor: string('ingredientKor'),
      ingredientEng: string('ingredientEng'),
      manufacturer: string('manufacturer'),
      category: string('category'),
      dosageForm: string('dosageForm'),
      administrationRoute: string('administrationRoute'),
      efficacy: string('efficacy'),
      dosage: string('dosage'),
      nursingPoints: nursingPointsJson is Map
          ? NursingPoints.fromJson(nursingPointsJson.cast<String, Object?>())
          : const NursingPoints(),
      contraindication: string('contraindication'),
      precaution: string('precaution'),
      interaction: string('interaction'),
      adverseEffect: string('adverseEffect'),
      storage: string('storage'),
      insuranceCode: nullableString('insuranceCode'),
      atcCode: nullableString('atcCode'),
      isPrescription: json['isPrescription'] == true,
      imageUrl: nullableString('imageUrl'),
      source: string('source', '식품의약품안전처 의약품 허가정보'),
      sourceUrl: string('sourceUrl', 'https://nedrug.mfds.go.kr/'),
      updatedAt: DateTime.tryParse(string('updatedAt', '')) ?? DateTime(1970),
    );
  }
}
