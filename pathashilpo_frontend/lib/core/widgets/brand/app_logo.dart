import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/colors.dart';

/// Reusable Patha-Shilpo Brand Logo using official SVG artwork.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 36,
    this.showBackground = false,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  final double size;
  final bool showBackground;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size * 0.25);

    Widget svg = SvgPicture.asset(
      'assets/patha-shilpo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.action),
        ),
      ),
    );

    if (showBackground) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          border: border ?? Border.all(color: AppColors.border, width: 0.8),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(size * 0.1),
          child: svg,
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: svg,
    );
  }
}
