import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// The Beacon loader: a primary disc with an amber ring emitting three
/// expanding, fading rings. Static (rings at rest) under reduced motion.
class BeaconPulse extends StatefulWidget {
  final double size;
  const BeaconPulse({super.key, this.size = 64});

  @override
  State<BeaconPulse> createState() => _BeaconPulseState();
}

class _BeaconPulseState extends State<BeaconPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (BeaconMotion.reduced(context)) {
      _c.stop();
      _c.value = 0.35;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final disc = widget.size * 0.42;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _PulsePainter(progress: _c.value, color: t.primary),
          child: Center(
            child: Container(
              width: disc,
              height: disc,
              decoration: BoxDecoration(
                color: t.primary,
                shape: BoxShape.circle,
                border: Border.all(color: t.accent, width: 2),
                boxShadow: [
                  BoxShadow(color: t.accentGlow, blurRadius: 18, spreadRadius: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress;
  final Color color;
  _PulsePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    final minR = size.width * 0.21;
    for (var i = 0; i < 3; i++) {
      final p = (progress + i / 3) % 1;
      final r = minR + (maxR - minR) * p;
      final alpha = (1 - p) * 0.45;
      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 - p;
      canvas.drawCircle(center, r, paint);
    }
    // faint sweep hand
    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi / 2,
        colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.18)],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: maxR));
    canvas.drawCircle(center, maxR * 0.98, sweep);
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) =>
      old.progress != progress || old.color != color;
}
