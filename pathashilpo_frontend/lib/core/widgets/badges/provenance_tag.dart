import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class ProvenanceTag extends StatelessWidget {
  final String? giTag;
  final String cluster;
  final bool compact;

  const ProvenanceTag({
    super.key,
    this.giTag,
    required this.cluster,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (giTag != null && giTag!.isNotEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 10,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: AppColors.giTagBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.giTagGreen.withOpacity(0.4), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_rounded,
              size: compact ? 12 : 14,
              color: AppColors.giTagGreen,
            ),
            const SizedBox(width: 4),
          Flexible(
            child: Text(
              giTag!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w600,
                fontSize: compact ? 10.5 : 12,
                color: AppColors.giTagGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 7 : 10,
      vertical: compact ? 3 : 5,
    ),
    decoration: BoxDecoration(
      color: AppColors.canvasParchment,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.place_outlined,
          size: compact ? 12 : 14,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            cluster,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              fontSize: compact ? 10.5 : 12,
              color: AppColors.deepUmber,
            ),
          ),
        ),
      ],
    ),
  );
  }
}
