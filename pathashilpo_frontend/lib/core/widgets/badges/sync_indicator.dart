import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';

/// Product sync lifecycle, mirroring the state machine in TRD.md §9.1.
enum SyncState { offlineProcessed, queued, syncing, upgraded, live }

/// A quiet inline progress line for the sync lifecycle.
///
/// Never a blocking spinner and never an error the artisan must resolve
/// (TRD.md §13.1) — the sync engine retries on its own.
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key, required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    final (IconData icon, String label, Color tint) appearance =
        switch (state) {
      SyncState.offlineProcessed => (
          Icons.save_rounded,
          t.syncSavedOnPhone,
          AppColors.border,
        ),
      SyncState.queued => (
          Icons.schedule_rounded,
          t.syncQueued,
          AppColors.border,
        ),
      SyncState.syncing => (
          Icons.sync_rounded,
          t.syncSyncing,
          AppColors.action,
        ),
      SyncState.upgraded => (
          Icons.auto_awesome_rounded,
          t.syncUpgraded,
          AppColors.heritage,
        ),
      SyncState.live => (
          Icons.check_circle_rounded,
          t.syncLive,
          AppColors.action,
        ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (state == SyncState.syncing)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: appearance.$3,
            ),
          )
        else
          Icon(appearance.$1, size: 16, color: appearance.$3),
        const SizedBox(width: 8),
        Text(
          appearance.$2,
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontFamilyFallback: AppTheme.scriptFallback,
            fontSize: 14,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
