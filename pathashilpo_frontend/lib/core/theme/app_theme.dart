import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// Consumer-Grade Theme strictly referencing explicit HEX codes
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.hexFFFBB6, // #fffbb6
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.hexCC915C, // #cc915c
        primary: AppColors.hexCC915C,   // #cc915c
        secondary: AppColors.hexD4A262, // #d4a262
        surface: AppColors.surfaceWhite,
        background: AppColors.hexFFFBB6,// #fffbb6
        error: AppColors.statusError,
        onPrimary: Colors.white,
        onSurface: AppColors.hex513A24, // #513a24
      ),
      // Card Theme using #bb8f67 for borders
      cardTheme: CardTheme(
        color: AppColors.surfaceWhite,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.hexBB8F67, width: 0.8), // #bb8f67
        ),
      ),
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.hexFFFBB6, // #fffbb6
        foregroundColor: AppColors.hex513A24, // #513a24
        elevation: 0,
        centerTitle: false,
      ),
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceWhite,
        modalBackgroundColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        elevation: 8,
      ),
      // Floating Action Button Theme (#cc915c)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.hexCC915C, // #cc915c
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
      // Category Filter Chips (#bb8f67 border, #cc915c selected)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedColor: AppColors.hexCC915C, // #cc915c
        side: const BorderSide(color: AppColors.hexBB8F67, width: 0.8), // #bb8f67
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        labelStyle: AppTypography.caption.copyWith(color: AppColors.hex513A24), // #513a24
      ),
    );
  }
}
