import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';

import '../../../core/theme/colors.dart';
import '../controllers/on_device_stt_controller.dart';
import '../models/stt_state.dart';

/// Reusable inline on-device voice recorder widget with real-time waveform and transcript.
class VoiceRecorderWidget extends StatefulWidget {
  final ValueChanged<String> onTranscriptChanged;
  final ValueChanged<String>? onFinalTranscript;
  final String? preferredLocaleCode;

  const VoiceRecorderWidget({
    super.key,
    required this.onTranscriptChanged,
    this.onFinalTranscript,
    this.preferredLocaleCode,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

/// Fixed footprint for the mic control, so the pulse can never move the sheet.
const double _micSlot = 68;

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  /// Localised strings for this screen. A getter rather than a local in
  /// every helper: the whole class renders in one language, and that
  /// language is whichever Localizations resolves right now.
  AppLocalizations get t => AppLocalizations.of(context);

  final OnDeviceSttController _stt = OnDeviceSttController();
  late AnimationController _anim;
  String _currentText = '';
  bool _isRecording = false;

  /// Amplitude drives only the mic glyph's paint. It used to be plain state
  /// updated with setState on every audio frame, which rebuilt this entire
  /// card - text, borders and all - many times a second. A ValueNotifier keeps
  /// those repaints inside one small AnimatedBuilder.
  final ValueNotifier<double> _level = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _level.dispose();
    _anim.dispose();
    _stt.stopListening();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      await _stt.stopListening();
      if (mounted) setState(() => _isRecording = false);
      if (_currentText.isNotEmpty) {
        widget.onFinalTranscript?.call(_currentText);
      }
    } else {
      setState(() {
        _isRecording = true;
        _currentText = '';
      });

      final success = await _stt.startListening(
        preferredLocale: widget.preferredLocaleCode,
        onResult: (SttResult res) {
          if (!mounted) return;
          setState(() {
            _currentText = res.text;
            if (res.isFinal) {
              _isRecording = false;
              widget.onFinalTranscript?.call(res.text);
            }
          });
          widget.onTranscriptChanged(res.text);
        },
        onSoundLevelChange: (level) {
          if (!mounted) return;
          // No setState: only the mic listens to this.
          _level.value = level.clamp(0.0, 1.0);
        },
      );

      if (!success && mounted) {
        setState(() => _isRecording = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isRecording ? AppColors.action : AppColors.border,
          // Constant width: a Border insets its child, so toggling this
          // nudged every child on record start/stop.
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Fixed slot. Transform.scale paints outside its bounds without
              // resizing anything, but the pulse still needs a stable box so
              // the row's height can never follow the animation - that, plus
              // the unclamped level below, is what made the sheet judder.
              SizedBox(
                width: _micSlot,
                height: _micSlot,
                child: GestureDetector(
                  onTap: _toggleRecord,
                  child: Center(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        // Listens to BOTH the idle pulse and the live level, so
                        // only this subtree repaints per audio frame.
                        animation:
                            Listenable.merge(<Listenable>[_anim, _level]),
                        builder: (BuildContext context, Widget? child) {
                          // Capped hard. The level is 0..1 and the breathing
                          // pulse adds at most 0.04, so the glyph moves within
                          // a few percent and always stays inside _micSlot.
                          final double scale = _isRecording
                              ? 1.0 +
                                  (_level.value.clamp(0.0, 1.0) * 0.08) +
                                  (_anim.value * 0.04)
                              : 1.0;
                          return Transform.scale(scale: scale, child: child);
                        },
                        // Built once: nothing inside depends on the animation.
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? AppColors.action
                                : AppColors.canvas,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            _isRecording ? Icons.mic : Icons.mic_none_rounded,
                            color:
                                _isRecording ? Colors.white : AppColors.action,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRecording
                          ? t.voiceListening
                          : t.voiceTapMic,
                      style: TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: _isRecording ? AppColors.action : AppColors.ink,
                      ),
                    ),
                    // Two lines' worth of space is reserved whether or not
                    // there is text yet, so a partial transcript arriving does
                    // not grow the card and shunt the whole sheet upward.
                    SizedBox(
                      height: 34,
                      child: Text(
                        _currentText.isNotEmpty
                            ? _currentText
                            : t.voiceSpeakClearly,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 12.5,
                          fontStyle: _currentText.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: _currentText.isNotEmpty
                              ? AppColors.ink
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_currentText.isNotEmpty && !_isRecording)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    setState(() => _currentText = '');
                    widget.onTranscriptChanged('');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
