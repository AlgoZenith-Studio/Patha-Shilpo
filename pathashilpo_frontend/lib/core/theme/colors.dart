import 'package:flutter/material.dart';

/// @UI_UX Strict HEX-Based Palette
/// Always reference HEX codes directly to prevent discrepancy.
class AppColors {
  AppColors._();

  // 1. Exactly matched 5 HEX codes from approved palette:
  static const Color hexFFFBB6 = Color(0xFFFFFBB6); // #fffbb6 · RGB(255, 251, 182)
  static const Color hexD4A262 = Color(0xFFD4A262); // #d4a262 · RGB(212, 162, 98)
  static const Color hexCC915C = Color(0xFFCC915C); // #cc915c · RGB(204, 145, 92)
  static const Color hexBB8F67 = Color(0xFFBB8F67); // #bb8f67 · RGB(187, 143, 103)
  static const Color hex513A24 = Color(0xFF513A24); // #513a24 · RGB(81, 58, 36)

  // Semantic mappings strictly tied to the 5 HEX codes:
  static const Color background   = hexFFFBB6; // #fffbb6 (App Background & Highlights)
  static const Color secondary    = hexD4A262; // #d4a262 (Accent Badges & Secondary Elements)
  static const Color primary      = hexCC915C; // #cc915c (Primary Action CTA & Buttons)
  static const Color border       = hexBB8F67; // #bb8f67 (Card Borders & Subtle Dividers)
  static const Color textPrimary  = hex513A24; // #513a24 (Headings, Body & High-Contrast Text)
  
  // Neutral container white
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  // Status Badges
  static const Color statusOfflineDraft = Color(0xFFD97706); // Amber
  static const Color statusSyncing      = Color(0xFF2563EB); // Blue
  static const Color statusLive         = Color(0xFF16A34A); // Green
  static const Color statusError        = Color(0xFFDC2626); // Red
}
