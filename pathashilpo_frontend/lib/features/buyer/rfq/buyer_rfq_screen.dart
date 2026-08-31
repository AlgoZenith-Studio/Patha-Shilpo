import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../data/mock/mock_buyer_data.dart';
import '../../../data/models/rfq_model.dart';

class BuyerRfqScreen extends StatefulWidget {
  final String? prefilledCraft;

  const BuyerRfqScreen({super.key, this.prefilledCraft});

  @override
  State<BuyerRfqScreen> createState() => _BuyerRfqScreenState();
}

class _BuyerRfqScreenState extends State<BuyerRfqScreen> {
  late String _selectedCraft;
  String _selectedCluster = 'All Clusters';
  int _quantity = 25;
  final String _deadline = '30 Nov 2026';
  RangeValues _budgetRange = const RangeValues(25000, 150000);
  final TextEditingController _notesController = TextEditingController();
  bool _isCreatingRfq = false;

  final List<String> _clusters = [
    'All Clusters',
    'Chanderi (MP)',
    'Bankura (WB)',
    'Bastar (CG)',
    'Mithila / Madhubani (BR)',
    'Varanasi (UP)',
    'Kutch (GJ)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCraft = widget.prefilledCraft ?? 'Handloom Weaving';
  }

  int get _estimatedArtisanMatches {
    if (_selectedCraft == 'Handloom Weaving') return 18;
    if (_selectedCraft == 'Terracotta Pottery') return 12;
    if (_selectedCraft == 'Metal Casting') return 8;
    if (_selectedCraft == 'Folk Art Painting') return 14;
    return 6;
  }

