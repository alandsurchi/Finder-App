import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'app_button.dart';

/// Page header used by every secondary screen: 48dp back button with an
/// accessible name, title (+ optional subtitle) and trailing actions.
class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? leading;
  final bool large;
  final EdgeInsetsGeometry padding;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.showBack = true,
    this.onBack,
    this.actions = const [],
    this.leading,
    this.large = false,
    this.padding = const EdgeInsets.fromLTRB(
        BeaconSpace.page, BeaconSpace.sm, BeaconSpace.page, BeaconSpace.lg),
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;

    final back = showBack
        ? AppIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            variant: AppIconButtonVariant.tonal,
            onPressed: onBack ?? () => Navigator.maybePop(context),
          )
        : null;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null)
          Padding(
            padding: const EdgeInsets.only(bottom: BeaconSpace.xs),
            child: Text(
              eyebrow!.toUpperCase(),
              style: text.labelSmall?.copyWith(color: t.primary),
            ),
          ),
        Text(
          title,
          style: large ? text.headlineMedium : text.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: BeaconSpace.xs),
            child: Text(subtitle!, style: text.bodyMedium),
          ),
      ],
    );

    if (large) {
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (back != null || leading != null || actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: BeaconSpace.lg),
                child: Row(
                  children: [
                    if (leading != null) leading! else if (back != null) back,
                    const Spacer(),
                    ..._spaced(actions),
                  ],
                ),
              ),
            titleBlock,
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: BeaconSpace.md),
          ] else if (back != null) ...[
            back,
            const SizedBox(width: BeaconSpace.md),
          ],
          Expanded(child: titleBlock),
          ..._spaced(actions),
        ],
      ),
    );
  }

  List<Widget> _spaced(List<Widget> items) => [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: BeaconSpace.sm),
          items[i],
        ],
      ];
}

/// Section title with an optional trailing text action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(0, 0, 0, BeaconSpace.md),
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Text(eyebrow!.toUpperCase(),
                      style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                Text(title, style: text.titleLarge),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.sm),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
