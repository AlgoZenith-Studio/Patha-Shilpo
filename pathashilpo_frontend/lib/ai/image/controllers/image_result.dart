/// Output contract for the image pipeline (TRD.md §7).
class ImageResult {
  const ImageResult({
    required this.imageUrl,
    required this.backgroundRemoved,
    required this.degraded,
  });

  /// A remote URL when the backend processed it, or a local `data:` URI when
  /// it did not - callers should not assume this is always fetchable without
  /// checking.
  final String imageUrl;
  final bool backgroundRemoved;

  /// True when this is the original image, unprocessed - either because the
  /// device is offline or the backend call failed.
  final bool degraded;
}
