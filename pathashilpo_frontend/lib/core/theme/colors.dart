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
