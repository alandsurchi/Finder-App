import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'press_scale.dart';

enum AppButtonVariant { primary, secondary, tonal, ghost, danger, accent }

enum AppButtonSize { large, medium, small }

/// The single call-to-action button. Pill shaped, 52dp tall by default,
/// keeps its width while [isLoading] swaps the label for a spinner.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool iconTrailing;
  final bool isLoading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.iconTrailing = false,
    this.isLoading = false,
    this.expand = true,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.iconTrailing = false,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.iconTrailing = false,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.tonal;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconTrailing = false,
    this.isLoading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.iconTrailing = false,
    this.isLoading = false,
    this.expand = true,
  }) : variant = AppButtonVariant.danger;

  double get _height => switch (size) {
        AppButtonSize.large => 52,
        AppButtonSize.medium => 44,
        AppButtonSize.small => 36,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final enabled = onPressed != null && !isLoading;

    final (Color bg, Color fg, Color? border) = switch (variant) {
      AppButtonVariant.primary => (t.primary, t.onPrimary, null),
      AppButtonVariant.accent => (t.accent, t.onAccent, null),
      AppButtonVariant.secondary => (Colors.transparent, t.primary, t.outline),
      AppButtonVariant.tonal => (t.primaryContainer, t.onPrimaryContainer, null),
      AppButtonVariant.ghost => (Colors.transparent, t.primary, null),
      AppButtonVariant.danger => (t.errorSurface, t.error, null),
    };

    final textStyle = (size == AppButtonSize.small
            ? Theme.of(context).textTheme.labelMedium
            : Theme.of(context).textTheme.labelLarge)
        ?.copyWith(color: fg);

    final iconSize = size == AppButtonSize.small ? 16.0 : 20.0;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !iconTrailing) ...[
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: BeaconSpace.sm),
        ],
        Flexible(
          child: Text(
            label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (icon != null && iconTrailing) ...[
          const SizedBox(width: BeaconSpace.sm),
          Icon(icon, size: iconSize, color: fg),
        ],
      ],
    );

    final child = Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: isLoading ? 0 : 1,
          duration: BeaconMotion.scaled(context, BeaconMotion.state),
          child: content,
        ),
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          ),
      ],
    );

    return PressScale(
      enabled: enabled,
      child: AnimatedOpacity(
        opacity: enabled || isLoading ? 1 : 0.45,
        duration: BeaconMotion.scaled(context, BeaconMotion.state),
        child: Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: Material(
            color: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BeaconRadius.rPill,
              side: border != null ? BorderSide(color: border) : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                height: _height,
                width: expand ? double.infinity : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size == AppButtonSize.small
                        ? BeaconSpace.md
                        : BeaconSpace.xxl,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AppIconButtonVariant { tonal, ghost, glass, filled, outlined }

/// Icon-only button with a guaranteed accessible name and a 44–48dp target.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final AppIconButtonVariant variant;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? background;
  final bool selected;
  final Widget? badge;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.variant = AppIconButtonVariant.tonal,
    this.size = 44,
    this.iconSize = BeaconIcon.md,
    this.color,
    this.background,
    this.selected = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final (Color bg, Color fg, Color? border) = switch (variant) {
      AppIconButtonVariant.tonal => (t.surfaceLow, t.onSurface, null),
      AppIconButtonVariant.ghost => (Colors.transparent, t.onSurface, null),
      AppIconButtonVariant.glass => (t.glassSurface, t.onSurface, t.glassBorder),
      AppIconButtonVariant.filled => (t.primary, t.onPrimary, null),
      AppIconButtonVariant.outlined => (Colors.transparent, t.onSurface, t.outline),
    };
    final effectiveBg = background ?? (selected ? t.primaryContainer : bg);
    final effectiveFg = color ?? (selected ? t.primary : fg);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        selected: selected,
        child: PressScale(
          enabled: onPressed != null,
          scale: 0.92,
          child: Material(
            color: effectiveBg,
            shape: CircleBorder(
              side: border != null ? BorderSide(color: border) : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, size: iconSize, color: effectiveFg),
                    if (badge != null)
                      Positioned(top: 8, right: 8, child: badge!),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small dot used as a badge on icon buttons and nav items.
class BadgeDot extends StatelessWidget {
  final Color? color;
  final double size;
  const BadgeDot({super.key, this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? t.accent,
        shape: BoxShape.circle,
        border: Border.all(color: t.surface, width: 1.5),
      ),
    );
  }
}
