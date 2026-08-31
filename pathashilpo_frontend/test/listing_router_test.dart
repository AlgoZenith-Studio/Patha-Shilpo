import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/ai/listing/controllers/listing_router.dart';
import 'package:pathashilpa/ai/listing/controllers/listing_template.dart';

/// Minimal fake transport so these tests don't touch the network or need a
/// mocking package - just enough of Dio's adapter contract to return a
/// canned response or throw, matching what `ApiClient` would see in each
/// scenario.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter.success(Map<String, dynamic> body) : _body = body, _fails = false;
  _FakeAdapter.failure() : _body = null, _fails = true;

  final Map<String, dynamic>? _body;
  final bool _fails;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (_fails) {
      throw DioException.connectionTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: options,
      );
    }
    final String json = jsonEncode(_body);
    return ResponseBody.fromString(
      json,
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioReturning(Map<String, dynamic> body) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://test'));
  dio.httpClientAdapter = _FakeAdapter.success(body);
  return dio;
}

Dio _dioThatFails() {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://test'));
  dio.httpClientAdapter = _FakeAdapter.failure();
  return dio;
}

const Map<String, dynamic> _validListingResponse = <String, dynamic>{
  'title': 'Chanderi Saree',
  'title_hi': 'चंदेरी साड़ी',
  'description': 'A handwoven saree.',
  'description_hi': 'हाथ से बुनी साड़ी।',
  'tags': <String>['saree', 'silk', 'handmade'],
  'colors': <String>['blue'],
  'material': 'silk',
  'craft_type': 'saree',
  'generated_by': 'gemini',
};

void main() {
  group('ListingRouter', () {
    test('uses the backend result when online and the call succeeds',
        () async {
      final ListingRouter router = ListingRouter(
        isOnline: () async => true,
        client: _dioReturning(_validListingResponse),
      );

      final ListingResult r = await router.run(transcript: 'a blue saree');

      expect(r.generatedBy, 'gemini');
      expect(r.title, 'Chanderi Saree');
    });

    test('falls back to the offline template when offline', () async {
      final ListingRouter router = ListingRouter(
        isOnline: () async => false,
        // No client wired - if the router tried to call it, this would
        // throw and the test would fail, proving offline skips the call.
      );

      final ListingResult r = await router.run(
        transcript: 'blue silk saree handmade',
        hoursOfWork: 6,
      );

      expect(r.generatedBy, 'template');
    });

    test('falls back to the offline template when the backend call fails',
        () async {
      final ListingRouter router = ListingRouter(
        isOnline: () async => true,
        client: _dioThatFails(),
      );

      // Must not throw - the router contract is "never throws to the caller".
      final ListingResult r = await router.run(
        transcript: 'blue silk saree handmade',
        hoursOfWork: 6,
      );

      expect(r.generatedBy, 'template');
    });

    test('falls back to the offline template if the connectivity check itself throws',
        () async {
      final ListingRouter router = ListingRouter(
        isOnline: () async => throw Exception('platform channel unavailable'),
      );

      // The artisan must always get a listing (TRD.md §7 router contract) -
      // even a broken connectivity check must not surface as an error.
      final ListingResult r = await router.run(transcript: 'test listing');
      expect(r.generatedBy, 'template');
    });
  });
}
