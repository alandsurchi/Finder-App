import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/widgets/ui/press_scale.dart';

/// Round social sign-in button (Google asset or a brand icon).
class SocialButton extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final String? imageAsset;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const SocialButton({
    super.key,
    this.icon,
    this.color,
    this.imageAsset,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? 'Continue with social account',
      child: PressScale(
        enabled: enabled,
        scale: 0.93,
        child: Material(
          color: t.surface,
          shape: CircleBorder(side: BorderSide(color: t.outlineVariant)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: imageAsset != null
                    ? Padding(
                        padding: const EdgeInsets.all(BeaconSpace.lg),
                        child: Image.asset(imageAsset!),
                      )
                    : Icon(icon, color: color ?? t.onSurface, size: 26),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
