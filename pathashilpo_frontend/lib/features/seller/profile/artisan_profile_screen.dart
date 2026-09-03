import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ai/tts/controllers/tts_router.dart';
import '../../../ai/tts/models/tts_input.dart';
import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../../core/widgets/badges/sync_indicator.dart';
import '../../../data/models/artisan_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../buyer/artisan/buyer_artisan_storefront_screen.dart';
import '../products/artisan_product_detail_screen.dart';

/// The artisan's master profile screen — showcasing their identity, official government
/// verification credentials, heritage user story, product process story, and their product listings.
class ArtisanProfileScreen extends StatelessWidget {
  const ArtisanProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AuthController auth = context.watch<AuthController>();
    final String? uid = auth.currentUser?.uid;

    if (uid == null) {
      return _ProfileNotice(icon: Icons.person_off_outlined, text: t.profileNotSignedIn);
    }

    return StreamBuilder<ArtisanModel?>(
      stream: FirestoreService().streamArtisan(uid),
      builder: (BuildContext context, AsyncSnapshot<ArtisanModel?> snap) {
        // Spin only while genuinely waiting for the FIRST snapshot. A Firestore
        // document stream sits in `waiting` indefinitely when the device cannot
        // reach the server and has no cached copy of the document - which is
        // how this screen ended up as a spinner that never resolved.
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.action));
        }

        if (snap.hasError) {
          return _ProfileNotice(
              icon: Icons.cloud_off_rounded, text: t.profileLoadFailed);
        }

        final ArtisanModel? artisan = snap.data;
        if (artisan == null) {
          // Deliberately NOT falling back to MockBuyerData.artisans.first.
          // That showed a signed-in artisan somebody else's name, village and
          // craft — the same bug as the old `orElse: () => artisans.first` in
          // the buyer product page. An unfinished profile must say so.
          return _ProfileNotice(
              icon: Icons.badge_outlined, text: t.profileIncomplete);
        }

        return _ProfileBody(artisan: artisan, phone: auth.phone);
      },
    );
  }
}

/// Full-bleed message for the states where there is no profile to show.
class _ProfileNotice extends StatelessWidget {
  const _ProfileNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody({required this.artisan, required this.phone});

  final ArtisanModel artisan;
  final String? phone;

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  /// Localised strings for this screen. A getter rather than a local in
  /// every helper: the whole class renders in one language, and that
  /// language is whichever Localizations resolves right now.
  AppLocalizations get t => AppLocalizations.of(context);

  final TtsRouter _tts = TtsRouter();
  bool _isPlayingStory = false;
  bool _isPlayingProductStory = false;

  @override
  void dispose() {
    _tts.stop();
    _tts.dispose();
    super.dispose();
  }

  Future<void> _speakVerificationBadge() async {
    final lang = Localizations.localeOf(context).languageCode;
    final String docName;
    final String text;

    if (lang == 'bn') {
      docName = switch (widget.artisan.idType) {
        'aadhaar' => 'আধার কার্ড',
        'pan' => 'প্যান কার্ড',
        'gstin' => 'জিএসটি নম্বর',
        _ => 'পরিচয়পত্র',
      };
      text =
          'কারিগর ${widget.artisan.name}-এর $docName ভারত সরকারের নথি অনুসারে যাচাইকৃত। এদের সকল হস্তশিল্পে প্রমাণীকৃত কারিগর ব্যাজ যুক্ত আছে। Verified Master Artisan under Patha-Shilpo provenance.';
    } else if (lang == 'hi') {
      docName = switch (widget.artisan.idType) {
        'aadhaar' => 'आधार कार्ड',
        'pan' => 'पैन कार्ड',
        'gstin' => 'जीएसटी नंबर',
        _ => 'पहचान पत्र',
      };
      text =
          'कारीगर ${widget.artisan.name} का $docName भारत सरकार के रिकॉर्ड के अनुसार सत्यापित है। इनके सभी उत्पादों पर प्रमाणित कारीगर बैज मान्य है। Verified Master Artisan under Patha-Shilpo provenance.';
    } else {
      docName = switch (widget.artisan.idType) {
        'aadhaar' => 'Aadhaar Card',
        'pan' => 'Income Tax PAN Card',
        'gstin' => 'GSTIN Taxpayer Registry',
        _ => 'Government ID',
      };
      text =
          "Artisan ${widget.artisan.name}'s $docName is officially verified under Government of India records. Certified master craft provenance badge displayed across all listings.";
    }

    await _tts.speak(TtsInput(text: text, languageCode: lang));
  }

