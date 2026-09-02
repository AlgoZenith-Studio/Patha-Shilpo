import '../models/tts_input.dart';
import 'tts_offline_flutter.dart';
import 'tts_online_bhashini.dart';

/// Speech-synthesis router (TRD.md AD-5, §8.5).
///
/// Online first, because Sarvam and Bhashini produce far better Indic prosody
/// than a budget phone's built-in voice - and because reading the price
/// rationale aloud in real Hindi is the point (PRD.md §6 step 4). Falls back
/// to the device voice on any failure, including the backend's deliberate 502
/// when neither provider is reachable.
///
/// `speak()` never throws. It returns a [TtsResult] whose `spoken` flag says
/// whether anything was actually audible, so a caller can show "no voice
/// available on this phone" instead of a silent no-op.
class TtsRouter {
  TtsRouter({TtsOnline? online, TtsOffline? offline})
      : _online = online ?? TtsOnline(),
        _offline = offline ?? TtsOffline();

  final TtsOnline _online;
  final TtsOffline _offline;

  Future<TtsResult> speak(TtsInput input) async {
    try {
      final TtsSource source = await _online.speak(input);
      return TtsResult(source: source, spoken: true);
    } catch (_) {
      // Offline, timed out, or the backend returned its 502 "use the device"
      // signal. All three mean the same thing here.
    }

    final bool spoke = await _offline.speak(input);
    return TtsResult(
      source: spoke ? TtsSource.device : TtsSource.none,
      spoken: spoke,
    );
  }

  Future<void> stop() async {
    await _online.stop();
    await _offline.stop();
  }

  void dispose() => _online.dispose();
}
