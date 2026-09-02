import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/enquiry_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

/// Enquiries received on the artisan's own products (PRD.md FEAT-04).
///
/// Live from Firestore. This screen previously showed two invented enquiries
/// ("Meera Textiles", "Craft Export Co.") under a "sample data" caption, so a
/// real buyer's message had nowhere to appear even though the buyer shell was
/// writing them.
class ArtisanEnquiriesScreen extends StatefulWidget {
  const ArtisanEnquiriesScreen({super.key});

  @override
  State<ArtisanEnquiriesScreen> createState() => _ArtisanEnquiriesScreenState();
}

class _ArtisanEnquiriesScreenState extends State<ArtisanEnquiriesScreen> {
  late final Stream<List<EnquiryModel>> _enquiries =
      FirestoreService().streamArtisanEnquiries(
    context.read<AuthController>().currentUser?.uid ?? '__none__',
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return StreamBuilder<List<EnquiryModel>>(
      stream: _enquiries,
      builder:
          (BuildContext context, AsyncSnapshot<List<EnquiryModel>> snapshot) {
        final List<EnquiryModel> enquiries =
            snapshot.data ?? const <EnquiryModel>[];

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: <Widget>[
            Text(t.enquiriesTitle,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError)
              _Notice(title: t.enquiriesLoadFailed, body: '')
            else if (enquiries.isEmpty)
              _Notice(title: t.enquiriesEmpty, body: t.enquiriesEmptyBody)
            else
              for (final EnquiryModel e in enquiries) ...<Widget>[
                _EnquiryCard(enquiry: e),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(color: AppColors.border, width: AppShape.hairline),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.mark_chat_read_outlined,
              size: 44, color: AppColors.border),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          if (body.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  const _EnquiryCard({required this.enquiry});

  final EnquiryModel enquiry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

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
          Text(enquiry.productTitle,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            t.enquiryFrom(enquiry.buyerName),
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(enquiry.message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t.enquiryQuantity(enquiry.quantity),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Spacer(),
              // The buyer's number is the point of the whole feature: the
              // artisan calls them directly, with no intermediary.
              Text(enquiry.buyerPhone,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.action,
                        fontWeight: FontWeight.w700,
                      )),
            ],
          ),
        ],
      ),
    );
  }
}