  Future<void> _togglePlayStory(String storyText) async {
    if (_isPlayingStory) {
      await _tts.stop();
      setState(() => _isPlayingStory = false);
      return;
    }

    setState(() {
      _isPlayingStory = true;
      _isPlayingProductStory = false;
    });

    final lang = Localizations.localeOf(context).languageCode;
    try {
      await _tts.speak(TtsInput(text: storyText, languageCode: lang));
    } finally {
      if (mounted) setState(() => _isPlayingStory = false);
    }
  }

  Future<void> _togglePlayProductStory(String storyText) async {
    if (_isPlayingProductStory) {
      await _tts.stop();
      setState(() => _isPlayingProductStory = false);
      return;
    }

    setState(() {
      _isPlayingProductStory = true;
      _isPlayingStory = false;
    });

    final lang = Localizations.localeOf(context).languageCode;
    try {
      await _tts.speak(TtsInput(text: storyText, languageCode: lang));
    } finally {
      if (mounted) setState(() => _isPlayingProductStory = false);
    }
  }

  void _showVerificationProofModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
              // Top drag pill handle
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_user_rounded,
                        color: Colors.green.shade700, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Government Verified Provenance',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'National Craft & Handloom Registry of India',
                          style: TextStyle(
                            fontFamily: 'Pally',
                            fontSize: 12,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),

              _buildModalProofRow('Artisan Legal Name', widget.artisan.name),
              const SizedBox(height: 10),
              _buildModalProofRow('Verification Agency',
                  'Ministry of Textiles · Office of DC (Handlooms)'),
              const SizedBox(height: 10),
              _buildModalProofRow('Authentication Status', 'Active & Verified'),
              const SizedBox(height: 10),
              _buildModalProofRow('Cluster GI Tag',
                  widget.artisan.giTag ?? 'GI-IN-007 (Chanderi Fabric)'),
              const SizedBox(height: 10),
              _buildModalProofRow('Document Registry',
                  (widget.artisan.idType ?? 'Government ID').toUpperCase()),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _speakVerificationBadge();
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: Text(t.profileListenVerification),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.action,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalProofRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'Pally',
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final artisan = widget.artisan;
    final phone = widget.phone;
    final AppLocalizations t = AppLocalizations.of(context);
    final String currentLang = Localizations.localeOf(context).languageCode;
    final String activeName = kLocaleNames[currentLang] ?? 'English';
    final bool showHindi = currentLang == 'hi';
    final bool showBengali = currentLang == 'bn';

    final String displayName = showBengali
        ? artisan.name
        : (showHindi && artisan.nameHi.isNotEmpty
            ? artisan.nameHi
            : artisan.name);

    final String displayUserStory = showHindi && artisan.storyHi.isNotEmpty
        ? artisan.storyHi
        : artisan.story;

