import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvasLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.ochreGold,
        secondary: AppColors.terracottaClay,
        surface: AppColors.cardSurface,
        onPrimary: AppColors.deepUmber,
        onSecondary: Colors.white,
        onSurface: AppColors.deepUmber,
        outline: AppColors.surfaceBorder,
      ),
      fontFamily: 'Lora',
      textTheme: const TextTheme(
        // Introductory titles & brand headers use Pally Bold
        displayLarge: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w700,
          fontSize: 32,
          color: AppColors.deepUmber,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w700,
          fontSize: 26,
          color: AppColors.deepUmber,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: AppColors.deepUmber,
          letterSpacing: -0.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.deepUmber,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.deepUmber,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.deepUmber,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: AppColors.deepUmber,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Lora',
          fontWeight: FontWeight.normal,
          fontSize: 13.5,
          color: AppColors.textMuted,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.deepUmber,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvasLight,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepUmber),
        titleTextStyle: TextStyle(
          fontFamily: 'Pally',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: AppColors.deepUmber,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ochreGold,
          foregroundColor: AppColors.deepUmber,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Pally',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.terracottaClay, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Lora',
          color: AppColors.sandstone,
          fontSize: 14,
        ),
      ),
    );
  }
}
