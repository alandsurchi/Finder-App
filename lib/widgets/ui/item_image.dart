import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Maps a post category to a representative icon.
IconData categoryIcon(String category) {
  final c = category.toLowerCase();
  if (c.contains('electron') || c.contains('phone') || c.contains('laptop')) {
    return Icons.devices_other_rounded;
  }
  if (c.contains('watch') || c.contains('jewel')) return Icons.watch_rounded;
  if (c.contains('wallet') || c.contains('bag')) return Icons.work_outline_rounded;
  if (c.contains('key')) return Icons.key_rounded;
  if (c.contains('pet')) return Icons.pets_rounded;
  if (c.contains('cloth')) return Icons.checkroom_rounded;
  if (c.contains('doc')) return Icons.description_outlined;
  return Icons.inventory_2_outlined;
}

/// Network image with a tokenized fallback, a fade-in and a fixed size so the
/// layout never shifts.
class ItemImage extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData? fallbackIcon;
  final String? heroTag;

  const ItemImage({
    super.key,
    required this.url,
    this.height,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.fallbackIcon,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);

    Widget fallback() => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [t.surfaceHigh, t.surfaceLow],
            ),
          ),
          child: Center(
            child: Icon(
              fallbackIcon ?? Icons.image_outlined,
              color: t.onSurfaceMuted,
              size: (height ?? 120) * 0.3,
            ),
          ),
        );

    Widget image;
    if (url.trim().isEmpty) {
      image = fallback();
    } else if (url.startsWith('assets/')) {
      image = Image.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback(),
      );
    } else {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      int? px(double? v) =>
          (v == null || !v.isFinite || v <= 0) ? null : (v * dpr).round();
      image = CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width,
        fit: fit,
        // Decode at the size we draw, not the size the phone camera took.
        memCacheWidth: px(width),
        memCacheHeight: px(height),
        fadeInDuration: BeaconMotion.scaled(context, BeaconMotion.enter),
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) => Container(
          height: height,
          width: width,
          color: t.surfaceHigh,
        ),
        errorWidget: (_, __, ___) => fallback(),
      );
    }

    final clipped = ClipRRect(borderRadius: borderRadius, child: image);
    if (heroTag == null || BeaconMotion.reduced(context)) return clipped;

    // The hero wraps the rounded clip so the corners fly too, and the
    // shuttle redraws the image at every frame size so it never stretches.
    return Hero(
      tag: heroTag!,
      createRectTween: (begin, end) => MaterialRectArcTween(begin: begin, end: end),
      placeholderBuilder: (context, size, child) => child,
      flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
        final from = _radiusOf(fromContext);
        final to = _radiusOf(toContext);
        final fromImage = _imageOf(fromContext) ?? url;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final tValue = direction == HeroFlightDirection.push
                ? animation.value
                : 1 - animation.value;
            final radius = BorderRadius.lerp(from, to, tValue) ?? BorderRadius.zero;
            return ClipRRect(
              borderRadius: radius,
              child: _HeroImage(url: fromImage, fallback: fallback),
            );
          },
        );
      },
      child: clipped,
    );
  }

  static BorderRadius _radiusOf(BuildContext context) {
    final w = context.widget;
    if (w is Hero && w.child is ClipRRect) {
      final r = (w.child as ClipRRect).borderRadius;
      if (r is BorderRadius) return r;
    }
    return BorderRadius.zero;
  }

  static String? _imageOf(BuildContext context) {
    String? found;
    context.visitChildElements((el) {
      final w = el.widget;
      if (w is CachedNetworkImage) found = w.imageUrl;
    });
    return found;
  }
}

/// The image drawn during a hero flight: same cache key as both ends, so it
/// paints immediately from memory, covering whatever size the flight has.
class _HeroImage extends StatelessWidget {
  final String url;
  final Widget Function() fallback;
  const _HeroImage({required this.url, required this.fallback});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return fallback();
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback());
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder: (_, __) => Container(color: AppColorTokens.of(context).surfaceHigh),
      errorWidget: (_, __, ___) => fallback(),
    );
  }
}
