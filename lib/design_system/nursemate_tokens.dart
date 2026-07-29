import 'package:flutter/material.dart';

abstract final class NurseMateColors {
  static const primary = Color(0xFF6554C0);
  static const primaryDark = Color(0xFF4939A8);
  static const primarySoft = Color(0xFFF1EEFF);

  static const blue = Color(0xFF3D7BF2);
  static const blueSoft = Color(0xFFEEF5FF);
  static const mint = Color(0xFF30B89D);
  static const mintSoft = Color(0xFFECFAF7);
  static const pink = Color(0xFFF35A88);
  static const pinkSoft = Color(0xFFFFF0F5);
  static const orange = Color(0xFFF3A33C);
  static const orangeSoft = Color(0xFFFFF7E9);
  static const yellow = Color(0xFFF4C94A);
  static const yellowSoft = Color(0xFFFFF9E5);

  static const background = Color(0xFFFBFAFE);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF8F7FC);
  static const navy = Color(0xFF172440);
  static const text = Color(0xFF343A52);
  static const textSecondary = Color(0xFF6E758C);
  static const textTertiary = Color(0xFF9A9FB2);
  static const border = Color(0xFFE9E8F2);
  static const divider = Color(0xFFF0EFF6);
  static const error = Color(0xFFD94A64);
  static const success = Color(0xFF2F9D70);

  static const darkBackground = Color(0xFF11111A);
  static const darkSurface = Color(0xFF1B1B28);
  static const darkSurfaceMuted = Color(0xFF232334);
  static const darkText = Color(0xFFE8E6F0);
  static const darkTextSecondary = Color(0xFFB5B1C5);
  static const darkTextTertiary = Color(0xFF898598);
  static const darkBorder = Color(0xFF373449);
  static const darkDivider = Color(0xFF2B293B);
}

abstract final class NurseMateSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const section = 32.0;
  static const page = 20.0;
}

abstract final class NurseMateRadii {
  static const small = 14.0;
  static const input = 18.0;
  static const button = 20.0;
  static const card = 24.0;
  static const panel = 28.0;
}

abstract final class NurseMateMotion {
  static const standard = Duration(milliseconds: 300);
  static const fast = Duration(milliseconds: 250);
  static const curve = Curves.easeOutCubic;
}

abstract final class NurseMateShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x0F5D4DB2), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const floating = <BoxShadow>[
    BoxShadow(color: Color(0x185D4DB2), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
