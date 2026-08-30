import 'package:flutter/material.dart';
import '../../theme/colors.dart';
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
    BuyerRfqScreen(),
    BuyerEnquiriesScreen(),
    BuyerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.canvasLight,
            border: Border(
              bottom: BorderSide(
                color: AppColors.surfaceBorder.withOpacity(0.6),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Brand Logo / Monogram
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.warmOchreGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ochreGold.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'प',
                        style: TextStyle(
                          fontFamily: 'Kalam',
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: AppColors.deepUmber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Brand Titles with Kalam Bold font
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'पाथ-शिल्प • Patha-Shilpo',
                        style: TextStyle(
                          fontFamily: 'Kalam',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.deepUmber,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Offline-First Rural Artisan Direct Trade',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Cluster Tag badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.canvasParchment,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.ochreGold.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.spa_outlined, size: 12, color: AppColors.terracottaClay),
                        SizedBox(width: 4),
                        Text(
                          'Fair-Trade',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepUmber,
                          ),
                        ),
                      ],
                    ),
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
          color: AppColors.cardSurface,
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceBorder.withOpacity(0.8),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepUmber.withOpacity(0.06),
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
              selectedItemColor: AppColors.terracottaClay,
              unselectedItemColor: AppColors.sandstone,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Kalam',
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w500,
                fontSize: 11.5,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore_rounded),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.request_quote_outlined),
                  activeIcon: Icon(Icons.request_quote_rounded),
                  label: 'Bulk RFQ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  activeIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Enquiries',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
