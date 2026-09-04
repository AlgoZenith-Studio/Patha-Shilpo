import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../ai/voice/controllers/on_device_stt_controller.dart';
import '../../../../ai/voice/models/stt_state.dart';
import '../../../../core/i18n/generated/app_localizations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../models/add_product_state.dart';

/// Step 2 — Vernacular on-device voice description (PRD.md FEAT-02).
///
/// Multi-tiered voice cataloguing:
///   1. On-Device Speech Recognition (Local, offline, privacy-first)
///   2. Continuous dictation with live sound visualizer
///   3. Typed manual description fallback so artisan is never blocked.
class VoiceRecordScreen extends StatefulWidget {
  const VoiceRecordScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen>
    with SingleTickerProviderStateMixin {
  final OnDeviceSttController _stt = OnDeviceSttController();
  final TextEditingController _manual = TextEditingController();
  late AnimationController _waveAnim;

  bool _available = false;
  bool _permissionPermanentlyDenied = false;
  bool _listening = false;
  bool _checked = false;
  String _partial = '';
  double _soundLevel = 0.0;
  String _activeLang = 'en';
  bool _hasSetInitialLang = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasSetInitialLang) {
      final code = Localizations.localeOf(context).languageCode;
      if (code == 'hi' || code == 'bn' || code == 'en') {
        _activeLang = code;
      }
      _hasSetInitialLang = true;
    }
  }

  Future<void> _switchLanguage(String newLang) async {
    if (_activeLang == newLang) return;
    setState(() {
      _activeLang = newLang;
      _partial = '';
    });
    if (_listening) {
      await _stop();
      await _start();
    }
  }

  @override
  void initState() {
    super.initState();
    _waveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _waveAnim.dispose();
    _manual.dispose();
    _stt.stopListening();
    super.dispose();
  }

  Future<void> _init() async {
    final status = await Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      setState(() {
        _available = false;
        _permissionPermanentlyDenied = true;
        _checked = true;
      });
      return;
    }

    final ok = await _stt.initialize();
    if (!mounted) return;
    setState(() {
      _available = ok;
      _checked = true;
      _permissionPermanentlyDenied = !ok && _stt.status == SttStatus.permissionDenied;
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
            const Center(child: CircularProgressIndicator(color: AppColors.action))
          else if (_available)
            _buildVoiceHero(t)
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

  Widget _buildVoiceHero(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _listening ? AppColors.action : AppColors.border.withValues(alpha: 0.8),
          width: _listening ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // On-device pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.offline_bolt_rounded,
                  size: 14,
                  color: _listening ? Colors.green : AppColors.action,
                ),
                const SizedBox(width: 4),
                const Text(
                  'On-Device Speech Recognizer (Offline)',
                  style: TextStyle(
                    fontFamily: 'Pally',
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ---- 3-LANGUAGE SELECTOR PILL: English | हिन्दी | বাংলা ----
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageTab('en', 'English'),
                _buildLanguageTab('hi', 'हिन्दी'),
                _buildLanguageTab('bn', 'বাংলা'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Stabilized mic button (fixed bounding container prevents layout dancing)
          GestureDetector(
            onTap: _listening ? _stop : _start,
            child: AnimatedBuilder(
              animation: _waveAnim,
              builder: (context, child) {
                return SizedBox(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_listening) ...[
                          Container(
                            width: 72 + (6 * _soundLevel),
                            height: 72 + (6 * _soundLevel),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.action.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _listening
                                ? AppColors.action
                                : AppColors.heritage,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_listening
                                        ? AppColors.action
                                        : AppColors.heritage)
                                    .withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _listening ? Icons.mic : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Dedicated Sound Wave Equalizer Voice Bars
          _VoiceEqualizerBars(
            isListening: _listening,
            soundLevel: _soundLevel,
            animValue: _waveAnim.value,
          ),
          const SizedBox(height: 12),

          Text(
            _listening
                ? switch (_activeLang) {
                    'hi' => 'सुन रहे हैं... (हिन्दी में बोलें)',
                    'bn' => 'শুনছি... (বাংলায় বলুন)',
                    _ => 'Listening in English... Speak clearly',
                  }
                : switch (_activeLang) {
                    'hi' => 'बोलने के लिए माइक पर टैप करें (हिन्दी)',
                    'bn' => 'কথা বলতে মাইকে চাপ দিন (বাংলা)',
                    _ => 'Tap microphone to speak (English)',
                  },
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pally',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _listening ? AppColors.action : AppColors.ink,
            ),
          ),

          if (_partial.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _partial,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 14.5,
                  height: 1.45,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tier3Notice(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.heritage.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.mic_off_outlined, color: AppColors.action, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(t.voiceUnavailableTitle,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(t.voiceUnavailableBody,
              style: Theme.of(context).textTheme.bodySmall),
          if (_permissionPermanentlyDenied) ...<Widget>[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: openAppSettings,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(t.voiceOpenSettings),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageTab(String langCode, String label) {
    final bool isSelected = _activeLang == langCode;
    return GestureDetector(
      onTap: () => _switchLanguage(langCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.action : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pally',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Future<void> _start() async {
    setState(() {
      _listening = true;
      _partial = '';
    });

    final String targetLocale = switch (_activeLang) {
      'hi' => 'hi_IN',
      'bn' => 'bn_IN',
      'en' => 'en_IN',
      _ => 'en_IN',
    };

    final success = await _stt.startListening(
      preferredLocale: targetLocale,
      onResult: (SttResult r) {
        if (!mounted) return;
        setState(() {
          _partial = r.text;
          if (r.isFinal) {
            _listening = false;
          }
        });
      },
      onSoundLevelChange: (level) {
        if (!mounted) return;
        final double normalized = ((level + 2.0) / 10.0).clamp(0.0, 1.0);
        setState(() {
          _soundLevel = (_soundLevel * 0.3) + (normalized * 0.7);
        });
      },
    );

    if (!success && mounted) {
      setState(() => _listening = false);
    }
  }

  Future<void> _stop() async {
    await _stt.stopListening();
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

/// Dedicated, smooth voice equalizer waveform bars that react gracefully to speech sound levels.
class _VoiceEqualizerBars extends StatelessWidget {
  final bool isListening;
  final double soundLevel;
  final double animValue;

  const _VoiceEqualizerBars({
    required this.isListening,
    required this.soundLevel,
    required this.animValue,
  });

  @override
  Widget build(BuildContext context) {
    const int barCount = 9;
    const double maxHeight = 28.0;
    const double minHeight = 4.0;

    return SizedBox(
      height: maxHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (index) {
          double height;
          if (!isListening) {
            height = minHeight;
          } else {
            final double normPos =
                (index - (barCount - 1) / 2).abs() / ((barCount - 1) / 2);
            final double centerBias = 1.0 - (normPos * 0.35);
            final double sineWave =
                (math.sin((animValue * 2 * math.pi) + (index * 0.75)) + 1.0) /
                    2.0;
            final double energy =
                (soundLevel * 0.65 + sineWave * 0.35) * centerBias;
            height = (minHeight + (maxHeight - minHeight) * energy)
                .clamp(minHeight, maxHeight);
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: isListening
                    ? [
                        AppColors.action,
                        AppColors.heritage,
                      ]
                    : [
                        AppColors.border,
                        AppColors.border.withValues(alpha: 0.5),
                      ],
              ),
            ),
          );
        }),
      ),
    );
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
          style: const TextStyle(fontFamily: 'Lora', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.action, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
