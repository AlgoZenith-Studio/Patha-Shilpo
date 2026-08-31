import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';

/// The primary artisan-facing action button.
///
/// DESIGN_SYSTEM.md §2D: background [AppColors.action] with a white label.
///
/// **Single-language.** Earlier builds rendered English and Hindi together
/// regardless of locale. That rule was reversed by product decision: the
/// selected language now controls every string in the app, and no screen mixes
/// scripts. Callers pass an already-localised string from `AppLocalizations`.
class PrimaryBilingualButton extends StatelessWidget {
  const PrimaryBilingualButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// Localised label. Resolve it with `AppLocalizations.of(context)` at the
  /// call site — never hardcode a string here.
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: enabled ? AppColors.action : AppColors.border,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppShape.minTapTarget,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 22, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontFamilyFallback: AppTheme.scriptFallback,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
