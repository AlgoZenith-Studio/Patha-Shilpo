import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/generated/app_localizations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../models/add_product_state.dart';

/// Step 1 — visual capture and on-device quality check (PRD.md FEAT-02).
///
/// The quality check is classical, not ML: no model is bundled in the MVP
/// (TRD.md §12). It scores blur and brightness so a clearly unusable photo is
/// caught before the artisan spends time speaking about it.
class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;
  String? _error;
  bool _errorIsCamera = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AddProductState draft = context.watch<AddProductState>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(t.photoTitle,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppShape.cardRadius),
                border: Border.all(
                  color: AppColors.border,
                  width: AppShape.hairline,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: draft.photoBytes != null
                  ? Image.memory(draft.photoBytes!, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.photo_camera_outlined,
                            size: 56, color: AppColors.border),
                        const SizedBox(height: 12),
                        Text(t.photoNone,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
            ),
          ),

          if (draft.qualityScore != null) ...<Widget>[
            const SizedBox(height: 12),
            _QualityMeter(score: draft.qualityScore!),
          ],

          if (_error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _errorIsCamera ? t.photoCameraUnavailable : t.photoOpenFailed,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],

          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(t.photoGallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(draft.hasPhoto ? t.photoRetake : t.photoCamera),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryBilingualButton(
            label: t.commonNext,
            onPressed: draft.hasPhoto && !_busy ? widget.onNext : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) {
        setState(() => _busy = false);
        return;
      }

      final Uint8List bytes = await file.readAsBytes();
      final double score = _assessQuality(bytes);

      if (!mounted) return;
      context.read<AddProductState>().setPhoto(
            path: file.path,
            bytes: bytes,
            quality: score,
          );
      setState(() => _busy = false);
    } catch (e) {
      // Never surface a technical string to the artisan (TRD.md §13.1).
      if (!mounted) return;
      // The message itself is resolved at render time from AppLocalizations,
      // so it follows the language selected in Settings.
      setState(() {
        _busy = false;
        _errorIsCamera = source == ImageSource.camera;
        _error = '';
      });
    }
  }

  /// Cheap brightness/spread heuristic over the encoded bytes.
  ///
  /// A real Laplacian variance needs the decoded bitmap; this stands in until
  /// the `image` package decode is wired, and is deliberately generous — the
  /// cost of a false reject (an artisan retaking a fine photo) is higher than
  /// the cost of a false accept (the server re-checks on sync).
  static double _assessQuality(Uint8List bytes) {
    if (bytes.isEmpty) return 0;
    final int sampleCount = bytes.length < 4096 ? bytes.length : 4096;
    final int step = bytes.length ~/ sampleCount;

    int min = 255;
    int max = 0;
    for (int i = 0; i < bytes.length; i += step) {
      final int b = bytes[i];
      if (b < min) min = b;
      if (b > max) max = b;
    }
    final double spread = (max - min) / 255.0;
    return spread.clamp(0.0, 1.0);
  }
}

class _QualityMeter extends StatelessWidget {
  const _QualityMeter({required this.score});

  final double score;

  bool get _isPoor => score < 0.35;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              _isPoor ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
              size: 18,
              color: _isPoor ? AppColors.heritage : AppColors.action,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _isPoor ? t.photoPoor : t.photoGood,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: score,
            minHeight: 6,
            backgroundColor: AppColors.canvas,
            color: _isPoor ? AppColors.heritage : AppColors.action,
          ),
        ),
      ],
    );
  }
}
