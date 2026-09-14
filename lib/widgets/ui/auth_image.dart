import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/app/di/app_providers.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// An image fetched from the Finder API with the session token, for files
/// that are never served publicly (identity documents, selfies).
class AuthImage extends ConsumerStatefulWidget {
  /// API path, e.g. `/admin/verification/<id>/file/front`.
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const AuthImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  /// Small in-memory cache so revisiting a screen does not refetch.
  static final Map<String, Uint8List> _cache = {};

  static void evict(String path) => _cache.remove(path);

  @override
  ConsumerState<AuthImage> createState() => _AuthImageState();
}

class _AuthImageState extends ConsumerState<AuthImage> {
  late Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant AuthImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _future = _load();
  }

  Future<Uint8List> _load() async {
    final cached = AuthImage._cache[widget.path];
    if (cached != null) return cached;
    final bytes = await ref.read(apiClientProvider).getBytes(widget.path);
    AuthImage._cache[widget.path] = bytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FutureBuilder<Uint8List>(
          future: _future,
          builder: (context, snap) {
            if (snap.hasData) {
              return Image.memory(
                snap.data!,
                fit: widget.fit,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => _fallback(t, Icons.broken_image_outlined),
              );
            }
            if (snap.hasError) {
              return _fallback(t, Icons.lock_outline_rounded,
                  label: 'Could not load');
            }
            return Container(
              color: t.surfaceHigh,
              alignment: Alignment.center,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: t.primary),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fallback(AppColorTokens t, IconData icon, {String? label}) {
    final text = Theme.of(context).textTheme;
    return Container(
      color: t.surfaceLow,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: t.onSurfaceMuted, size: 28),
          if (label != null) ...[
            const SizedBox(height: BeaconSpace.xs),
            Text(label, style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}
