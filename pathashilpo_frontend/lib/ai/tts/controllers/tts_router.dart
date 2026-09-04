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
/// **Why there is a circuit breaker.** "Online first" used to mean *every*
/// tap paid a full network round trip before any sound came out. With the
/// backend unreachable, asleep on a free dyno, or answering its 502 "no
/// provider configured", that was a 5+ second silence on every single press -
/// on a screen whose entire purpose is reading instructions aloud to someone
/// who may not read. Now the first failure opens the breaker and every tap for
/// the next [_breakerCooldown] goes straight to the device voice, which starts
/// speaking immediately. One slow tap instead of all of them.
///
/// `speak()` never throws. It returns a [TtsResult] whose `spoken` flag says
/// whether anything was actually audible, so a caller can show "no voice
/// available on this phone" instead of a silent no-op.
class TtsRouter {
  TtsRouter({TtsOnline? online, TtsOffline? offline, DateTime Function()? clock})
      : _online = online ?? TtsOnline(),
        _offline = offline ?? TtsOffline(),
        _now = clock ?? DateTime.now;

  final TtsOnline _online;
  final TtsOffline _offline;
  final DateTime Function() _now;

  /// How long the online tier stays skipped after a failure.
  ///
  /// Long enough that a broken backend costs one slow tap rather than dozens;
  /// short enough that recovery is picked up within a single sitting.
  static const Duration _breakerCooldown = Duration(minutes: 3);

  /// Shared across instances on purpose: screens create their own [TtsRouter],
  /// and one screen discovering the backend is down should spare every other
  /// screen the same wait.
  static DateTime? _onlineBlockedUntil;

  /// Test seam - lets a test start from a known state.
  static void resetBreaker() => _onlineBlockedUntil = null;

  bool get _onlineAvailable {
    final DateTime? until = _onlineBlockedUntil;
    if (until == null) return true;
    if (_now().isAfter(until)) {
      _onlineBlockedUntil = null; // cooldown elapsed, try the network again
      return true;
    }
    return false;
  }

  Future<TtsResult> speak(TtsInput input) async {
    if (_onlineAvailable) {
      try {
        final TtsSource source = await _online.speak(input);
        _onlineBlockedUntil = null; // healthy again
        return TtsResult(source: source, spoken: true);
      } catch (_) {
        // Offline, timed out, or the backend returned its 502 "use the device"
        // signal. All three mean the same thing here: stop paying the network
        // cost on every subsequent tap.
        _onlineBlockedUntil = _now().add(_breakerCooldown);
      }
    }

    final bool spoke = await _offline.speak(input);
    return TtsResult(
      source: spoke ? TtsSource.device : TtsSource.none,
      spoken: spoke,
    );
  }

  /// Preloads speech synthesis into memory cache and warms the device TTS.
  /// Call this when a screen loads so voice instructions start immediately when tapped.
  Future<void> preload(TtsInput input) async {
    if (_onlineAvailable) {
      // Fire-and-forget background preload
      _online.preload(input);
    }
    _offline.prewarm(input.languageCode);
  }

  /// Preloads a list of voice guidance prompts in parallel.
  Future<void> preloadBatch(List<TtsInput> inputs) async {
    for (final input in inputs) {
      preload(input);
    }
  }

  Future<void> stop() async {
    await _online.stop();
    await _offline.stop();
  }

  void dispose() => _online.dispose();
}
