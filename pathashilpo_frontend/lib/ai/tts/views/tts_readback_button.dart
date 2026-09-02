import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../controllers/tts_router.dart';
import '../models/tts_input.dart';

/// "Listen" control for any block of text (PRD.md §6 step 4).
///
/// Built for an artisan with limited literacy: a single tap, a clear label in
/// the selected language, and a 56px tap target to match the rest of the app.
/// It owns its own [TtsRouter] so a caller only has to supply the text.
class TtsReadbackButton extends StatefulWidget {
  const TtsReadbackButton({super.key, required this.text, this.router});

  final String text;

  /// Injectable for tests.
  final TtsRouter? router;

  @override
  State<TtsReadbackButton> createState() => _TtsReadbackButtonState();
}

class _TtsReadbackButtonState extends State<TtsReadbackButton> {
  late final TtsRouter _router = widget.router ?? TtsRouter();
  bool _busy = false;
  bool _speaking = false;

  @override
  void dispose() {
    // Stop before disposing: audio would otherwise keep playing after the
    // artisan has left the screen.
    _router.stop();
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_speaking) {
      await _router.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }

    setState(() => _busy = true);

    final TtsResult result = await _router.speak(
      TtsInput(
        text: widget.text,
        languageCode: Localizations.localeOf(context).languageCode,
      ),
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      _speaking = result.spoken;
    });

    if (!result.spoken) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).ttsUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return SizedBox(
      height: 56,
      child: TextButton.icon(
        onPressed: _busy ? null : _toggle,
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _speaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                color: AppColors.ink,
              ),
        label: Text(
          _speaking ? t.ttsStop : t.ttsListen,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
