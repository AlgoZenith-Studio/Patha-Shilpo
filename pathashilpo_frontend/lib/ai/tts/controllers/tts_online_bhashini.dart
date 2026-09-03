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

  /// TRD.md §8.5 budgets 8s with zero retries: past that the artisan is
  /// better served by the device voice than by waiting.
  /// Deliberately short. This is the first thing between a tap and audio, and
  /// [TtsRouter] has a device-voice fallback right behind it - waiting 8s for a
  /// nicer voice is a worse outcome than speaking now. Synthesis that has not
  /// answered in this long is not going to feel instant anyway.
  static const Duration _timeout = Duration(seconds: 3);

  /// Throws on any failure so the router can fall through. Returns which
  /// provider actually synthesised the audio.
  Future<TtsSource> speak(TtsInput input) async {
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

    await _player.play(BytesSource(audio, mimeType: body['content_type'] as String?));

    return body['source'] == 'sarvam' ? TtsSource.sarvam : TtsSource.bhashini;
  }

  Future<void> stop() => _player.stop();

  void dispose() => _player.dispose();
}
