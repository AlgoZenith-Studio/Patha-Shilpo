import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../../../data/remote/api_client.dart';
import 'listing_template.dart';

/// Router for listing generation (TRD.md AD-5): tries the backend's
/// `POST /api/v1/ai/listing` (Gemini, per TRD.md §8.1) when a network is
/// reported, and falls back to the offline [ListingTemplate] on any failure -
/// timeout, non-2xx, no connectivity, or `connectivity_plus` reporting a
/// network that turns out not to actually reach the backend. `run()` never
/// throws; the artisan always gets a listing (TRD.md §7 router contract).
class ListingRouter {
  const ListingRouter({
    Future<bool> Function()? isOnline,
    Dio? client,
    ListingTemplate template = const ListingTemplate(),
  })  : _isOnlineOverride = isOnline,
        _client = client,
        _template = template;

  /// Injectable for tests; defaults to a real `connectivity_plus` check.
  final Future<bool> Function()? _isOnlineOverride;
  final Dio? _client;
  final ListingTemplate _template;

  Future<ListingResult> run({
    required String transcript,
    String? craftType,
    String? material,
    List<String>? colors,
    int? hoursOfWork,
  }) async {
    if (await _safeIsOnline()) {
      try {
        return await _callBackend(
          transcript: transcript,
          craftType: craftType,
          material: material,
          colors: colors,
          hoursOfWork: hoursOfWork,
        );
      } catch (_) {
        // Falls through to the offline template - see class doc.
      }
    }

    return _template.generate(
      transcript: transcript,
      craftHint: craftType,
      hoursOfWork: hoursOfWork,
    );
  }

  /// Never throws - a failed connectivity check is treated as offline rather
  /// than propagating, which would break the "run() never throws" contract.
  Future<bool> _safeIsOnline() async {
    try {
      if (_isOnlineOverride != null) return await _isOnlineOverride();
      final List<ConnectivityResult> result =
          await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none) && result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<ListingResult> _callBackend({
    required String transcript,
    String? craftType,
    String? material,
    List<String>? colors,
    int? hoursOfWork,
  }) async {
    final Dio client = _client ?? ApiClient.instance;

    final Response<Map<String, dynamic>> response =
        await client.post<Map<String, dynamic>>(
      '/api/v1/ai/listing',
      // craft_type is required by the backend schema; the app doesn't collect
      // it as a separate field from the artisan, so it falls back to a
      // generic hint - Gemini still has the full transcript to work from.
      data: <String, dynamic>{
        'transcript': transcript,
        'craft_type': (craftType?.trim().isNotEmpty ?? false)
            ? craftType!.trim()
            : 'handicraft',
        if (material != null && material.trim().isNotEmpty)
          'material': material.trim(),
        if (colors != null && colors.isNotEmpty) 'colors': colors,
        if (hoursOfWork != null) 'hours_of_work': hoursOfWork,
      },
      options: Options(receiveTimeout: const Duration(seconds: 12)),
    );

    final Map<String, dynamic> body = response.data!;
    return ListingResult(
      title: body['title'] as String,
      titleHi: body['title_hi'] as String,
      description: body['description'] as String,
      descriptionHi: body['description_hi'] as String,
      tags: (body['tags'] as List<dynamic>).cast<String>(),
      colors: (body['colors'] as List<dynamic>).cast<String>(),
      material: body['material'] as String,
      craftType: body['craft_type'] as String,
      generatedBy: body['generated_by'] as String,
    );
  }
}
