import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:finder/theme/app_color_tokens.dart';
import 'beacon_glow.dart';

/// The band behind a profile's avatar: the member's cover photo with a
/// soft scrim at the bottom, or the Beacon gradient when there is none.
class ProfileCover extends StatelessWidget {
  final String url;
  final double height;
  final Widget? overlay;

  const ProfileCover({super.key, required this.url, this.height = 140, this.overlay});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final hasCover = url.trim().isNotEmpty;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasCover)
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              memCacheHeight: (height * dpr * 1.5).round(),
              fadeInDuration: const Duration(milliseconds: 240),
              placeholder: (_, __) => DecoratedBox(decoration: BoxDecoration(gradient: t.primaryGradient)),
              errorWidget: (_, __, ___) => DecoratedBox(decoration: BoxDecoration(gradient: t.primaryGradient)),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(gradient: t.primaryGradient),
              child: const Stack(
                fit: StackFit.expand,
                children: [
                  BeaconGlow(alignment: Alignment(1.1, -0.6), radius: 0.9),
                  BeaconRings(alignment: Alignment(1.05, -0.5), radius: 180, opacity: 0.18),
                ],
              ),
            ),
          if (hasCover)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.32),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}
