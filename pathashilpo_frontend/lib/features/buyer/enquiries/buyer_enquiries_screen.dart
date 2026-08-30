import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../data/mock/mock_buyer_data.dart';
import '../../../data/models/enquiry_model.dart';
import '../product/buyer_product_detail_screen.dart';

class BuyerEnquiriesScreen extends StatefulWidget {
  const BuyerEnquiriesScreen({super.key});

  @override
  State<BuyerEnquiriesScreen> createState() => _BuyerEnquiriesScreenState();
}

class _BuyerEnquiriesScreenState extends State<BuyerEnquiriesScreen> {
  String _filter = 'all'; // all | new | accepted

  List<EnquiryModel> get _filteredEnquiries {
    if (_filter == 'new') {
      return MockBuyerData.initialEnquiries.where((e) => e.status == 'new').toList();
    } else if (_filter == 'accepted') {
      return MockBuyerData.initialEnquiries.where((e) => e.status == 'accepted').toList();
    }
    return MockBuyerData.initialEnquiries;
  }

  void _showEnquiryDetails(EnquiryModel enquiry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.canvasLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.sandstone.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      enquiry.productImageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: AppColors.canvasParchment,
                        child: const Icon(Icons.palette_outlined, size: 24, color: AppColors.terracottaClay),
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
                            fontFamily: 'Kalam',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.deepUmber,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Artisan: ${enquiry.artisanName}',
                          style: const TextStyle(fontFamily: 'Lora', fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Message:',
                style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, color: AppColors.deepUmber),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  enquiry.message,
                  style: const TextStyle(fontFamily: 'Lora', fontSize: 13.5, color: AppColors.deepUmber),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quantity: ${enquiry.quantity} unit(s)', style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: enquiry.status == 'accepted' ? AppColors.giTagBg : AppColors.canvasParchment,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      enquiry.status == 'accepted' ? 'Accepted by Artisan' : 'Awaiting Reply',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: enquiry.status == 'accepted' ? AppColors.giTagGreen : AppColors.terracottaClay,
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
                        backgroundColor: AppColors.deepUmber,
                        content: Text(
                          'Direct phone connect initiated with ${enquiry.artisanName}',
                          style: const TextStyle(fontFamily: 'Lora', color: AppColors.canvasParchment),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_rounded, color: AppColors.deepUmber),
                  label: const Text(
                    'Direct Phone Call with Artisan',
                    style: TextStyle(fontFamily: 'Kalam', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.deepUmber),
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
    final enquiries = _filteredEnquiries;

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Sent Enquiries • पूछताछ'),
      ),
      body: Column(
        children: [
          // Filter Chips Strip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _buildFilterTab('All (${MockBuyerData.initialEnquiries.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterTab('New (${MockBuyerData.initialEnquiries.where((e) => e.status == 'new').length})', 'new'),
                const SizedBox(width: 8),
                _buildFilterTab('Accepted (${MockBuyerData.initialEnquiries.where((e) => e.status == 'accepted').length})', 'accepted'),
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
                        const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.sandstone),
                        const SizedBox(height: 12),
                        const Text(
                          'No Enquiries Found',
                          style: TextStyle(
                            fontFamily: 'Kalam',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.deepUmber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Browse the craft collection and send enquiries to master artisans.',
                          style: TextStyle(fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: enquiries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final enquiry = enquiries[index];
                      return _buildEnquiryCard(enquiry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String key) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: isSelected ? 'Kalam' : 'Lora',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12.5,
          color: isSelected ? AppColors.deepUmber : AppColors.textMuted,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.ochreGold,
      backgroundColor: AppColors.cardSurface,
      side: BorderSide(color: isSelected ? AppColors.ochreGold : AppColors.surfaceBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) {
        if (val) setState(() => _filter = key);
      },
    );
  }

  Widget _buildEnquiryCard(EnquiryModel enquiry) {
    return InkWell(
      onTap: () => _showEnquiryDetails(enquiry),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepUmber.withOpacity(0.04),
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
                  child: Image.network(
                    enquiry.productImageUrl,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 54,
                      height: 54,
                      color: AppColors.canvasParchment,
                      child: const Icon(Icons.palette_outlined, size: 24, color: AppColors.terracottaClay),
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
                          fontFamily: 'Kalam',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.deepUmber,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: enquiry.status == 'accepted' ? AppColors.giTagBg : AppColors.canvasParchment,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    enquiry.status == 'accepted' ? 'Accepted' : 'Sent',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: enquiry.status == 'accepted' ? AppColors.giTagGreen : AppColors.terracottaClay,
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
                color: AppColors.deepUmber,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity: ${enquiry.quantity} pcs',
                  style: const TextStyle(fontFamily: 'Lora', fontSize: 11.5, color: AppColors.textMuted),
                ),
                Text(
                  'Tap for details & call →',
                  style: const TextStyle(
                    fontFamily: 'Kalam',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.terracottaClay,
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
