import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';

/// Circular avatar with initials fallback, optional ring and status dot.
class AppAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double size;
  final bool ring;
  final bool? online;
  final IconData fallbackIcon;
  final Color? background;

  const AppAvatar({
    super.key,
    this.url,
    this.name,
    this.size = 48,
    this.ring = false,
    this.online,
    this.fallbackIcon = Icons.person_rounded,
    this.background,
  });

  String get _initials {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '';
    final parts = n.split(RegExp(r'\s+'));
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final hasUrl = url != null && url!.trim().isNotEmpty;
    final initials = _initials;

    Widget fallback = Container(
      color: background ?? t.primaryContainer,
      alignment: Alignment.center,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: (size >= 64 ? text.headlineSmall : text.titleSmall)
                  ?.copyWith(color: t.onPrimaryContainer),
            )
          : Icon(fallbackIcon, color: t.primary, size: size * 0.5),
    );

    Widget content = !hasUrl
        ? fallback
        : url!.startsWith('assets/')
            ? Image.asset(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              );

    Widget avatar = ClipOval(
      child: SizedBox(width: size, height: size, child: content),
    );

    if (ring) {
      avatar = Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: t.primary, width: 2),
        ),
        child: avatar,
      );
    }

    if (online == null) return avatar;

    final dot = size * 0.26;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: dot,
            height: dot,
            decoration: BoxDecoration(
              color: online! ? t.found : t.onSurfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: t.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
