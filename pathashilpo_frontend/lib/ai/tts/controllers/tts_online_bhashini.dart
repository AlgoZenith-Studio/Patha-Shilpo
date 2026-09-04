import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';

import '../../../data/remote/api_client.dart';
import '../models/tts_input.dart';

/// Online tier: `POST /api/v1/ai/tts`, which tries Sarvam then Bhashini
/// server-side and returns base64 WAV (TRD.md §8.3, §8.5).
///
/// A 502 from that endpoint is a NORMAL outcome, not an error to report - it
/// is how the backend says "both providers are down, use the device voice".
/// [TtsRouter] treats it the same as a timeout.
class TtsOnline {
  TtsOnline({Dio? client, AudioPlayer? player})
      : _client = client,
        _player = player ?? AudioPlayer();

  final Dio? _client;
  final AudioPlayer _player;

  /// Global audio cache by key (language_code:::text) across instances to preload guidance.
  static final Map<String, (Uint8List, String?, TtsSource)> _audioCache =
      <String, (Uint8List, String?, TtsSource)>{};

  static String _cacheKey(TtsInput input) =>
      '${input.languageCode}:::${input.text.trim()}';

  /// TRD.md §8.5 budgets 8s with zero retries: past that the artisan is
  /// better served by the device voice than by waiting.
  /// Deliberately short. This is the first thing between a tap and audio, and
  /// [TtsRouter] has a device-voice fallback right behind it - waiting 8s for a
  /// nicer voice is a worse outcome than speaking now. Synthesis that has not
  /// answered in this long is not going to feel instant anyway.
  static const Duration _timeout = Duration(seconds: 4);

  /// Preloads audio into memory cache in the background so subsequent speak() calls are instant.
  Future<void> preload(TtsInput input) async {
    final String key = _cacheKey(input);
    if (_audioCache.containsKey(key)) return;

    try {
      final Dio client = _client ?? ApiClient.instance;
      final Response<Map<String, dynamic>> response =
          await client.post<Map<String, dynamic>>(
        '/api/v1/ai/tts',
        data: <String, dynamic>{
          'text': input.text,
          'language_code': input.languageCode,
        },
        options: Options(receiveTimeout: const Duration(seconds: 8), sendTimeout: const Duration(seconds: 8)),
      );

      final Map<String, dynamic> body = response.data!;
      final Uint8List audio = base64Decode(body['audio'] as String);
      final String? contentType = body['content_type'] as String?;
      final TtsSource source =
          body['source'] == 'sarvam' ? TtsSource.sarvam : TtsSource.bhashini;

      _audioCache[key] = (audio, contentType, source);
    } catch (_) {
      // Best effort background preloading; ignore errors.
    }
  }

  /// Throws on any failure so the router can fall through. Returns which
  /// provider actually synthesised the audio.
  Future<TtsSource> speak(TtsInput input) async {
    final String key = _cacheKey(input);
    if (_audioCache.containsKey(key)) {
      final (Uint8List cachedAudio, String? contentType, TtsSource source) =
          _audioCache[key]!;
      await _player.play(BytesSource(cachedAudio, mimeType: contentType));
      return source;
    }

    final Dio client = _client ?? ApiClient.instance;

    final Response<Map<String, dynamic>> response =
        await client.post<Map<String, dynamic>>(
      '/api/v1/ai/tts',
      data: <String, dynamic>{
        'text': input.text,
        'language_code': input.languageCode,
      },
      options: Options(receiveTimeout: _timeout, sendTimeout: _timeout),
    );

    final Map<String, dynamic> body = response.data!;
    final Uint8List audio = base64Decode(body['audio'] as String);
    final String? contentType = body['content_type'] as String?;
    final TtsSource source =
        body['source'] == 'sarvam' ? TtsSource.sarvam : TtsSource.bhashini;

    _audioCache[key] = (audio, contentType, source);

    await _player.play(BytesSource(audio, mimeType: contentType));

    return source;
  }

  Future<void> stop() => _player.stop();

  void dispose() => _player.dispose();
}
