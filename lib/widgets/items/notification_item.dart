import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/widgets/ui/surface_card.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;

    return Semantics(
      label: isUnread ? 'Unread notification' : null,
      child: SurfaceCard(
        margin: const EdgeInsets.only(bottom: BeaconSpace.md),
        padding: const EdgeInsets.all(BeaconSpace.md),
        tone: isUnread ? SurfaceTone.primary : SurfaceTone.base,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: t.isDark ? 0.18 : 0.12),
                borderRadius: BeaconRadius.rMd,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: BeaconSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: text.titleSmall?.copyWith(
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: BeaconSpace.sm),
                      Text(timeAgo,
                          style: text.bodySmall?.copyWith(color: t.onSurfaceMuted)),
                    ],
                  ),
                  const SizedBox(height: BeaconSpace.xs),
                  Text(message, style: text.bodyMedium),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: BeaconSpace.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
