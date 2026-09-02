import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../routing/route_names.dart';
import '../../theme/colors.dart';
import '../brand/app_logo.dart';
import '../../../features/auth/controllers/auth_controller.dart';

/// Bottom-nav scaffold for the artisan (seller) shell.
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

  Future<void> _handleLogout(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.commonSignOut),
        content: const Text('Are you sure you want to log out of Patha-Shilpo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.action,
              foregroundColor: Colors.white,
            ),
            child: Text(t.commonSignOut),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthController>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.canvas,
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const AppLogo(size: 38, showBackground: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          t.appName,
                          style: const TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Artisan Studio · कारीगर केंद्र',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.ink),
                    tooltip: t.commonSignOut,
                    onPressed: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
