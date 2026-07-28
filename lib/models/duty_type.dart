import 'package:flutter/material.dart';

import '../design_system/nursemate_tokens.dart';

enum DutyType {
  day(
    code: 'D',
    label: '데이',
    background: Color(0xFFE4F7E8),
    foreground: Color(0xFF16924E),
  ),
  evening(
    code: 'E',
    label: '이브',
    background: Color(0xFFF0EBFF),
    foreground: Color(0xFF6547B2),
  ),
  night(
    code: 'N',
    label: '나이트',
    background: Color(0xFFFFF0DB),
    foreground: Color(0xFFE47012),
  ),
  off(
    code: 'OFF',
    label: '오프',
    background: Color(0xFFF1F1F7),
    foreground: Color(0xFF606174),
  ),
  annualLeave(
    code: 'Y',
    label: '연차',
    background: NurseMateColors.yellowSoft,
    foreground: Color(0xFFB38600),
  );

  const DutyType({
    required this.code,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String code;
  final String label;
  final Color background;
  final Color foreground;

  static DutyType? fromStorage(String value) {
    for (final type in values) {
      if (type.name == value || type.code == value) return type;
    }
    return null;
  }
}