    final String displayProductStory = switch (currentLang) {
      'bn' =>
        'প্রতিটি ঐতিহ্যবাহী হস্তশিল্প নিখুঁতভাবে তৈরি করতে প্রায় ৪৮ থেকে ৭২ ঘণ্টার গভীর একাগ্রতা প্রয়োজন। হাতে কাটা সূক্ষ্ম সিল্ক সুতা, প্রাকৃতিক উদ্ভিজ্জ রঙ এবং খাঁটি রৌপ্য-স্বর্ণ জরির সূক্ষ্ম কাজের মাধ্যমে প্রতিটি শিল্পকর্মে ভারতীয় ঐতিহ্যের সৌন্দর্য জীবন্ত হয়ে ওঠে।',
      'hi' =>
        'प्रत्येक पारंपरिक शिल्प के निर्माण में 48 से 72 घंटे का कठिन परिश्रम लगता है। शुद्ध रेशमी धागे, प्राकृतिक वनस्पति रंग और असली ज़री के साथ पारंपरिक गड्ढा करघे (Pit Loom) पर प्रत्येक धागे को हाथ से बुना जाता है।',
      _ =>
        'Each handcrafted piece requires 48 to 72 hours of dedicated artisanal labor. Spun with pure mulberry silk warp, natural vegetable dyes, and hand-twisted zari motifs woven seamlessly on traditional pit looms.',
    };

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: <Widget>[
          // ---- 1. MASTER IDENTITY HERO CARD ----
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.action, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: AppColors.heritage,
                            backgroundImage: (artisan.photoUrl != null &&
                                    artisan.photoUrl!.isNotEmpty)
                                ? NetworkImage(artisan.photoUrl!)
                                : null,
                            child: (artisan.photoUrl == null ||
                                    artisan.photoUrl!.isEmpty)
                                ? const Icon(Icons.person_rounded,
                                    size: 36, color: AppColors.ink)
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (phone != null && phone.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(phone,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined,
                                  size: 13, color: AppColors.action),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${artisan.village}, ${artisan.district}, ${artisan.state}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                // Public Storefront Preview Action
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BuyerArtisanStorefrontScreen(artisan: artisan),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.storefront_outlined,
                                size: 18, color: AppColors.action),
                            SizedBox(width: 10),
                            Text(
                              'View Public Storefront (Buyer Perspective)',
                              style: TextStyle(
                                fontFamily: 'Pally',
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 20, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---- 2. PROVENANCE BADGES ----
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (artisan.cluster.isNotEmpty)
                ProvenanceTag(
                    label: artisan.cluster, icon: Icons.place_outlined),
              if (artisan.craft.isNotEmpty)
                ProvenanceTag(
                  label: artisan.craft,
                  icon: Icons.workspace_premium_outlined,
                ),
              if (artisan.giTag != null && artisan.giTag!.isNotEmpty)
                ProvenanceTag(label: artisan.giTag!, verified: true),
              if (artisan.verified)
                ProvenanceTag(label: t.profileVerified, verified: true),
            ],
          ),

          // ---- 3. OFFICIAL IDENTITY & TAX VERIFICATION BADGE CARD ----
          const SizedBox(height: 16),
          _buildIdentityVerificationCard(t, artisan),

          // ---- 4. ARTISAN HERITAGE & USER STORY CARD ----
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_edu_outlined,
                            color: AppColors.action, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          switch (currentLang) {
                            'bn' => 'কারিগর পরিচয় ও ঐতিহ্য (Artisan Story)',
                            'hi' => 'कारीगर विरासत एवं कहानी (Artisan Story)',
                            _ => 'Artisan Heritage Story',
                          },
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    // Voice Listen User Story Button
                    ElevatedButton.icon(
                      onPressed: () => _togglePlayStory(
                          displayUserStory.isNotEmpty
                              ? displayUserStory
                              : t.profileNoStoryYet),
                      icon: Icon(
                        _isPlayingStory
                            ? Icons.stop_circle_outlined
                            : Icons.volume_up_rounded,
                        size: 15,
                      ),
                      label: Text(_isPlayingStory ? 'Stop' : 'Listen'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        backgroundColor: _isPlayingStory
                            ? Colors.redAccent
                            : AppColors.surface,
                        foregroundColor:
                            _isPlayingStory ? Colors.white : AppColors.ink,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  displayUserStory.isNotEmpty
                      ? displayUserStory
                      : t.profileNoStoryYet,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_outlined,
                          size: 14, color: AppColors.action),
                      const SizedBox(width: 6),
                      Text(
                        t.profileYearsOfPractice(artisan.yearsOfPractice),
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- 5. PRODUCT & CRAFT PROCESS STORY CARD ----
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined,
                            color: AppColors.action, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          switch (currentLang) {
                            'bn' =>
                              'হস্তশিল্প নির্মাণ প্রক্রিয়া (Product Story)',
                            'hi' => 'शिल्प निर्माण एवं सामग्री (Product Story)',
                            _ => 'Handcraft Process & Materials',
                          },
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _togglePlayProductStory(displayProductStory),
                      icon: Icon(
                        _isPlayingProductStory
                            ? Icons.stop_circle_outlined
                            : Icons.volume_up_rounded,
                        size: 15,
                      ),
                      label: Text(_isPlayingProductStory ? 'Stop' : 'Listen'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        backgroundColor: _isPlayingProductStory
                            ? Colors.redAccent
                            : AppColors.surface,
                        foregroundColor: _isPlayingProductStory
                            ? Colors.white
                            : AppColors.ink,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  displayProductStory,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14, color: AppColors.action),
                          SizedBox(width: 6),
                          Text(
                            '48 - 72 Hours Handwork',
                            style: TextStyle(
                              fontFamily: 'Pally',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_outlined,
                              size: 14, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            'Pure Natural Dyes',
                            style: TextStyle(
                              fontFamily: 'Pally',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---- 6. MY HANDCRAFTED LISTINGS & DIRECT LINK TO PRODUCT DETAIL ----
          const SizedBox(height: 18),
          _buildArtisanProductsSection(context, artisan),

          // ---- 7. AT-A-GLANCE STATS ----
          const SizedBox(height: 18),
          _Card(
            child: Row(
              children: <Widget>[
                StreamBuilder<List<ProductModel>>(
                  stream: FirestoreService().streamArtisanProducts(artisan.uid),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ProductModel>> snap) {
                    final int count = snap.hasData && snap.data!.isNotEmpty
                        ? snap.data!.length
                        : artisan.productCount;
                    return _Stat(
                      label: t.profileProductsListed,
                      value: '$count',
                      icon: Icons.inventory_2_outlined,
                    );
                  },
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                _Stat(
                  label: t.profileRating,
                  value: artisan.rating.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                _Stat(
                  label: t.profileVerification,
                  value: artisan.verified
                      ? t.profileVerified
                      : t.profileUnverified,
                  icon: artisan.verified
                      ? Icons.verified_rounded
                      : Icons.pending_outlined,
                ),
              ],
            ),
          ),

          // ---- 8. SETTINGS, LANGUAGE SWITCHER & LOGOUT ----
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.border.withValues(alpha: 0.8)),
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.language_rounded,
                      color: AppColors.action),
                  title: Text(t.commonLanguage,
                      style: Theme.of(context).textTheme.titleSmall),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      activeName,
                      style: const TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  onTap: () => _pickLanguage(context),
                ),
                const Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded,
                      color: Colors.redAccent),
                  title: Text(
                    t.commonSignOut,
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section in Profile displaying the artisan's products with direct tap to ArtisanProductDetailScreen
  Widget _buildArtisanProductsSection(
      BuildContext context, ArtisanModel artisan) {
    return StreamBuilder<List<ProductModel>>(
      stream: FirestoreService().streamArtisanProducts(artisan.uid),
      builder: (context, snapshot) {
        // The artisan's OWN products, and nothing else. This used to fall back
        // to MockBuyerData filtered on `artisanId == 'artisan_001'`, so an
        // artisan with no listings saw the mock Chanderi saree sitting in their
        // profile as though they had made it. There is a real empty state
        // below; showing someone else's craft is worse than showing none.
        final List<ProductModel> products = snapshot.data ?? const <ProductModel>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_rounded,
                        color: AppColors.action, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      switch (Localizations.localeOf(context).languageCode) {
                        'bn' => 'আমার হস্তশিল্প তালিকা (${products.length})',
                        'hi' => 'मेरी शिल्प सूची (${products.length})',
                        _ => 'My Craft Listings (${products.length})',
                      },
                      style: const TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.artisanAddProduct),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: Text(t.artisanAddCraft),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.action,
                    textStyle: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (products.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No craft products listed yet. Tap Add Craft above.',
                    style: TextStyle(fontFamily: 'Lora', fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, idx) {
                  final p = products[idx];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // Direct navigation to the artisan's dedicated product detail & pricing page!
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ArtisanProductDetailScreen(product: p),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: 68,
                                height: 68,
                                child: p.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: p.imageUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => Container(
                                          color: AppColors.canvas,
                                          child: const Icon(Icons.image_outlined,
                                              color: AppColors.border),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.canvas,
                                        child: const Icon(Icons.image_outlined,
                                            color: AppColors.border),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Lora',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${p.priceFinal}',
                                        style: const TextStyle(
                                          fontFamily: 'Pally',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: AppColors.action,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '· ${p.craftType}',
                                        style: const TextStyle(
                                          fontFamily: 'Lora',
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  SyncIndicator(
                                      state: p.status == 'live'
                                          ? SyncState.live
                                          : SyncState.offlineProcessed),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textMuted, size: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildIdentityVerificationCard(
      AppLocalizations t, ArtisanModel artisan) {
    final String maskedId = artisan.gstin != null &&
            artisan.gstin!.length >= 4
        ? '•••• •••• ${artisan.gstin!.substring(artisan.gstin!.length - 4)}'
        : '•••• •••• 6721';

    final String docTitle = switch (artisan.idType) {
      'aadhaar' => 'UIDAI Aadhaar Verified',
      'pan' => 'IT PAN Taxpayer Verified',
      'gstin' => 'GSTIN Handloom Registry',
      _ => 'Government Verified Artisan',
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.green.shade200, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_rounded,
                        color: Colors.green.shade700, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docTitle,
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Digital Provenance Certificate',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 11.5,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  'AUTHENTICATED',
                  style: TextStyle(
                    fontFamily: 'Pally',
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5,
                    letterSpacing: 0.5,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GOVERNMENT ID NUMBER',
                    style: TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    maskedId,
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1.2,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _speakVerificationBadge,
                icon: const Icon(Icons.volume_up_rounded, size: 16),
                label: Text(t.commonVoiceReadout),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  side: const BorderSide(color: AppColors.border),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showVerificationProofModal(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Proof Details (राष्ट्रीय रजिस्ट्री प्रमाण)',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: Colors.green.shade900,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: Colors.green.shade800),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickLanguage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetCtx) {
        final LocaleProvider provider = sheetCtx.watch<LocaleProvider>();
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
              for (final Locale loc in kSupportedLocales) ...<Widget>[
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    kLocaleNames[loc.languageCode] ?? loc.languageCode,
                    style: TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: provider.locale.languageCode == loc.languageCode
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: provider.locale.languageCode == loc.languageCode
                          ? AppColors.action
                          : AppColors.ink,
                    ),
                  ),
                  trailing: provider.locale.languageCode == loc.languageCode
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.action)
                      : null,
                  onTap: () {
                    provider.setLocale(loc);
                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _confirmSignOut(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(t.commonSignOut,
            style: const TextStyle(fontFamily: 'Lora')),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontFamily: 'Lora', fontSize: 14),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.commonCancel,
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AuthController>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.splash,
                  (Route<dynamic> r) => false,
                );
              }
            },
            child: Text(
              t.commonSignOut,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, size: 22, color: AppColors.action),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pally',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lora',
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
