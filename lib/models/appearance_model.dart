import 'package:flutter/material.dart';

class AppearanceItem {
  const AppearanceItem({
    required this.id,
    required this.englishName,
    required this.koreanName,
    required this.description,
    required this.colorDescription,
    required this.causes,
    required this.nursingInterventions,
    required this.topColor,
    required this.bottomColor,
    required this.borderColor,
  });

  final String id;
  final String englishName;
  final String koreanName;
  final String description;
  final String colorDescription;
  final List<String> causes;
  final List<String> nursingInterventions;
  final Color topColor;
  final Color bottomColor;
  final Color borderColor;
}
