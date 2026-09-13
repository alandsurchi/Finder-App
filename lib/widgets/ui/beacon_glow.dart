import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';

/// A soft radial amber glow — the Beacon signature. Purely decorative and
/// pointer-transparent; place it in a [Stack] behind content.
class BeaconGlow extends StatelessWidget {
  final Alignment alignment;
  final double radius;

  /// 0‥1 multiplier on the token's alpha.
  final double intensity;
  final Color? color;

  const BeaconGlow({
    super.key,
    this.alignment = Alignment.topRight,
    this.radius = 0.9,
    this.intensity = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final base = color ?? t.accentGlow;
    final a = (base.a * intensity).clamp(0.0, 1.0);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: radius,
            colors: [
              base.withValues(alpha: a),
              base.withValues(alpha: a * 0.35),
              base.withValues(alpha: 0),
            ],
            stops: const [0, 0.35, 1],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Concentric hairline rings — the "radar" texture that sits under the glow
/// on hero surfaces (auth, onboarding, empty states).
class BeaconRings extends StatelessWidget {
  final Alignment alignment;
  final double radius;
  final double opacity;
  final int count;

  const BeaconRings({
    super.key,
    this.alignment = const Alignment(1.1, -1.0),
    this.radius = 320,
    this.opacity = 0.10,
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return IgnorePointer(
      child: CustomPaint(
        painter: _RingsPainter(
          alignment: alignment,
          radius: radius,
          color: t.primary.withValues(alpha: opacity),
          count: count,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final Alignment alignment;
  final double radius;
  final Color color;
  final int count;
  _RingsPainter({
    required this.alignment,
    required this.radius,
    required this.color,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = alignment.alongSize(size);
    for (var i = 1; i <= count; i++) {
      final paint = Paint()
        ..color = color.withValues(alpha: color.a * (1 - i / (count + 1)))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius * i / count, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) =>
      old.alignment != alignment ||
      old.radius != radius ||
      old.color != color ||
      old.count != count;
}

/// Places one or two [BeaconGlow]s (and optionally the ring texture) behind
/// [child] on the scaffold background.
class BeaconBackdrop extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  final double intensity;
  final bool secondary;
  final bool rings;

  const BeaconBackdrop({
    super.key,
    required this.child,
    this.alignment = const Alignment(1.2, -1.1),
    this.intensity = 1,
    this.secondary = false,
    this.rings = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (rings) BeaconRings(alignment: alignment),
        BeaconGlow(alignment: alignment, radius: 0.75, intensity: intensity),
        if (secondary)
          BeaconGlow(
            alignment: const Alignment(-1.3, 1.2),
            radius: 0.8,
            intensity: intensity * 0.6,
            color: t.primaryContainer,
          ),
        child,
      ],
    );
  }
}
