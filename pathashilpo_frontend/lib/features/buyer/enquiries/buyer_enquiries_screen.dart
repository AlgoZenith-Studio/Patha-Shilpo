import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/enquiry_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

class BuyerEnquiriesScreen extends StatefulWidget {
  const BuyerEnquiriesScreen({super.key});

  @override
  State<BuyerEnquiriesScreen> createState() => _BuyerEnquiriesScreenState();
}

class _BuyerEnquiriesScreenState extends State<BuyerEnquiriesScreen> {
  String _filter = 'all'; // all | new | accepted

  /// Subscribed once so switching filter tabs does not re-subscribe. The
  /// filter is applied to the snapshot in [_applyFilter] instead.
  late final Stream<List<EnquiryModel>> _enquiryStream;

  @override
  void initState() {
    super.initState();
    final String uid =
        context.read<AuthController>().currentUser?.uid ?? '__none__';
    _enquiryStream = FirestoreService().streamBuyerEnquiries(uid);
  }

  List<EnquiryModel> _applyFilter(List<EnquiryModel> source) {
    if (_filter == 'all') return source;
    return source.where((EnquiryModel e) => e.status == _filter).toList();
  }

  void _showEnquiryDetails(EnquiryModel enquiry) {
    final AppLocalizations t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppShape.sheetRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: enquiry.productImageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: AppColors.canvas,
                        child: const Icon(Icons.palette_outlined,
                            size: 24, color: AppColors.action),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enquiry.productTitle,
                          style: const TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Artisan: ${enquiry.artisanName}',
                          style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 12,
                              color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                t.buyerYourMessage,
                style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  enquiry.message,
                  style: const TextStyle(
                      fontFamily: 'Lora', fontSize: 13.5, color: AppColors.ink),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quantity: ${enquiry.quantity} unit(s)',
                      style: const TextStyle(
                          fontFamily: 'Lora', fontWeight: FontWeight.w600)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: enquiry.status == 'accepted'
                          ? AppColors.giTagBg
                          : AppColors.canvas,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      enquiry.status == 'accepted'
                          ? t.buyerAcceptedByArtisan
                          : t.buyerAwaitingReply,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: enquiry.status == 'accepted'
                            ? AppColors.giTagGreen
                            : AppColors.action,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.ink,
                        content: Text(
                          'Direct phone connect initiated with ${enquiry.artisanName}',
                          style: const TextStyle(
                              fontFamily: 'Lora', color: AppColors.canvas),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_rounded, color: AppColors.ink),
                  label: const Text(
                    'Direct Phone Call with Artisan',
                    style: TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.ink),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).buyerSentEnquiries),
      ),
      body: StreamBuilder<List<EnquiryModel>>(
        stream: _enquiryStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<EnquiryModel>> snapshot) {
          final List<EnquiryModel> all =
              snapshot.data ?? const <EnquiryModel>[];
          final List<EnquiryModel> enquiries = _applyFilter(all);
          return Column(
            children: [
              // Filter Chips Strip. Counts come from the unfiltered snapshot, so
              // each tab shows its own total rather than the current view's.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    _buildFilterTab('All (${all.length})', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                        'New (${all.where((e) => e.status == 'new').length})',
                        'new'),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                        'Accepted (${all.where((e) => e.status == 'accepted').length})',
                        'accepted'),
                  ],
                ),
              ),

              // Enquiries List
              Expanded(
                child: enquiries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded,
                                size: 48, color: AppColors.border),
                            const SizedBox(height: 12),
                            const Text(
                              'No Enquiries Found',
                              style: TextStyle(
                                fontFamily: 'Pally',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Browse the craft collection and send enquiries to master artisans.',
                              style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 13,
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: enquiries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final enquiry = enquiries[index];
                          return _buildEnquiryCard(enquiry);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTab(String label, String key) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: isSelected ? 'Pally' : 'Lora',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12.5,
          color: isSelected ? AppColors.ink : AppColors.textMuted,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.heritage,
      backgroundColor: AppColors.surface,
      side:
          BorderSide(color: isSelected ? AppColors.heritage : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) {
        if (val) setState(() => _filter = key);
      },
    );
  }

  Widget _buildEnquiryCard(EnquiryModel enquiry) {
    final AppLocalizations t = AppLocalizations.of(context);
    return InkWell(
      onTap: () => _showEnquiryDetails(enquiry),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: enquiry.productImageUrl,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 54,
                      height: 54,
                      color: AppColors.canvas,
                      child: const Icon(Icons.palette_outlined,
                          size: 24, color: AppColors.action),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enquiry.productTitle,
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Artisan: ${enquiry.artisanName}',
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: enquiry.status == 'accepted'
                        ? AppColors.giTagBg
                        : AppColors.canvas,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    enquiry.status == 'accepted' ? 'Accepted' : 'Sent',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: enquiry.status == 'accepted'
                          ? AppColors.giTagGreen
                          : AppColors.action,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              enquiry.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Lora',
                fontSize: 13,
                color: AppColors.ink,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity: ${enquiry.quantity} pcs',
                  style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 11.5,
                      color: AppColors.textMuted),
                ),
                Text(
                  t.buyerTapForDetails,
                  style: const TextStyle(
                    fontFamily: 'Pally',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.action,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
