import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../theme/colors.dart';

/// Bottom-nav scaffold for the buyer shell.
///
/// Buyers are assumed online (mvp PIPELINE 5) — there is no offline browse
/// guarantee here beyond the `cache_products` box.
class BuyerShell extends StatelessWidget {
  const BuyerShell({
    super.key,
    required this.currentIndex,
    required this.child,
    this.onDestinationSelected,
  });

  final int currentIndex;
  final Widget child;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onDestinationSelected,
        backgroundColor: AppColors.surface,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_rounded),
            label: t.navExplore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.request_quote_rounded),
            label: t.navRfq,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum_rounded),
            label: t.navEnquiries,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: t.navProfile,
          ),
        ],
      ),
    );
  }
}
