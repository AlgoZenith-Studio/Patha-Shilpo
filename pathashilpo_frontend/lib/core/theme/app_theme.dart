import 'package:flutter/material.dart';

import 'colors.dart';

/// Application theme — the approved palette (DESIGN_SYSTEM.md §1) wired to the
/// approved type stack (TRD.md §10.1).
abstract final class AppTheme {
  /// Latin display faces supplied in `assets/data/`.
  static const String headingFont = 'Lora';
  static const String bodyFont = 'Pally';
  static const String accentFont = 'Rowan';

  /// CRITICAL — all three families are Latin-only: zero Devanagari (U+0900–097F)
  /// and zero Bengali (U+0980–09FF) glyphs. Without this fallback every Hindi
  /// string renders as tofu boxes, which breaks the bilingual-button rule in
  /// DESIGN_SYSTEM.md §2D. Android 8+ ships Noto, so this costs 0 MB against the
  /// APK budget. See TRD.md §10.1.
  static const List<String> scriptFallback = <String>[
    'Noto Sans Devanagari',
    'Noto Sans Bengali',
    'sans-serif',
  ];

  static TextStyle _heading(double size, FontWeight weight) => TextStyle(
        fontFamily: headingFont,
        fontFamilyFallback: scriptFallback,
        fontSize: size,
        fontWeight: weight,
        color: AppColors.ink,
      );

  static TextStyle _body(double size, FontWeight weight) => TextStyle(
        fontFamily: bodyFont,
        fontFamilyFallback: scriptFallback,
        fontSize: size,
        fontWeight: weight,
        color: AppColors.ink,
      );

  static TextStyle _accent(double size, FontStyle style) => TextStyle(
        fontFamily: accentFont,
        fontFamilyFallback: scriptFallback,
        fontSize: size,
        fontStyle: style,
        color: AppColors.ink,
      );

  /// Artisan stories, pull-quotes and provenance lines.
  static TextStyle get story => _accent(15, FontStyle.italic);

  /// Body sizes never drop below 16px — PRD.md §8 accessibility requirement.
  static final TextTheme textTheme = TextTheme(
    displayLarge: _heading(32, FontWeight.w700),
    displayMedium: _heading(28, FontWeight.w700),
    headlineLarge: _heading(24, FontWeight.w700),
    headlineMedium: _heading(22, FontWeight.w600),
    headlineSmall: _heading(20, FontWeight.w600),
    titleLarge: _heading(18, FontWeight.w600),
    titleMedium: _heading(17, FontWeight.w600),
    titleSmall: _body(16, FontWeight.w700),
    bodyLarge: _body(17, FontWeight.w400),
    bodyMedium: _body(16, FontWeight.w400),
    bodySmall: _body(14, FontWeight.w400),
    labelLarge: _body(16, FontWeight.w700),
    labelMedium: _body(14, FontWeight.w700),
    labelSmall: _body(13, FontWeight.w400),
  );

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.action,
      primary: AppColors.action,
      secondary: AppColors.heritage,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: AppColors.ink,
      onSurface: AppColors.ink,
      outline: AppColors.border,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: textTheme,
      fontFamily: bodyFont,
      fontFamilyFallback: scriptFallback,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _heading(22, FontWeight.w700),
      ),

      // §2A — white surface, 18dp radius, 0.8dp border.
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          side: const BorderSide(
            color: AppColors.border,
            width: AppShape.hairline,
          ),
        ),
      ),

      // §2D — primary action buttons.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.action,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppShape.minTapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
          ),
          textStyle: _body(16, FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(AppShape.minTapTarget),
          side: const BorderSide(
            color: AppColors.border,
            width: AppShape.hairline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
          ),
          textStyle: _body(16, FontWeight.w700),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.action,
        foregroundColor: Colors.white,
      ),

      // §2B — category filter rails.
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.action,
        checkmarkColor: Colors.white,
        labelStyle: _body(14, FontWeight.w400),
        secondaryLabelStyle: _body(14, FontWeight.w700).copyWith(
          color: Colors.white,
        ),
        side: const BorderSide(
          color: AppColors.border,
          width: AppShape.hairline,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),

      // §2C — draggable bottom sheets.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppShape.sheetRadius),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: _body(16, FontWeight.w400).copyWith(color: AppColors.border),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppShape.hairline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppShape.hairline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          borderSide: const BorderSide(color: AppColors.action, width: 1.6),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: AppShape.hairline,
        space: 1,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.action,
        unselectedItemColor: AppColors.border,
        selectedLabelStyle: _body(13, FontWeight.w700),
        unselectedLabelStyle: _body(13, FontWeight.w400),
        type: BottomNavigationBarType.fixed,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: _body(15, FontWeight.w400).copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.action,
      ),
    );
  }
}
