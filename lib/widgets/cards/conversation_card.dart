import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/routes.dart';
import 'package:finder/models/conversation_model.dart';
import 'package:finder/widgets/ui/app_avatar.dart';
import 'package:finder/widgets/ui/surface_card.dart';

class ConversationCard extends StatelessWidget {
  final ConversationModel convo;

  const ConversationCard({super.key, required this.convo});

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final unread = convo.unreadCount > 0;

    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: BeaconSpace.md),
      padding: const EdgeInsets.all(BeaconSpace.md),
      onTap: () {
        final chatId = convo.chatId.isEmpty
            ? convo.name.toLowerCase().replaceAll(' ', '_')
            : convo.chatId;
        Navigator.pushNamed(
          context,
          AppRoutes.chat,
          arguments: {
            'userName': convo.name,
            'itemName': convo.itemName,
            'chatId': chatId,
          },
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(
            url: convo.avatarUrl,
            name: convo.name,
            size: 52,
            online: convo.isOnline,
          ),
          const SizedBox(width: BeaconSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              convo.name,
                              style: text.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (convo.isVerified) ...[
                            const SizedBox(width: BeaconSpace.xs),
                            Icon(Icons.verified_rounded, color: t.primary, size: 15),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: BeaconSpace.sm),
                    Text(
                      _formatTimeAgo(convo.lastUpdatedAt.toDate()),
                      style: text.bodySmall?.copyWith(
                        color: unread ? t.primary : t.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                if (convo.itemName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 12, color: t.onSurfaceMuted),
                      const SizedBox(width: BeaconSpace.xs),
                      Flexible(
                        child: Text(
                          convo.itemName,
                          style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: BeaconSpace.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        convo.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          color: unread ? t.onSurface : t.onSurfaceVar,
                          fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (unread) ...[
                      const SizedBox(width: BeaconSpace.sm),
                      Container(
                        constraints: const BoxConstraints(minWidth: 22),
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BeaconRadius.rPill,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          convo.unreadCount.toString(),
                          style: text.labelSmall?.copyWith(color: t.onPrimary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
