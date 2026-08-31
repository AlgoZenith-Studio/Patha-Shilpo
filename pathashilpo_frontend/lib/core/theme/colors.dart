import 'package:flutter/material.dart';

/// The approved brand palette — exactly five HEX codes, per DESIGN_SYSTEM.md §1.
///
/// Rule: always refer to these constants, never to a literal HEX, so the palette
/// stays consistent across every agent and implementation.
abstract final class AppColors {
  /// Primary app scaffold background canvas.
  static const Color canvas = Color(0xFFFFFBB6);

  /// Secondary accent — heritage badges, verified GI tag highlights.
  static const Color heritage = Color(0xFFD4A262);

  /// Primary CTA buttons, floating action buttons, active filter chips.
  static const Color action = Color(0xFFCC915C);

  /// Card borders, dividers, unselected chip borders, subtle secondary text.
  static const Color border = Color(0xFFBB8F67);

  /// All primary typography, headings, title text, high-contrast labels.
  static const Color ink = Color(0xFF513A24);

  /// Card and sheet surface. DESIGN_SYSTEM.md §2A specifies white surfaces
  /// sitting on the [canvas].
  static const Color surface = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // BUYER MODULE EXTENSIONS - pending design review.
  //
  // DESIGN_SYSTEM.md §1 defines a strict five-colour palette. The values
  // below came in with the buyer module and are NOT part of it. They are
  // kept separate (rather than silently folded into the five above) so the
  // divergence stays visible and can be either approved into the design
  // system or flattened onto the core palette.
  //
  // Everything here is used only by lib/features/buyer/**.
  // ---------------------------------------------------------------------

  /// Muted body text in the buyer UI. Closest core equivalent is [border].
  static const Color textMuted = Color(0xFF7D6043);
  static const Color textSecondary = Color(0xFF9E7E5E);

  /// GI-tag verification accents. Green carries "verified" meaning that the
  /// core palette has no equivalent for - DESIGN_SYSTEM.md §1 assigns that
  /// role to [heritage] instead.
  static const Color giTagGreen = Color(0xFF2E6B47);
  static const Color giTagBg = Color(0xFFE7F3EC);

  static const Color vermillionAccent = Color(0xFFC04A26);
  static const Color starAmber = Color(0xFFE08D2C);

  /// Gradients are built mostly from the approved five, with a few
  /// intermediate shades for depth.
  static const LinearGradient artisanHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF513A24), Color(0xFF835A36), Color(0xFFCC915C)],
  );

  static const LinearGradient warmOchreGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFD4A262), Color(0xFFCC915C)],
  );

  static const LinearGradient parchmentCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFFFFFFF), Color(0xFFFFFDF7), Color(0xFFF7F0E1)],
  );

  static const LinearGradient goldBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFE8C388), Color(0xFFD4A262), Color(0xFFBB8F67)],
  );

  static const LinearGradient sunsetTerracottaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFFCC915C), Color(0xFFD4A262)],
  );
}

/// Shape and stroke constants from DESIGN_SYSTEM.md §2.
abstract final class AppShape {
  /// Card corner radius (§2A).
  static const double cardRadius = 18;

  /// Bottom-sheet top corner radius (§2C).
  static const double sheetRadius = 24;

  /// Card and chip border stroke (§2A).
  static const double hairline = 0.8;

  /// Minimum tap target — PRD.md §8 accessibility requirement.
  static const double minTapTarget = 56;
}
