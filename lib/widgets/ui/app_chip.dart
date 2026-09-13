import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'press_scale.dart';

/// Selectable pill chip.
class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? selectedForeground;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.selectedColor,
    this.selectedForeground,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final bg = selected ? (selectedColor ?? t.primary) : t.surfaceLow;
    final fg = selected ? (selectedForeground ?? t.onPrimary) : t.onSurfaceVar;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: PressScale(
        scale: 0.95,
        child: AnimatedContainer(
          duration: BeaconMotion.scaled(context, BeaconMotion.state),
          curve: BeaconMotion.standard,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BeaconRadius.rPill,
            border: Border.all(
              color: selected ? Colors.transparent : t.outlineVariant,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BeaconRadius.rPill,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: fg),
                      const SizedBox(width: BeaconSpace.xs + 2),
                    ],
                    Text(label, style: text.labelLarge?.copyWith(color: fg)),
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

/// Segmented control with a sliding indicator. Options are labels; the
/// selected index drives the indicator position.
class SegmentedPills extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  const SegmentedPills({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final duration = BeaconMotion.scaled(context, BeaconMotion.state);

    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surfaceLow,
        borderRadius: BeaconRadius.rPill,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth / options.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: duration,
                curve: BeaconMotion.emphasized,
                left: w * selectedIndex,
                top: 0,
                bottom: 0,
                width: w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BeaconRadius.rPill,
                    border: Border.all(color: t.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: t.shadow.withValues(alpha: t.isDark ? 0.4 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < options.length; i++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: i == selectedIndex,
                        label: options[i],
                        child: InkWell(
                          borderRadius: BeaconRadius.rPill,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: duration,
                              style: text.labelLarge!.copyWith(
                                color: i == selectedIndex
                                    ? t.onSurface
                                    : t.onSurfaceVar,
                              ),
                              child: Text(options[i], maxLines: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
