import 'package:flutter/material.dart';

import '../design_system/nursemate_tokens.dart';

enum DDayCalculationMode {
  countdown('D-Day'),
  countUp('D+Day');

  const DDayCalculationMode(this.label);

  final String label;
}

enum DDayCardColor {
  purple('보라'),
  blue('파랑'),
  green('초록'),
  orange('주황'),
  red('빨강');

  const DDayCardColor(this.label);

  final String label;

  Color get accent {
    return switch (this) {
      DDayCardColor.purple => NurseMateColors.primary,
      DDayCardColor.blue => NurseMateColors.blue,
      DDayCardColor.green => NurseMateColors.mint,
      DDayCardColor.orange => NurseMateColors.orange,
      DDayCardColor.red => NurseMateColors.error,
    };
  }

  Color get backgroundStart {
    return switch (this) {
      DDayCardColor.purple => const Color(0xFFF8F6FF),
      DDayCardColor.blue => const Color(0xFFF4F8FF),
      DDayCardColor.green => const Color(0xFFF2FBF8),
      DDayCardColor.orange => const Color(0xFFFFF9F0),
      DDayCardColor.red => const Color(0xFFFFF6F7),
    };
  }

  Color get backgroundEnd {
    return switch (this) {
      DDayCardColor.purple => const Color(0xFFF0EEFF),
      DDayCardColor.blue => NurseMateColors.blueSoft,
      DDayCardColor.green => NurseMateColors.mintSoft,
      DDayCardColor.orange => NurseMateColors.orangeSoft,
      DDayCardColor.red => NurseMateColors.pinkSoft,
    };
  }
}

class DDaySetting {
  const DDaySetting({
    required this.title,
    required this.date,
    required this.calculationMode,
    required this.cardColor,
  });

  final String title;
  final DateTime date;
  final DDayCalculationMode calculationMode;
  final DDayCardColor cardColor;

  factory DDaySetting.defaultFor(DateTime today) {
    final normalizedToday = DateTime(today.year, today.month, today.day);
    return DDaySetting(
      title: '입사 후 D-Day',
      date: normalizedToday.add(const Duration(days: 120)),
      calculationMode: DDayCalculationMode.countdown,
      cardColor: DDayCardColor.purple,
    );
  }

  int daysFrom(DateTime today) {
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return calculationMode == DDayCalculationMode.countdown
        ? normalizedDate.difference(normalizedToday).inDays.abs()
        : normalizedToday.difference(normalizedDate).inDays.abs();
  }

  String counterLabel(DateTime today) {
    final days = daysFrom(today);
    if (calculationMode == DDayCalculationMode.countdown && days == 0) {
      return 'D-Day';
    }
    final prefix = calculationMode == DDayCalculationMode.countdown
        ? 'D-'
        : 'D+';
    return '$prefix$days';
  }
}
