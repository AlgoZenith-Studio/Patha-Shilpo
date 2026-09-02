import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../i18n/generated/app_localizations.dart';
import '../../routing/route_names.dart';
import '../../theme/colors.dart';
import '../brand/app_logo.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/buyer/explore/buyer_explore_screen.dart';
import '../../../features/buyer/rfq/buyer_rfq_screen.dart';
import '../../../features/buyer/enquiries/buyer_enquiries_screen.dart';
import '../../../features/buyer/profile/buyer_profile_screen.dart';

class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BuyerExploreScreen(),
    BuyerRfqScreen(embedded: true),
    BuyerEnquiriesScreen(),
    BuyerProfileScreen(),
  ];

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
                  // Official Brand SVG Logo
                  const AppLogo(size: 38, showBackground: true),
                  const SizedBox(width: 10),

                  // Brand Titles with Pally Bold font
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
                        Text(
                          t.buyerTagline,
                          style: const TextStyle(
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
                  const SizedBox(width: 8),

                  // Cluster Tag badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.heritage.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.spa_outlined, size: 12, color: AppColors.action),
                        const SizedBox(width: 4),
                        Text(
                          t.buyerFairTrade,
                          style: const TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Quick Logout Button
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.action,
              unselectedItemColor: AppColors.border,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Pally',
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w500,
                fontSize: 11.5,
              ),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.explore_outlined),
                  activeIcon: const Icon(Icons.explore_rounded),
                  label: t.navExplore,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.request_quote_outlined),
                  activeIcon: const Icon(Icons.request_quote_rounded),
                  label: t.buyerBulkRfq,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  activeIcon: const Icon(Icons.chat_bubble_rounded),
                  label: t.navEnquiries,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline_rounded),
                  activeIcon: const Icon(Icons.person_rounded),
                  label: t.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
