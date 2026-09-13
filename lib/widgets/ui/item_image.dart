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
    } else {
      image = Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: BeaconMotion.scaled(context, BeaconMotion.enter),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            width: width,
            color: t.surfaceHigh,
          );
        },
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return ClipRRect(borderRadius: borderRadius, child: image);
  }
}
