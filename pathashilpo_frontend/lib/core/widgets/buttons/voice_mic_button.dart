import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// The voice capture trigger — the single most important control in the app.
///
/// DESIGN_SYSTEM.md §2D: circular [AppColors.action] button with gentle pulsing
/// rings in [AppColors.heritage] while listening.
class VoiceMicButton extends StatefulWidget {
  const VoiceMicButton({
    super.key,
    required this.isListening,
    required this.onPressed,
    this.size = 96,
  });

  final bool isListening;
  final VoidCallback? onPressed;
  final double size;

  @override
  State<VoiceMicButton> createState() => _VoiceMicButtonState();
}

class _VoiceMicButtonState extends State<VoiceMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isListening) _controller.repeat();
  }

  @override
  void didUpdateWidget(VoiceMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isListening && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double ringExtent = widget.size * 1.9;

    return Semantics(
      button: true,
      label: widget.isListening ? 'Listening. Tap to stop.' : 'Tap to speak',
      excludeSemantics: true,
      child: SizedBox(
        width: ringExtent,
        height: ringExtent,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (widget.isListening)
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, _) {
                  return CustomPaint(
                    size: Size.square(ringExtent),
                    painter: _PulseRingPainter(
                      progress: _controller.value,
                      baseDiameter: widget.size,
                    ),
                  );
                },
              ),
            Material(
              color: AppColors.action,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: widget.onPressed,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Icon(
                    widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    size: widget.size * 0.44,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two rings staggered half a cycle apart, expanding outward and fading.
class _PulseRingPainter extends CustomPainter {
  const _PulseRingPainter({
    required this.progress,
    required this.baseDiameter,
  });

  final double progress;
  final double baseDiameter;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = size.center(Offset.zero);
    final double maxRadius = size.width / 2;
    final double minRadius = baseDiameter / 2;

    for (final double offset in <double>[0, 0.5]) {
      final double t = (progress + offset) % 1.0;
      final double radius = minRadius + (maxRadius - minRadius) * t;
      final double opacity = (1.0 - t) * 0.55;

      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = AppColors.heritage.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_PulseRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
