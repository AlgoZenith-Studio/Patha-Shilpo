import 'package:flutter/material.dart';

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

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  final OnDeviceSttController _stt = OnDeviceSttController();
  late AnimationController _anim;
  String _currentText = '';
  bool _isRecording = false;
  double _soundLevel = 0.0;

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
          setState(() => _soundLevel = level);
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
          width: _isRecording ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _toggleRecord,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) {
                    final scale = _isRecording
                        ? 1.0 + (_soundLevel * 0.3) + (_anim.value * 0.1)
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _isRecording ? AppColors.action : AppColors.canvas,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none_rounded,
                          color: _isRecording ? Colors.white : AppColors.action,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRecording ? 'Listening (On-Device)...' : 'Tap mic to dictate story',
                      style: TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: _isRecording ? AppColors.action : AppColors.ink,
                      ),
                    ),
                    Text(
                      _currentText.isNotEmpty ? _currentText : 'Speak clearly in your dialect...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 12.5,
                        fontStyle: _currentText.isEmpty ? FontStyle.italic : FontStyle.normal,
                        color: _currentText.isNotEmpty ? AppColors.ink : AppColors.textMuted,
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
