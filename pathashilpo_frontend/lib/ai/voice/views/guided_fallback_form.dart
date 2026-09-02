import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Guided fallback form when microphone or speech recognizer is unavailable.
class GuidedFallbackForm extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback? onSubmitted;

  const GuidedFallbackForm({
    super.key,
    required this.controller,
    this.label = 'Craft Description',
    this.hint = 'Describe material, tradition, colors, and hours worked...',
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.keyboard_outlined, size: 18, color: AppColors.action),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Pally',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'Lora',
              fontSize: 14,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.action, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
