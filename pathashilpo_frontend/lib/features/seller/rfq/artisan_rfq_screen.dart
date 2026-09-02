import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/artisan_model.dart';
import '../../../data/models/rfq_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

/// Open bulk requests from buyers that this artisan could fulfil.
///
/// This is the artisan half of the RFQ loop: a buyer posts a request, artisans
/// whose craft matches see it here, and responding adds them to the RFQ's
/// `matchedArtisanIds` so the buyer sees how many makers can take the work.
class ArtisanRfqScreen extends StatelessWidget {
  const ArtisanRfqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final String? uid = context.watch<AuthController>().currentUser?.uid;

    if (uid == null) {
      return Center(child: Text(t.profileNotSignedIn));
    }

    // The artisan's own craft decides which requests are worth showing.
    return StreamBuilder<ArtisanModel?>(
      stream: FirestoreService().streamArtisan(uid),
      builder: (BuildContext context, AsyncSnapshot<ArtisanModel?> profile) {
        if (profile.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final String craft = profile.data?.craft ?? '';

        return StreamBuilder<List<RfqModel>>(
          stream: FirestoreService().streamOpenRfqsForCraft(craft),
          builder: (BuildContext context, AsyncSnapshot<List<RfqModel>> snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _Empty(title: t.artisanRfqLoadFailed, body: '');
            }

            final List<RfqModel> rfqs = snap.data ?? const <RfqModel>[];
            if (rfqs.isEmpty) {
              return _Empty(
                title: t.artisanRfqEmpty,
                body: craft.isEmpty
                    ? t.artisanRfqEmptyNoCraft
                    : t.artisanRfqEmptyBody(craft),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: rfqs.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(t.artisanRfqTitle,
                            style: Theme.of(context).textTheme.headlineMedium),
                        Text(t.artisanRfqSubtitle,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }
                return _RfqCard(rfq: rfqs[i - 1], artisanId: uid);
              },
            );
          },
        );
      },
    );
  }
}

class _RfqCard extends StatefulWidget {
  const _RfqCard({required this.rfq, required this.artisanId});

  final RfqModel rfq;
  final String artisanId;

  @override
  State<_RfqCard> createState() => _RfqCardState();
}

class _RfqCardState extends State<_RfqCard> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final bool alreadyResponded =
        widget.rfq.matchedArtisanIds.contains(widget.artisanId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(color: AppColors.border, width: AppShape.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(widget.rfq.buyerName,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.heritage,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(t.enquiriesQuantity(widget.rfq.quantity),
                    style: Theme.of(context).textTheme.labelMedium),
              ),
            ],
          ),
          Text(widget.rfq.craft, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _Meta(
                label: t.buyerBudget,
                value: '₹${widget.rfq.budgetMin} - ₹${widget.rfq.budgetMax}',
              ),
              _Meta(label: t.buyerDeadline, value: widget.rfq.deadline),
            ],
          ),
          if (widget.rfq.notes != null && widget.rfq.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(widget.rfq.notes!,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 14),
          if (alreadyResponded)
            Row(
              children: <Widget>[
                const Icon(Icons.check_circle_rounded,
                    size: 18, color: AppColors.action),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(t.artisanRfqResponded,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _respond,
                icon: const Icon(Icons.handshake_outlined, size: 18),
                label: Text(t.artisanRfqRespond),
              ),
            ),
          if (widget.rfq.matchedArtisanIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              t.artisanRfqOtherResponses(widget.rfq.matchedArtisanIds.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _respond() async {
    final AppLocalizations t = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    setState(() => _sending = true);
    try {
      await FirestoreService().respondToRfq(
        rfqId: widget.rfq.rfqId,
        artisanId: widget.artisanId,
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(t.artisanRfqSent)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(t.artisanRfqFailed)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.request_quote_outlined,
                  size: 48, color: AppColors.border),
              const SizedBox(height: 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              if (body.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(body,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      );
}
