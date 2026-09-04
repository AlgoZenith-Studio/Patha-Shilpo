import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../controllers/on_device_stt_controller.dart';
import '../models/stt_state.dart';

/// Shows the luxury On-Device Speech-to-Text modal bottom sheet.
///
/// Fully supports all three official Patha-Shilpo languages:
/// 1. English (`en`)
/// 2. Hindi (`hi` - हिन्दी)
/// 3. Bengali (`bn` - বাংলা)
///
/// Returns the transcribed text string if accepted, or null if cancelled.
Future<String?> showOnDeviceVoiceModal(
  BuildContext context, {
  String? title,
  String? hint,
  String? preferredLocaleCode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _OnDeviceVoiceModalContent(
      title: title,
      hint: hint,
      preferredLocaleCode: preferredLocaleCode,
    ),
  );
}

class _OnDeviceVoiceModalContent extends StatefulWidget {
  final String? title;
  final String? hint;
  final String? preferredLocaleCode;

  const _OnDeviceVoiceModalContent({
    this.title,
    this.hint,
    this.preferredLocaleCode,
  });

  @override
  State<_OnDeviceVoiceModalContent> createState() =>
      _OnDeviceVoiceModalContentState();
}

class _OnDeviceVoiceModalContentState extends State<_OnDeviceVoiceModalContent>
    with SingleTickerProviderStateMixin {
  final OnDeviceSttController _controller = OnDeviceSttController();
  late AnimationController _pulseController;

  late String _activeLang;
  String _transcribedText = '';
  bool _isListening = false;
  double _soundLevel = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _activeLang = widget.preferredLocaleCode ?? 'en';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _startListening();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.preferredLocaleCode == null) {
      final code = Localizations.localeOf(context).languageCode;
      if (code == 'hi' || code == 'bn' || code == 'en') {
        _activeLang = code;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.stopListening();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _transcribedText = '';
      _error = null;
      _isListening = true;
    });

    final success = await _controller.startListening(
      preferredLocale: _activeLang,
      onResult: (SttResult res) {
        if (!mounted) return;
        setState(() {
          _transcribedText = res.text;
          if (res.isFinal) {
            _isListening = false;
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
      setState(() {
        _isListening = false;
        _error = _controller.errorMessage ?? _getGenericMicError();
      });
    }
  }

  String _getGenericMicError() {
    return switch (_activeLang) {
      'hi' => 'माइक्रोफ़ोन प्रारंभ नहीं हो सका।',
      'bn' => 'মাইক্রোফোন চালু করা যায়নি।',
      _ => 'Could not start microphone.',
    };
  }

  Future<void> _switchLanguage(String newLang) async {
    if (_activeLang == newLang) return;
    setState(() {
      _activeLang = newLang;
      _transcribedText = '';
      _error = null;
    });
    if (_isListening) {
      await _controller.stopListening();
    }
    await _startListening();
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _controller.stopListening();
      if (mounted) setState(() => _isListening = false);
    } else {
      await _startListening();
    }
  }

  void _submit() {
    _controller.stopListening();
    Navigator.of(context).pop(_transcribedText.trim());
  }

  @override
  Widget build(BuildContext context) {
    // 3-Language Localized Copy
    final defaultTitle = widget.title ??
        switch (_activeLang) {
          'hi' => 'बोलकर खोजें / दर्ज करें',
          'bn' => 'মুখে বলে খুঁজুন / লিখুন',
          _ => 'Speak to Search / Dictate',
        };

    final defaultHint = widget.hint ??
        switch (_activeLang) {
          'hi' => 'अपने शिल्प, उत्पाद या कारीगर का नाम बोलें...',
          'bn' => 'আপনার শিল্প, পণ্য বা কারিগরের নাম বলুন...',
          _ => 'Say craft name, artisan, or product details...',
        };

    final statusText = _isListening
        ? switch (_activeLang) {
            'hi' => 'सुन रहे हैं... कृपया स्पष्ट बोलें',
            'bn' => 'শুনছি... অনুগ্রহ করে স্পষ্ট করে বলুন',
            _ => 'Listening... Speak clearly',
          }
        : switch (_activeLang) {
            'hi' => 'बोलने के लिए माइक पर टैप करें',
            'bn' => 'কথা বলতে মাইকে চাপ দিন',
            _ => 'Tap microphone to speak',
          };

    final badgeText = (_controller.isOffline || _controller.isFallbackActive)
        ? switch (_activeLang) {
            'hi' => 'ऑफ़लाइन फ़ॉलबैक सक्रिय',
            'bn' => 'অফলাইন ফলব্যাক সক্রিয়',
            _ => 'Offline Fallback Active',
          }
        : switch (_activeLang) {
            'hi' => 'ऑनलाइन · फ़ॉलबैक तैयार',
            'bn' => 'অনলাইন · ফলব্যাক প্রস্তুত',
            _ => 'Cloud Online · Fallback Ready',
          };

    final submitText = switch (_activeLang) {
      'hi' => 'इस लेख का उपयोग करें',
      'bn' => 'এই লেখাটি ব্যবহার করুন',
      _ => 'Use Transcribed Text',
    };

    final cancelText = switch (_activeLang) {
      'hi' => 'रद्द करें',
      'bn' => 'বাতিল করুন',
      _ => 'Cancel',
    };

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShape.sheetRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row with Fallback Status Badge and Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (_controller.isOffline || _controller.isFallbackActive)
                      ? Colors.amber.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (_controller.isOffline || _controller.isFallbackActive)
                            ? Colors.amber.shade300
                            : Colors.green.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      (_controller.isOffline || _controller.isFallbackActive)
                          ? Icons.wifi_off_rounded
                          : Icons.cloud_done_rounded,
                      size: 14,
                      color:
                          (_controller.isOffline || _controller.isFallbackActive)
                              ? Colors.amber.shade800
                              : Colors.green.shade700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: (_controller.isOffline ||
                                _controller.isFallbackActive)
                            ? Colors.amber.shade900
                            : Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.close_rounded, color: AppColors.textMuted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ---- 3-LANGUAGE SELECTOR PILL: ENGLISH | हिन्दी | বাংলা ----
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
          const SizedBox(height: 14),

          // Title
          Text(
            defaultTitle,
            style: const TextStyle(
              fontFamily: 'Lora',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Subtitle Status
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Pally',
              fontSize: 12.5,
              color: _isListening ? AppColors.action : AppColors.textMuted,
              fontWeight: _isListening ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),

          // Stabilized Voice Visualizer with Voice Waveform Equalizer Bars
          GestureDetector(
            onTap: _toggleListen,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return SizedBox(
                  height: 124,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Fixed-dimension Microphone Button (never resizes dialog)
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Subtle aura ring that NEVER expands outside bounds
                              if (_isListening)
                                Container(
                                  width: 68 + (8 * _soundLevel),
                                  height: 68 + (8 * _soundLevel),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.action
                                        .withValues(alpha: 0.22),
                                  ),
                                ),
                              // Core Mic Button
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: _isListening
                                      ? AppColors.action
                                      : AppColors.heritage,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isListening
                                              ? AppColors.action
                                              : AppColors.heritage)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening
                                      ? Icons.mic_rounded
                                      : Icons.mic_none_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dedicated Sound Wave Equalizer Voice Bars
                      _VoiceEqualizerBars(
                        isListening: _isListening,
                        soundLevel: _soundLevel,
                        animValue: _pulseController.value,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Transcribed Text Bubble Container
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isListening
                    ? AppColors.action.withValues(alpha: 0.6)
                    : AppColors.border,
                width: 1.2,
              ),
            ),
            child: SingleChildScrollView(
              child: Text(
                _transcribedText.isNotEmpty
                    ? _transcribedText
                    : (_error ?? defaultHint),
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 15,
                  height: 1.45,
                  fontStyle: _transcribedText.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: _error != null
                      ? Colors.redAccent
                      : (_transcribedText.isNotEmpty
                          ? AppColors.ink
                          : AppColors.textMuted),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Bottom Action Controls
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _controller.cancelListening();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed:
                      _transcribedText.trim().isNotEmpty ? _submit : null,
                  icon:
                      const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(
                    submitText,
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.action,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.border.withValues(alpha: 0.6),
                    disabledForegroundColor: AppColors.textMuted,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    const double maxHeight = 30.0;
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
            // Harmonic wave offset across bars for a fluid, natural waveform
            final double normPos =
                (index - (barCount - 1) / 2).abs() / ((barCount - 1) / 2);
            final double centerBias = 1.0 - (normPos * 0.35); // Center bars are taller
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
