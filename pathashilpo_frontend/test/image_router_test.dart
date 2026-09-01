import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/ai/image/controllers/image_result.dart';
import 'package:pathashilpa/ai/image/controllers/image_router.dart';

/// The router's contract (TRD.md §7) is that `run()` NEVER throws - the
/// artisan must always end up with a usable image. These tests exercise the
/// three ways that promise can be tested: offline, backend failure, success.
void main() {
  final Uint8List photo = Uint8List.fromList(<int>[1, 2, 3, 4]);

  test('offline returns the original bytes, marked degraded', () async {
    const ImageRouter router = ImageRouter(isOnline: _offline);

    final ImageResult r = await router.run(photo);

    expect(r.degraded, isTrue);
    expect(r.backgroundRemoved, isFalse);
    expect(r.imageUrl, startsWith('data:image/jpeg;base64,'));
  });

  test('a backend failure falls back instead of throwing', () async {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:1'));
    final ImageRouter router = ImageRouter(isOnline: _online, client: dio);

    final ImageResult r = await router.run(photo);

    expect(r.degraded, isTrue);
    expect(r.imageUrl, startsWith('data:image/jpeg;base64,'));
  });

  test('a successful call surfaces the processed URL', () async {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'));
    dio.httpClientAdapter = _StubAdapter();
    final ImageRouter router = ImageRouter(isOnline: _online, client: dio);

    final ImageResult r = await router.run(photo);

    expect(r.degraded, isFalse);
    expect(r.backgroundRemoved, isTrue);
    expect(r.imageUrl, 'https://cdn.test/processed.png');
  });
}

Future<bool> _offline() async => false;
Future<bool> _online() async => true;

class _StubAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    return ResponseBody.fromString(
      '{"image_url":"https://cdn.test/processed.png",'
      '"background_removed":true,"degraded":false}',
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
