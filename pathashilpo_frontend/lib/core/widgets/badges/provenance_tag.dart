import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';

/// Provenance chip — GI tag, cluster, technique or verification status.
///
/// Provenance is *data*, not AI (mvp PIPELINE 6): it travels with every listing
/// and is what lets a buyer tell handmade from machine-made.
class ProvenanceTag extends StatelessWidget {
  const ProvenanceTag({
    super.key,
    required this.label,
    this.icon,
    this.verified = false,
  });

  final String label;
  final IconData? icon;

  /// Verified tags use [AppColors.heritage] per DESIGN_SYSTEM.md §1.
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: verified ? AppColors.heritage : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: verified ? AppColors.heritage : AppColors.border,
          width: AppShape.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon ?? (verified ? Icons.verified_rounded : Icons.place_outlined),
            size: 14,
            color: AppColors.ink,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.bodyFont,
              fontFamilyFallback: AppTheme.scriptFallback,
              fontSize: 13,
              fontWeight: verified ? FontWeight.w700 : FontWeight.w400,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
