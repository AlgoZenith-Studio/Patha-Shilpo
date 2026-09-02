import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/buyer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../product/buyer_product_detail_screen.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final FirestoreService _firestore = FirestoreService();

  /// The live catalogue, read once and held so the saved list can resolve
  /// product ids to products. Saved ids live on the buyer document; the
  /// products themselves do not, so the two have to be joined client-side.
  List<ProductModel> _catalogue = const <ProductModel>[];

  late final Stream<BuyerModel?> _buyerStream;

  /// Whether anyone is signed in at all - distinct from whether their buyer
  /// profile document has loaded.
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    final AuthController auth = context.read<AuthController>();
    _signedIn = auth.currentUser != null;
    _buyerStream = _firestore.streamBuyer(auth.currentUser?.uid ?? '__none__');
    // A signed-in buyer whose buyers/{uid} document is missing gets it created
    // here. chooseRole() writes users/{uid} and buyers/{uid} separately and
    // swallows failures, so the pair can end up half-written - which is why a
    // logged-in buyer was being told to "sign in as a buyer".
    if (_signedIn) auth.ensureBuyerProfile();
    _loadCatalogue();
  }

  Future<void> _loadCatalogue() async {
    try {
      final List<ProductModel> products = await _firestore.fetchLiveProducts();
      if (!mounted) return;
      setState(() => _catalogue = products);
    } catch (_) {
      // Leaves the saved list empty rather than failing the whole profile.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    // Read from Localizations, not by watching LocaleProvider: the provider
    // lives above MaterialApp, so a dependency registered here is torn down
    // by the very rebuild it triggers. See LanguageSwitcher for the full
    // explanation of the assertion that caused.

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(t.buyerProfileTitle),
      ),
      body: StreamBuilder<BuyerModel?>(
        stream: _buyerStream,
        builder: (BuildContext context, AsyncSnapshot<BuyerModel?> snapshot) {
          final BuyerModel? buyer = snapshot.data;
          if (buyer == null) {
            // Three different situations, which must not share one message.
            // Telling a signed-in buyer to "sign in" is the bug this fixes.
            final Widget content;
            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const CircularProgressIndicator(color: AppColors.action);
            } else if (_signedIn) {
              // Signed in, profile still being repaired by ensureBuyerProfile.
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircularProgressIndicator(color: AppColors.action),
                  const SizedBox(height: 16),
                  Text(t.profileSettingUp,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              );
            } else {
              content = Text(t.profileSignInPrompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium);
            }
            return Center(
              child: Padding(padding: const EdgeInsets.all(32), child: content),
            );
          }

          final List<ProductModel> savedItems = _catalogue
              .where(
                  (ProductModel p) => buyer.savedProducts.contains(p.productId))
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buyer Identity Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.artisanHeroGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.heritage,
                        child: Text(
                          buyer.name.substring(0, 1),
                          style: const TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              buyer.name,
                              style: const TextStyle(
                                fontFamily: 'Pally',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: AppColors.canvas,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (buyer.company != null)
                              Text(
                                buyer.company!,
                                style: const TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 12.5,
                                  color: Color(0xFFF3E5D0),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.heritage.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppColors.heritage
                                        .withValues(alpha: 0.6)),
                              ),
                              child: Text(
                                t.buyerRoleSourcing(
                                    buyer.buyerType.toUpperCase()),
                                style: const TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.canvas,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sourcing Details / GSTIN
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buyer Sourcing Details',
                        style: TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildProfileRow('Phone:', buyer.phone),
                      if (buyer.email != null) ...[
                        const SizedBox(height: 6),
                        _buildProfileRow(t.buyerEmailLabel, buyer.email!),
                      ],
                      if (buyer.gstin != null) ...[
                        const SizedBox(height: 6),
                        _buildProfileRow(t.buyerGstinVerified, buyer.gstin!),
                      ],
                      const Divider(color: AppColors.border, height: 20),
                      const Text(
                        'Craft Interests:',
                        style: TextStyle(
                            fontFamily: 'Lora',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: buyer.interests
                            .map(
                              (interest) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bookmarked Handcrafted Masterpieces
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Saved Masterpieces (${savedItems.length})',
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (savedItems.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'No saved items yet. Tap the heart icon on any craft to save it.',
                        style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 13,
                            color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: savedItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = savedItems[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    BuyerProductDetailScreen(product: item)),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.canvas,
                                    child: const Icon(Icons.palette_outlined,
                                        size: 22, color: AppColors.action),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontFamily: 'Pally',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.ink,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '₹${item.priceFinal} • ${item.artisanCluster}',
                                      style: const TextStyle(
                                          fontFamily: 'Lora',
                                          fontSize: 12,
                                          color: AppColors.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: AppColors.border),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                // Language & Role Switch Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Language & Regional Settings',
                        style: TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildLangChoice('English', 'en'),
                          _buildLangChoice('हिंदी (Hindi)', 'hi'),
                          _buildLangChoice('বাংলা (Bengali)', 'bn'),
                        ],
                      ),
                      const Divider(color: AppColors.border, height: 24),
                      // Artisan Onboarding & Registration
                      Text(
                        t.buyerSwitchRole,
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Are you a rural craftsman or artisan? Complete artisan registration to list, price, and sell your handiwork.',
                        style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 12.5,
                            color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, Routes.artisanRegistration);
                          },
                          icon: const Icon(Icons.handyman_outlined,
                              color: AppColors.action),
                          label: const Text(
                            'Become an Artisan Seller',
                            style: TextStyle(
                              fontFamily: 'Pally',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.action, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(t.commonSignOut),
                          content: const Text(
                              'Are you sure you want to log out of Patha-Shilpo?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
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
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.login, (_) => false);
                        }
                      }
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.redAccent),
                    label: Text(
                      t.commonSignOut,
                      style: const TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        color: Colors.redAccent,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLangChoice(
      String label, String code) {
    final isSelected = Localizations.localeOf(context).languageCode == code;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: isSelected ? 'Pally' : 'Lora',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
          color: isSelected ? AppColors.ink : AppColors.textMuted,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.heritage,
      backgroundColor: AppColors.canvas,
      side:
          BorderSide(color: isSelected ? AppColors.heritage : AppColors.border),
      onSelected: (val) {
        if (val) {
          context.read<LocaleProvider>().setLocale(Locale(code));
        }
      },
    );
  }
}
