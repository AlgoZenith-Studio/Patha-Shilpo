import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/ai/tts/controllers/tts_offline_flutter.dart';
import 'package:pathashilpa/ai/tts/controllers/tts_online_bhashini.dart';
import 'package:pathashilpa/ai/tts/controllers/tts_router.dart';
import 'package:pathashilpa/ai/tts/models/tts_input.dart';

/// The router's contract (TRD.md §8.5): online first, device voice second,
/// and `speak()` never throws whatever happens.
void main() {
  const TtsInput input = TtsInput(text: 'Materials 200 rupees', languageCode: 'hi');

  test('uses the online tier when it succeeds', () async {
    final TtsRouter router = TtsRouter(
      online: _FakeOnline(TtsSource.sarvam),
      offline: _FakeOffline(available: true),
    );

    final TtsResult r = await router.speak(input);

    expect(r.source, TtsSource.sarvam);
    expect(r.spoken, isTrue);
  });

  test('falls back to the device voice when the backend fails', () async {
    // Covers the backend's deliberate 502 as well as a timeout - the router
    // cannot and should not tell them apart.
    final TtsRouter router = TtsRouter(
      online: _FakeOnline(null),
      offline: _FakeOffline(available: true),
    );

    final TtsResult r = await router.speak(input);

    expect(r.source, TtsSource.device);
    expect(r.spoken, isTrue);
  });

  test('reports silence honestly when no tier can speak', () async {
    final TtsRouter router = TtsRouter(
      online: _FakeOnline(null),
      offline: _FakeOffline(available: false),
    );

    final TtsResult r = await router.speak(input);

    expect(r.source, TtsSource.none);
    expect(r.spoken, isFalse,
        reason: 'the UI must be able to say "no voice available"');
  });
}

class _FakeOnline implements TtsOnline {
  _FakeOnline(this._source);

  final TtsSource? _source;

  @override
  Future<TtsSource> speak(TtsInput input) async {
    if (_source == null) throw Exception('backend unavailable');
    return _source;
  }

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOffline implements TtsOffline {
  _FakeOffline({required this.available});

  final bool available;

  @override
  Future<bool> speak(TtsInput input) async => available;

  @override
  Future<void> stop() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
