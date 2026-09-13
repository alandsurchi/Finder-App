import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Bottom-sheet chrome: grabber, title row with close button, content and a
/// pinned action row above the safe area.
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final bool scrollable;
  final EdgeInsetsGeometry contentPadding;
  final double? maxHeightFactor;

  const AppBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.actions = const [],
    this.scrollable = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
    this.maxHeightFactor,
  });

  /// Shows a modal sheet using the app's sheet theme. The returned future
  /// resolves with whatever the sheet pops.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final maxH = media.size.height * (maxHeightFactor ?? 0.88);

    final header = (title != null)
        ? Padding(
            padding: const EdgeInsets.fromLTRB(
                BeaconSpace.page, 0, BeaconSpace.sm, BeaconSpace.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: text.headlineSmall),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle!, style: text.bodyMedium),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          )
        : const SizedBox(height: BeaconSpace.sm);

    final content = Padding(padding: contentPadding, child: child);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: BeaconSpace.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: t.outline,
              borderRadius: BeaconRadius.rPill,
            ),
          ),
          const SizedBox(height: BeaconSpace.lg),
          header,
          if (scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: actions.isEmpty ? BeaconSpace.xxl : BeaconSpace.lg,
                ),
                child: content,
              ),
            )
          else
            content,
          if (actions.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                BeaconSpace.page,
                BeaconSpace.sm,
                BeaconSpace.page,
                BeaconSpace.lg + media.viewInsets.bottom,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: BeaconSpace.md),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple tappable option row for pickers inside sheets.
class SheetOption extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;
  final bool destructive;

  const SheetOption({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final fg = destructive ? t.error : t.onSurface;
    return Material(
      color: selected ? t.primaryContainer : Colors.transparent,
      borderRadius: BeaconRadius.rLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: BeaconSpace.lg, vertical: BeaconSpace.md),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: BeaconIcon.md,
                    color: destructive ? t.error : (selected ? t.primary : t.onSurfaceVar)),
                const SizedBox(width: BeaconSpace.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.titleMedium?.copyWith(color: fg)),
                    if (subtitle != null) Text(subtitle!, style: text.bodySmall),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_rounded, color: t.primary),
            ],
          ),
        ),
      ),
    );
  }
}
