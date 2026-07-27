import 'package:flutter/material.dart';

import 'screens/infusion_calculator_screen.dart';

void main() {
  runApp(const NurseMateApp());
}

class NurseMateApp extends StatelessWidget {
  const NurseMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF17324D);
    const blue = Color(0xFF2166D1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NurseMate',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
          titleLarge: TextStyle(
            color: navy,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          titleMedium: TextStyle(color: navy, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: Color(0xFF344B60), height: 1.45),
          bodyMedium: TextStyle(color: Color(0xFF5B6F82), height: 1.45),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: blue, width: 2),
          ),
          errorMaxLines: 2,
        ),
      ),
      home: const InfusionCalculatorScreen(),
    );
  }
}
