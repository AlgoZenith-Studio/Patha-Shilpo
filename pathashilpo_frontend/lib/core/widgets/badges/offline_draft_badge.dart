import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';

/// "Offline Draft" chip shown on a product saved without a network.
///
/// This badge is the visible proof of the product thesis — the artisan has a
/// complete, sellable listing with no internet. It is reassurance, never a
/// warning, so it must never read as an error state (TRD.md §13.1).
class OfflineDraftBadge extends StatelessWidget {
  const OfflineDraftBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.heritage,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.cloud_off_rounded,
            size: compact ? 13 : 16,
            color: AppColors.ink,
          ),
          SizedBox(width: compact ? 5 : 7),
          Flexible(
            child: Text(
              t.reviewOfflineDraft,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontFamilyFallback: AppTheme.scriptFallback,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
