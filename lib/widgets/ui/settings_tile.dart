import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'surface_card.dart';

/// Groups tiles into one tonal card with an optional eyebrow title.
class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  const SettingsGroup({
    super.key,
    this.title,
    required this.children,
    this.margin = const EdgeInsets.only(bottom: BeaconSpace.xxl),
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(
                  left: BeaconSpace.xs, bottom: BeaconSpace.sm),
              child: Text(
                title!.toUpperCase(),
                style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
              ),
            ),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xs),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 64, right: BeaconSpace.lg),
                      child: Divider(color: t.outlineVariant, height: 1),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigational row: icon tile, title, optional subtitle, chevron.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;
  final Color? iconColor;
  final bool showChevron;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final fg = destructive ? t.error : t.onSurface;
    final ic = iconColor ?? (destructive ? t.error : t.primary);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: BeaconSpace.lg, vertical: BeaconSpace.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: destructive ? t.errorSurface : t.surfaceLow,
                  borderRadius: BeaconRadius.rMd,
                ),
                child: Icon(icon, size: 20, color: ic),
              ),
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium?.copyWith(color: fg)),
                    if (subtitle != null)
                      Text(subtitle!, style: text.bodySmall),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showChevron && onTap != null)
                Icon(Icons.chevron_right_rounded, color: t.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row with a trailing switch. The whole row toggles.
class ToggleTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? badge;

  const ToggleTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BeaconSpace.lg, vertical: BeaconSpace.sm),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: value ? t.primaryContainer : t.surfaceLow,
                      borderRadius: BeaconRadius.rMd,
                    ),
                    child: Icon(icon,
                        size: 20, color: value ? t.primary : t.onSurfaceVar),
                  ),
                  const SizedBox(width: BeaconSpace.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(title, style: text.titleMedium)),
                          if (badge != null) ...[
                            const SizedBox(width: BeaconSpace.sm),
                            badge!,
                          ],
                        ],
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: text.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: BeaconSpace.sm),
                Switch.adaptive(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
