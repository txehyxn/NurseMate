import 'package:flutter/material.dart';

import 'nursemate_tokens.dart';

abstract final class NurseMateTheme {
  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: NurseMateColors.primary,
          brightness: Brightness.light,
          surface: NurseMateColors.surface,
        ).copyWith(
          primary: NurseMateColors.primary,
          onPrimary: Colors.white,
          secondary: NurseMateColors.blue,
          onSecondary: Colors.white,
          error: NurseMateColors.error,
          surfaceContainerLowest: NurseMateColors.surface,
          surfaceContainerLow: NurseMateColors.surfaceMuted,
          outline: NurseMateColors.border,
          outlineVariant: NurseMateColors.divider,
        );

    final textTheme = const TextTheme(
      displaySmall: TextStyle(
        color: NurseMateColors.navy,
        fontSize: 40,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        color: NurseMateColors.navy,
        fontSize: 30,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.9,
      ),
      headlineSmall: TextStyle(
        color: NurseMateColors.navy,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      titleLarge: TextStyle(
        color: NurseMateColors.navy,
        fontSize: 21,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(
        color: NurseMateColors.navy,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: NurseMateColors.text,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: NurseMateColors.textSecondary,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: NurseMateColors.textTertiary,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: NurseMateColors.navy,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NurseMateColors.background,
      textTheme: textTheme,
      dividerColor: NurseMateColors.divider,
      splashColor: NurseMateColors.primary.withValues(alpha: 0.06),
      highlightColor: NurseMateColors.primary.withValues(alpha: 0.03),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: NurseMateColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: NurseMateColors.navy,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: NurseMateColors.navy,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: NurseMateColors.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NurseMateRadii.card),
          side: const BorderSide(color: NurseMateColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NurseMateColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NurseMateSpacing.lg,
          vertical: 18,
        ),
        border: inputBorder(NurseMateColors.border),
        enabledBorder: inputBorder(NurseMateColors.border),
        focusedBorder: inputBorder(NurseMateColors.primary, 1.8),
        errorBorder: inputBorder(NurseMateColors.error),
        focusedErrorBorder: inputBorder(NurseMateColors.error, 1.8),
        labelStyle: const TextStyle(color: NurseMateColors.textSecondary),
        hintStyle: const TextStyle(color: NurseMateColors.textTertiary),
        errorMaxLines: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          backgroundColor: NurseMateColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NurseMateRadii.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: NurseMateColors.primary,
          side: const BorderSide(color: NurseMateColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NurseMateRadii.button),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: NurseMateColors.textSecondary,
          shape: const CircleBorder(),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: NurseMateColors.surface,
        indicatorColor: NurseMateColors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? NurseMateColors.primary
                : NurseMateColors.textSecondary,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? NurseMateColors.primary
                : NurseMateColors.textSecondary,
            size: 25,
          );
        }),
      ),
    );
  }

  static ThemeData dark() {
    const background = NurseMateColors.darkBackground;
    const surface = NurseMateColors.darkSurface;
    const surfaceMuted = NurseMateColors.darkSurfaceMuted;
    const text = NurseMateColors.darkText;
    const textSecondary = NurseMateColors.darkTextSecondary;
    const textTertiary = NurseMateColors.darkTextTertiary;
    const border = NurseMateColors.darkBorder;
    const divider = NurseMateColors.darkDivider;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: NurseMateColors.primary,
          brightness: Brightness.dark,
          surface: surface,
        ).copyWith(
          primary: NurseMateColors.primary,
          onPrimary: Colors.white,
          secondary: NurseMateColors.blue,
          onSecondary: Colors.white,
          error: const Color(0xFFFF8FA5),
          surface: surface,
          onSurface: text,
          onSurfaceVariant: textSecondary,
          surfaceContainerLowest: surface,
          surfaceContainerLow: surfaceMuted,
          outline: border,
          outlineVariant: divider,
        );

    final textTheme = const TextTheme(
      displaySmall: TextStyle(
        color: text,
        fontSize: 40,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        color: text,
        fontSize: 30,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.9,
      ),
      headlineSmall: TextStyle(
        color: text,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      titleLarge: TextStyle(
        color: text,
        fontSize: 21,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(
        color: text,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: text, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
      bodySmall: TextStyle(color: textTertiary, fontSize: 12, height: 1.4),
      labelLarge: TextStyle(
        color: text,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      dividerColor: divider,
      iconTheme: const IconThemeData(color: textSecondary),
      splashColor: NurseMateColors.primary.withValues(alpha: 0.12),
      highlightColor: NurseMateColors.primary.withValues(alpha: 0.07),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: text,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NurseMateRadii.card),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NurseMateSpacing.lg,
          vertical: 18,
        ),
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(colorScheme.primary, 1.8),
        errorBorder: inputBorder(colorScheme.error),
        focusedErrorBorder: inputBorder(colorScheme.error, 1.8),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
        errorMaxLines: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NurseMateRadii.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: colorScheme.primary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NurseMateRadii.button),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: textSecondary,
          shape: const CircleBorder(),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: surface,
        indicatorColor: NurseMateColors.primary.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : textSecondary,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : textSecondary,
            size: 25,
          );
        }),
      ),
    );
  }
}
