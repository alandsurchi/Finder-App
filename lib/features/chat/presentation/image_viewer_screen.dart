import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../widgets/ui/ui.dart';

/// Full-screen photo: pinch to zoom, swipe down to dismiss.
class ImageViewerScreen extends StatelessWidget {
  final String url;
  final Object? heroTag;

  const ImageViewerScreen({super.key, required this.url, this.heroTag});

  static Future<void> open(BuildContext context, String url, {Object? heroTag}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => ImageViewerScreen(url: url, heroTag: heroTag),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Dismissible(
              key: const ValueKey('image-viewer'),
              direction: DismissDirection.vertical,
              onDismissed: (_) => Navigator.of(context).maybePop(),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: heroTag == null ? image : Hero(tag: heroTag!, child: image),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + BeaconSpace.sm,
            start: BeaconSpace.md,
            child: AppIconButton(
              icon: Icons.close_rounded,
              tooltip: context.l10n.commonClose,
              variant: AppIconButtonVariant.glass,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}
