import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../theme/colors.dart';

/// Bottom-nav scaffold for the artisan (seller) shell.
///
/// One binary serves both roles (TRD.md AD-3); this shell is selected from
/// `session.role` before the network responds. The shell itself is cosmetic —
/// authorisation lives in the Security Rules (TRD.md §5.2).
class ArtisanShell extends StatelessWidget {
  const ArtisanShell({
    super.key,
    required this.currentIndex,
    required this.child,
    this.onDestinationSelected,
    this.onAddProduct,
  });

  final int currentIndex;
  final Widget child;
  final ValueChanged<int>? onDestinationSelected;
  final VoidCallback? onAddProduct;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(child: child),
      floatingActionButton: onAddProduct == null
          ? null
          : FloatingActionButton.extended(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: Text(t.navAdd),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onDestinationSelected,
        backgroundColor: AppColors.surface,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: t.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_rounded),
            label: t.navProducts,
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
