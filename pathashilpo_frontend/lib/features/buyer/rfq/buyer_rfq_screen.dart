import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/craft_taxonomy.dart';
import '../../../data/models/rfq_model.dart';

class BuyerRfqScreen extends StatefulWidget {
  final String? prefilledCraft;

  /// True when hosted inside [BuyerShell]'s IndexedStack, which already
  /// provides an app bar and a bottom nav. Without this the screen stacked a
  /// second AppBar inside the shell's body, eating the vertical space the
  /// "New request" control needed and pushing it below the fold.
  final bool embedded;

  const BuyerRfqScreen({
    super.key,
    this.prefilledCraft,
    this.embedded = false,
  });

  @override
  State<BuyerRfqScreen> createState() => _BuyerRfqScreenState();
}

class _BuyerRfqScreenState extends State<BuyerRfqScreen> {
  late String _selectedCraft;
  String? _selectedCluster;
  int _quantity = 25;

  /// Chosen by the buyer. Was previously a hardcoded const ('30 Nov 2026')
  /// that every RFQ card displayed as though the buyer had picked it.
  DateTime? _deadline;
  RangeValues _budgetRange = const RangeValues(25000, 150000);
  final TextEditingController _notesController = TextEditingController();
  bool _isCreatingRfq = false;

  static const List<String> _clusters = <String>[
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
    // Normalised so a craft passed in from a product detail page ('Dhokra
    // Lost-Wax Metal Casting') still selects a valid dropdown entry.
    _selectedCraft = CraftTaxonomy.categoryFor(widget.prefilledCraft) ??
        CraftTaxonomy.categories.first;
    // Reached from a product or storefront via "request a bulk quote": the
    // buyer already said what they want, so land on the form rather than on a
    // list of past requests they then have to find a button in.
    _isCreatingRfq = widget.prefilledCraft != null;
  }

  /// RfqModel.deadline is a String on the wire, so the picked date is stored
  /// as ISO-8601 (yyyy-MM-dd) - sortable, unambiguous, and locale-independent.
  /// Display goes through [_formatDeadline], which tolerates the free-text
  /// values ("30 Nov 2026") older documents carry.
  static String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _formatDeadline(String raw, AppLocalizations t) {
    if (raw.isEmpty) return t.rfqDeadlineNotSet;
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw; // legacy free text - show it as written
    return DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
        .format(parsed);
  }