  void _submitRfq() {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.vermillionAccent,
          content: Text('Please describe your requirements/specifications.', style: TextStyle(fontFamily: 'Lora')),
        ),
      );
      return;
    }

    final newRfq = RfqModel(
      rfqId: 'rfq_${DateTime.now().millisecondsSinceEpoch}',
      buyerUid: MockBuyerData.currentBuyer.uid,
      buyerName: MockBuyerData.currentBuyer.name,
      craft: _selectedCraft,
      cluster: _selectedCluster != 'All Clusters' ? _selectedCluster : null,
      quantity: _quantity,
      deadline: _deadline,
      budgetMin: _budgetRange.start.toInt(),
      budgetMax: _budgetRange.end.toInt(),
      matchedArtisanIds: ['artisan_001', 'artisan_002'],
      status: 'active',
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      MockBuyerData.initialRfqs.insert(0, newRfq);
      _isCreatingRfq = false;
      _notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        content: Text(
          'RFQ broadcasted to $_estimatedArtisanMatches master artisans! You will receive quotations directly.',
          style: const TextStyle(fontFamily: 'Lora', color: AppColors.canvas),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(t.buyerBulkAndCustomRfqs),
        actions: [
          IconButton(
            icon: Icon(
              _isCreatingRfq ? Icons.list_alt_rounded : Icons.add_circle_outline_rounded,
              color: AppColors.ink,
            ),
            tooltip: _isCreatingRfq ? t.buyerViewActiveRfqs : t.buyerCreateNewRfq,
            onPressed: () {
              setState(() {
                _isCreatingRfq = !_isCreatingRfq;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Intro Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.sunsetTerracottaGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake_outlined, size: 36, color: AppColors.canvas),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Direct Sourcing from Rural Clusters',
                          style: TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.canvas,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Post custom specifications, bulk orders, or corporate gifting needs with zero intermediary margins.',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_isCreatingRfq) ...[
              // RFQ CREATION FORM
              Text(
                t.buyerRfqForm,
                style: TextStyle(
                  fontFamily: 'Pally',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),

              // Craft Type Picker
              const Text(
                'Select Craft Discipline:',
                style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCraft,
                    isExpanded: true,
                    items: MockBuyerData.craftCategories
                        .where((c) => c != 'All Crafts')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Lora'))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCraft = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Cluster Preference
              const Text(
                'Target Cluster / Region:',
                style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCluster,
                    isExpanded: true,
                    items: _clusters
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Lora'))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCluster = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Quantity (Units):',
                    style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  Text(
                    '$_quantity pieces',
                    style: const TextStyle(fontFamily: 'Pally', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink),
                  ),
                ],
              ),
              Slider(
                value: _quantity.toDouble(),
                min: 5,
                max: 500,
                divisions: 99,
                activeColor: AppColors.heritage,
                inactiveColor: AppColors.border,
                onChanged: (val) {
                  setState(() => _quantity = val.round());
                },
              ),
              const SizedBox(height: 10),

              // Budget Range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.buyerBudgetBracket,
                    style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  Text(
                    '₹${(_budgetRange.start / 1000).toStringAsFixed(0)}K - ₹${(_budgetRange.end / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontFamily: 'Pally', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink),
                  ),
                ],
              ),
              RangeSlider(
                values: _budgetRange,
                min: 5000,
                max: 500000,
                divisions: 99,
                activeColor: AppColors.action,
                inactiveColor: AppColors.border,
                onChanged: (val) {
                  setState(() => _budgetRange = val);
                },
              ),
              const SizedBox(height: 10),

              // Notes & Requirements
              const Text(
                'Specifications & Customization Details:',
                style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 4,
                style: const TextStyle(fontFamily: 'Lora', fontSize: 14, color: AppColors.ink),
                decoration: const InputDecoration(
                  hintText: 'Describe colors, dimensions, motifs, packaging needs, or attach reference briefs...',
                ),
              ),
              const SizedBox(height: 14),

              // Match Indicator Chip
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.heritage.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hub_outlined, color: AppColors.action, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Automatically matches $_estimatedArtisanMatches certified rural artisans in selected cluster.',
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 12.5,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Submit RFQ Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitRfq,
                  icon: const Icon(Icons.send_rounded, color: AppColors.ink),
                  label: const Text(
                    'Broadcast RFQ to Artisans • कोटेशन मंगाएं',
                    style: TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isCreatingRfq = false),
                  child: Text(
                    t.buyerCancelViewRfqs,
                    style: TextStyle(fontFamily: 'Lora', color: AppColors.textMuted),
                  ),
                ),
              ),
            ] else ...[
              // ACTIVE RFQs LIST
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Quotations (${MockBuyerData.initialRfqs.length})',
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColors.ink,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isCreatingRfq = true),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.ink),
                    label: Text(t.buyerNewRfq),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (MockBuyerData.initialRfqs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.border),
                        SizedBox(height: 10),
                        Text(
                          t.buyerNoActiveRfqs,
                          style: TextStyle(fontFamily: 'Pally', fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.ink),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Create your first custom quote request to connect with master artisans.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: MockBuyerData.initialRfqs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rfq = MockBuyerData.initialRfqs[index];
                    return _buildRfqCard(rfq);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRfqCard(RfqModel rfq) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.heritage.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    rfq.craft,
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: rfq.status == 'matched' ? AppColors.giTagBg : AppColors.canvas,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rfq.status == 'matched' ? '● Quotations Received' : '● Active Sourcing',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: rfq.status == 'matched' ? AppColors.giTagGreen : AppColors.action,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rfq.notes ?? 'Bulk requirement for handcrafted collection.',
            style: const TextStyle(
              fontFamily: 'Lora',
              fontSize: 13.5,
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildRfqMeta(t.buyerQuantity, '${rfq.quantity} pcs')),
              const SizedBox(width: 8),
              Flexible(child: _buildRfqMeta(t.buyerDeadline, rfq.deadline)),
              const SizedBox(width: 8),
              Flexible(child: _buildRfqMeta(t.buyerBudget, '₹${(rfq.budgetMin / 1000).toStringAsFixed(0)}K - ₹${(rfq.budgetMax / 1000).toStringAsFixed(0)}K')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRfqMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Lora', fontSize: 11, color: AppColors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Pally',
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            color: AppColors.ink,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
