import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread ? t.primaryContainer : t.surface,
        borderRadius: BorderRadius.circular(16),
        border: isUnread
            ? Border.all(color: t.primary.withOpacity(0.3), width: 1)
            : Border.all(color: t.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: t.onSurface,
                        )),
                    Text(timeAgo,
                        style: TextStyle(
                            fontSize: 12,
                            color: t.onSurfaceMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message,
                    style: TextStyle(
                        fontSize: 13,
                        color: t.onSurfaceVar,
                        height: 1.4)),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                  color: t.primary, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}
