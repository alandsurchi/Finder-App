import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/widgets/ui/app_button.dart';

/// Empty state with an illustration disc, title, subtitle and optional CTA.
class EmptyWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BeaconSpace.xxxl, vertical: BeaconSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [t.accentGlow, t.accentGlow.withValues(alpha: 0)],
                  radius: 0.9,
                ),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: t.surfaceLow,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.outlineVariant),
                  ),
                  child: Icon(icon, size: 28, color: t.onSurfaceVar),
                ),
              ),
            ),
            const SizedBox(height: BeaconSpace.lg),
            Text(title, textAlign: TextAlign.center, style: text.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: BeaconSpace.sm),
              Text(subtitle!, textAlign: TextAlign.center, style: text.bodyMedium),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: BeaconSpace.xxl),
              AppButton.tonal(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