  Future<void> _pickDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      // Handmade work needs lead time; a deadline in the past is not a request
      // any artisan can accept.
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submitRfq() async {
    final AppLocalizations t = AppLocalizations.of(context);

    if (_notesController.text.trim().isEmpty) {
      _toast(t.rfqNotesRequired, error: true);
      return;
    }
    if (_deadline == null) {
      _toast(t.rfqChooseDate, error: true);
      return;
    }

    final user = context.read<AuthController>().currentUser;
    if (user == null) {
      _toast(t.rfqSignInRequired, error: true);
      return;
    }

    final newRfq = RfqModel(
      // Left empty so Firestore allocates the id; the previous
      // 'rfq_<millis>' meant a double tap wrote two near-identical requests.
      rfqId: '',
      buyerUid: user.uid,
      buyerName: user.displayName ?? user.phoneNumber ?? 'Buyer',
      craft: _selectedCraft,
      cluster: _selectedCluster,
      quantity: _quantity,
      deadline: _isoDate(_deadline!),
      budgetMin: _budgetRange.start.toInt(),
      budgetMax: _budgetRange.end.toInt(),
      // Matching is server-side work that does not exist yet (TRD.md §19.6),
      // so this stays empty rather than showing fabricated matches.
      matchedArtisanIds: const <String>[],
      status: 'active',
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      // Firestore's set() future does not complete until the SERVER
      // acknowledges the write. On a weak connection that means this await
      // never returns and the button appears to do nothing at all - the write
      // is queued locally the whole time and will sync on its own. So we wait
      // only briefly for confirmation and treat a timeout as "queued", which
      // is what actually happened.
      await FirestoreService()
          .createRfq(newRfq)
          .timeout(const Duration(seconds: 8));
    } on TimeoutException {
      if (!mounted) return;
      _toast(t.rfqQueuedOffline);
      setState(() {
        _isCreatingRfq = false;
        _notesController.clear();
        _deadline = null;
      });
      return;
    } on FirebaseException catch (e) {
      if (!mounted) return;
      // The code matters when this fails: 'permission-denied' means the role
      // is wrong, not that the network is down.
      _toast('${t.rfqSendFailed} (${e.code})', error: true);
      return;
    } catch (_) {
      if (!mounted) return;
      _toast(t.rfqSendFailed, error: true);
      return;
    }
    if (!mounted) return;

    setState(() {
      _isCreatingRfq = false;
      _notesController.clear();
      _deadline = null;
    });
    // No artisan count here: nothing has matched yet, and the old message
    // claimed a broadcast to N "master artisans" that never happened.
    _toast(t.rfqSent);
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? AppColors.vermillionAccent : AppColors.ink,
        content: Text(
          message,
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
      // Always reachable, whatever has scrolled out of view. The inline
      // "New RFQ" button sat inside the scroll view under a large banner, so
      // on a phone it was frequently off-screen.
      floatingActionButton: _isCreatingRfq
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _isCreatingRfq = true),
              backgroundColor: AppColors.action,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(t.buyerNewRfq),
            ),
      appBar: widget.embedded
          ? null
          : AppBar(
        title: Text(t.buyerBulkAndCustomRfqs),
        actions: [
          IconButton(
            icon: Icon(
              _isCreatingRfq
                  ? Icons.list_alt_rounded
                  : Icons.add_circle_outline_rounded,
              color: AppColors.ink,
            ),
            tooltip:
                _isCreatingRfq ? t.buyerViewActiveRfqs : t.buyerCreateNewRfq,
            onPressed: () {
              setState(() {
                _isCreatingRfq = !_isCreatingRfq;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Room for the FAB so it never covers the last card.
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
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
                  const Icon(Icons.handshake_outlined,
                      size: 36, color: AppColors.canvas),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.rfqHeroTitle,
                          style: TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.canvas,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.rfqHeroBody,
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
              Text(
                t.rfqSelectCraft,
                style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink),
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
                    items: CraftTaxonomy.categories
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(fontFamily: 'Lora'))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCraft = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Cluster Preference
              Text(
                t.rfqTargetCluster,
                style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink),
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
                  child: DropdownButton<String?>(
                    value: _selectedCluster,
                    isExpanded: true,
                    // null is a real choice here - "no cluster preference" -
                    // so the value is nullable rather than a magic string.
                    items: <DropdownMenuItem<String?>>[
                      DropdownMenuItem<String?>(
                          value: null,
                          child: Text(t.rfqAllClusters,
                              style: const TextStyle(fontFamily: 'Lora'))),
                      for (final String c in _clusters)
                        DropdownMenuItem<String?>(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(fontFamily: 'Lora'))),
                    ],
                    onChanged: (val) => setState(() => _selectedCluster = val),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.rfqQuantityLabel,
                    style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                  Text(
                    t.rfqPieces(_quantity),
                    style: const TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.ink),
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

              // Delivery deadline - buyer-chosen. Handmade work is quoted
              // against a date, so this is required before an RFQ can go out.
              Text(
                t.rfqDeadlineLabel,
                style: const TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.event_outlined,
                          size: 18, color: AppColors.action),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _deadline == null
                              ? t.rfqChooseDate
                              : _formatDeadline(_isoDate(_deadline!), t),
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 14,
                            color: _deadline == null
                                ? AppColors.textMuted
                                : AppColors.ink,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: AppColors.border),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Budget Range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.buyerBudgetBracket,
                    style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink),
                  ),
                  Text(
                    '₹${(_budgetRange.start / 1000).toStringAsFixed(0)}K - ₹${(_budgetRange.end / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.ink),
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
              Text(
                t.rfqSpecsLabel,
                style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 4,
                style: const TextStyle(
                    fontFamily: 'Lora', fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(hintText: t.rfqSpecsHint),
              ),
              const SizedBox(height: 14),

              // Match Indicator Chip
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.heritage.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hub_outlined,
                        color: AppColors.action, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.rfqMatchNote,
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
                  label: Text(
                    t.rfqBroadcast,
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
                    style: TextStyle(
                        fontFamily: 'Lora', color: AppColors.textMuted),
                  ),
                ),
              ),
            ] else ...[
              // ACTIVE RFQs LIST - live from Firestore
              StreamBuilder<List<RfqModel>>(
                stream: FirestoreService().streamBuyerRfqs(
                    context.read<AuthController>().currentUser?.uid ??
                        '__none__'),
                builder:
                    (BuildContext context, AsyncSnapshot<List<RfqModel>> snap) {
                  final List<RfqModel> rfqs = snap.data ?? const <RfqModel>[];
                  final bool loading =
                      snap.connectionState == ConnectionState.waiting;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // The create action lives in the FloatingActionButton.
                      // It used to also sit here as an ElevatedButton inside
                      // this Row, which inherits the theme's infinite minimum
                      // width and threw "BoxConstraints forces an infinite
                      // width" - the whole screen failed to lay out, which is
                      // why adding an RFQ appeared impossible.
                      Text(
                        '${t.buyerActiveQuotations} (${rfqs.length})',
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (snap.hasError)
                        _emptyBox(context, t.buyerRfqLoadFailed, '')
                      else if (rfqs.isEmpty)
                        _emptyBox(context, t.buyerNoActiveRfqs,
                            t.buyerNoActiveRfqsBody)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rfqs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) =>
                              _buildRfqCard(rfqs[index]),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(BuildContext context, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            const Icon(Icons.inventory_2_outlined,
                size: 48, color: AppColors.border),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (body.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.heritage.withValues(alpha: 0.6)),
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
                  color: rfq.status == 'matched'
                      ? AppColors.giTagBg
                      : AppColors.canvas,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rfq.status == 'matched'
                      ? '● ${t.rfqStatusMatched}'
                      : '● ${t.rfqStatusActive}',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: rfq.status == 'matched'
                        ? AppColors.giTagGreen
                        : AppColors.action,
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
              Flexible(
                  child:
                      _buildRfqMeta(t.buyerQuantity, t.rfqPcs(rfq.quantity))),
              const SizedBox(width: 8),
              Flexible(
                  child: _buildRfqMeta(
                      t.buyerDeadline, _formatDeadline(rfq.deadline, t))),
              const SizedBox(width: 8),
              Flexible(
                  child: _buildRfqMeta(t.buyerBudget,
                      '₹${(rfq.budgetMin / 1000).toStringAsFixed(0)}K - ₹${(rfq.budgetMax / 1000).toStringAsFixed(0)}K')),
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
          style: const TextStyle(
              fontFamily: 'Lora', fontSize: 11, color: AppColors.textMuted),
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
