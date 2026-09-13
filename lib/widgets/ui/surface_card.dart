import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'press_scale.dart';

enum SurfaceTone { base, low, high, primary, accent, lost, found, error }

/// Tonal card. Depth comes from the surface tone, not shadows; an optional
/// hairline border is available for dark mode where tones sit close together.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final SurfaceTone tone;
  final VoidCallback? onTap;
  final bool border;
  final bool elevated;
  final Clip clipBehavior;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(BeaconSpace.lg),
    this.margin,
    this.radius = BeaconRadius.xl,
    this.tone = SurfaceTone.base,
    this.onTap,
    this.border = false,
    this.elevated = false,
    this.clipBehavior = Clip.antiAlias,
  });

  static Color toneColor(AppColorTokens t, SurfaceTone tone) => switch (tone) {
        SurfaceTone.base => t.surface,
        SurfaceTone.low => t.surfaceLow,
        SurfaceTone.high => t.surfaceHigh,
        SurfaceTone.primary => t.primaryContainer,
        SurfaceTone.accent => t.accentContainer,
        SurfaceTone.lost => t.lostContainer,
        SurfaceTone.found => t.foundContainer,
        SurfaceTone.error => t.errorSurface,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border || t.isDark
          ? BorderSide(color: t.outlineVariant)
          : BorderSide.none,
    );

    Widget body = Padding(padding: padding, child: child);
    if (onTap != null) {
      body = InkWell(onTap: onTap, child: body);
    }

    Widget card = Material(
      color: toneColor(t, tone),
      shape: shape,
      clipBehavior: clipBehavior,
      child: body,
    );

    if (elevated) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: t.shadow.withValues(alpha: t.isDark ? 0.35 : 0.06),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: card,
      );
    }

    if (onTap != null) card = PressScale(scale: 0.985, child: card);
    if (margin != null) card = Padding(padding: margin!, child: card);
    return card;
  }
}

/// Frosted glass panel for floating chrome (nav, overlays on images).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(BeaconSpace.lg),
    this.radius = BeaconRadius.xl,
    this.blur = 18,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final br = borderRadius ?? BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Material(
          color: t.glassSurface,
          shape: RoundedRectangleBorder(
            borderRadius: br,
            side: BorderSide(color: t.glassBorder),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
