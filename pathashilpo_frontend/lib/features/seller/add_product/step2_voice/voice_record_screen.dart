import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/i18n/generated/app_localizations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../../../../core/widgets/buttons/voice_mic_button.dart';
import '../models/add_product_state.dart';

/// Step 2 — vernacular voice description (PRD.md FEAT-02).
///
/// Three tiers, degrading downward (TRD.md §7):
///   1. cloud ASR via the backend — not wired here yet
///   2. the device recogniser via `speech_to_text`
///   3. a typed description, which always works
///
/// **The artisan is never blocked.** If tiers 1 and 2 are unavailable — no
/// network, no recogniser, permission refused — tier 3 still produces a usable
/// draft, which is the whole point.
class VoiceRecordScreen extends StatefulWidget {
  const VoiceRecordScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen> {
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _manual = TextEditingController();

  bool _available = false;
  bool _permissionPermanentlyDenied = false;
  bool _listening = false;
  bool _checked = false;
  String _partial = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // speech_to_text.initialize() can only request the runtime permission if
    // RECORD_AUDIO is declared in AndroidManifest.xml. Requesting it
    // explicitly here, rather than relying on the plugin's implicit prompt,
    // gives an honest "permission refused" message instead of a generic
    // "not available" one when that's genuinely why it failed.
    final PermissionStatus micStatus = await Permission.microphone.request();

    if (micStatus.isPermanentlyDenied) {
      if (!mounted) return;
      setState(() {
        _available = false;
        _permissionPermanentlyDenied = true;
        _checked = true;
      });
      return;
    }

    bool ok = false;
    if (micStatus.isGranted) {
      try {
        ok = await _speech.initialize(
          onStatus: (String s) {
            if (!mounted) return;
            if (s == 'done' || s == 'notListening') {
              setState(() => _listening = false);
            }
          },
          onError: (_) {
            if (mounted) setState(() => _listening = false);
          },
        );
      } catch (_) {
        ok = false;
      }
    }

    if (!mounted) return;
    setState(() {
      _available = ok;
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AddProductState draft = context.watch<AddProductState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(t.voiceTitle,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(t.voiceSubtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),

          if (!_checked)
            const Center(child: CircularProgressIndicator())
          else if (_available)
            _tier2(t)
          else
            _tier3Notice(t),

          const SizedBox(height: 20),
          _GuidedForm(
            controller: _manual,
            label: t.voiceTypeInstead,
            hint: t.voiceTypeHint,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 20),
          PrimaryBilingualButton(
            label: t.commonNext,
            onPressed: _hasSomething(draft) ? () => _commit(draft) : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  bool _hasSomething(AddProductState draft) =>
      _manual.text.trim().isNotEmpty ||
      _partial.trim().isNotEmpty ||
      (draft.transcript?.trim().isNotEmpty ?? false);

  Widget _tier2(AppLocalizations t) {
    return Column(
      children: <Widget>[
        Center(
          child: VoiceMicButton(
            isListening: _listening,
            onPressed: _listening ? _stop : _start,
          ),
        ),
        Text(
          _listening ? t.voiceListening : t.voiceTapToSpeak,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (_partial.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppShape.cardRadius),
              border:
                  Border.all(color: AppColors.border, width: AppShape.hairline),
            ),
            child:
                Text(_partial, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ],
    );
  }

  Widget _tier3Notice(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.heritage.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(t.voiceUnavailableTitle,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(t.voiceUnavailableBody,
              style: Theme.of(context).textTheme.bodySmall),
          if (_permissionPermanentlyDenied) ...<Widget>[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: openAppSettings,
              child: Text(t.voiceOpenSettings),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _start() async {
    setState(() {
      _listening = true;
      _partial = '';
    });
    await _speech.listen(
      // Speech locale is independent of UI locale — an artisan may run the
      // interface in English and speak Hindi (TRD.md §10).
      listenOptions: SpeechListenOptions(localeId: 'hi_IN'),
      onResult: (SpeechRecognitionResult r) {
        if (!mounted) return;
        setState(() => _partial = r.recognizedWords);
      },
    );
  }

  Future<void> _stop() async {
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  void _commit(AddProductState draft) {
    final String spoken = _partial.trim();
    final String typed = _manual.text.trim();
    final String combined =
        <String>[spoken, typed].where((String s) => s.isNotEmpty).join('. ');

    draft.setSpeech(
      transcript: combined,
      tier: spoken.isNotEmpty ? 2 : 3,
    );
    widget.onNext();
  }
}

/// Tier 3 — the typed description that always works.
class _GuidedForm extends StatelessWidget {
  const _GuidedForm({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 4,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
