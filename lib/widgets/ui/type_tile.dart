import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'press_scale.dart';
import 'status_badge.dart';

/// "I lost something" / "I found something" selector tile.
class LostFoundTypeTile extends StatelessWidget {
  final SignalKind kind;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const LostFoundTypeTile({
    super.key,
    required this.kind,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final color = kind.color(t);
    final container = kind.container(t);
    final isLost = kind == SignalKind.lost;
    final title = isLost ? 'I lost something' : 'I found something';
    final subtitle = isLost ? 'Ask the community for help' : 'Help return it home';

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: PressScale(
        child: AnimatedContainer(
          duration: BeaconMotion.scaled(context, BeaconMotion.state),
          curve: BeaconMotion.standard,
          padding: EdgeInsets.all(compact ? BeaconSpace.md : BeaconSpace.lg),
          decoration: BoxDecoration(
            color: selected ? container : t.surface,
            borderRadius: BeaconRadius.rXl,
            border: Border.all(
              color: selected ? color : t.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BeaconRadius.rXl,
              onTap: onTap,
              child: compact
                  ? Row(
                      children: [
                        _iconDisc(t, color, selected),
                        const SizedBox(width: BeaconSpace.md),
                        Expanded(
                          child: Text(kind == SignalKind.lost ? 'Lost' : 'Found',
                              style: text.titleMedium),
                        ),
                        if (selected) Icon(Icons.check_rounded, color: color),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _iconDisc(t, color, selected),
                            const Spacer(),
                            AnimatedOpacity(
                              duration: BeaconMotion.scaled(
                                  context, BeaconMotion.state),
                              opacity: selected ? 1 : 0,
                              child: Icon(Icons.check_circle_rounded, color: color),
                            ),
                          ],
                        ),
                        const SizedBox(height: BeaconSpace.md),
                        Text(title, style: text.titleMedium),
                        const SizedBox(height: 2),
                        Text(subtitle, style: text.bodySmall),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconDisc(AppColorTokens t, Color color, bool selected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: selected ? color : t.surfaceLow,
        shape: BoxShape.circle,
      ),
      child: Icon(
        kind.icon,
        size: 20,
        color: selected ? kind.onColor(t) : t.onSurfaceVar,
      ),
    );
  }
}
