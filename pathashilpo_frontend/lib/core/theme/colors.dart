import 'package:flutter/material.dart';

/// Patha-Shilpo Artistic Color Palette
/// Derived directly from the heritage Indian handicraft warm earthy aesthetic:
/// - Lighter background: #FFFBB6 / #FFFDF0
/// - Warm Ochre: #D4A262
/// - Terracotta Clay: #CC915C
/// - Sandstone / Khadi: #BB8F67
/// - Deep Umber / Roasted Earth: #513A24
class AppColors {
  AppColors._();

  // Core Palette from user specification
  static const Color canvasLight = Color(0xFFFDFBF7); // Clean, ultra-light warm canvas
  static const Color canvasParchment = Color(0xFFF9F5EC); // Light warm background
  static const Color ochreGold = Color(0xFFD4A262); // Warm Ochre
  static const Color terracottaClay = Color(0xFFCC915C); // Warm Clay
  static const Color sandstone = Color(0xFFBB8F67); // Sandstone Khadi
  static const Color deepUmber = Color(0xFF513A24); // Roasted Earth / Primary Text

  // Surface & Neutral Tints
  static const Color cardSurface = Color(0xFFFFFFFF); // Crisp clean white card surface
  static const Color cardSurfaceAlt = Color(0xFFFAF6EE); // Subtle warm surface
  static const Color chipBackground = Color(0xFFF6EEDC); // Distinct tag/chip background
  static const Color surfaceBorder = Color(0xFFE8DECE); // Refined subtle border
  static const Color textMuted = Color(0xFF7D6043);
  static const Color textSecondary = Color(0xFF9E7E5E);

  // Heritage Accents
  static const Color giTagGreen = Color(0xFF2E6B47);
  static const Color giTagBg = Color(0xFFE7F3EC);
  static const Color vermillionAccent = Color(0xFFC04A26);
  static const Color starAmber = Color(0xFFE08D2C);

  // Gradients for artistic depth
  static const LinearGradient artisanHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF513A24),
      Color(0xFF835A36),
      Color(0xFFCC915C),
    ],
  );

  static const LinearGradient warmOchreGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4A262),
      Color(0xFFCC915C),
    ],
  );

  static const LinearGradient parchmentCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFDF7),
      Color(0xFFF7F0E1),
    ],
  );

  static const LinearGradient goldBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8C388),
      Color(0xFFD4A262),
      Color(0xFFBB8F67),
    ],
  );

  static const LinearGradient sunsetTerracottaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFCC915C),
      Color(0xFFD4A262),
    ],
  );
}
