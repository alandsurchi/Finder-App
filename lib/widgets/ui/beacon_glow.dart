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

/// Places one or two [BeaconGlow]s behind [child] on the scaffold background.
class BeaconBackdrop extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  final double intensity;
  final bool secondary;

  const BeaconBackdrop({
    super.key,
    required this.child,
    this.alignment = const Alignment(1.2, -1.1),
    this.intensity = 1,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
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
