import 'package:flutter/material.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/chat/presentation/open_chat.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/routes.dart';
import 'package:finder/models/conversation_model.dart';
import 'package:finder/widgets/ui/app_avatar.dart';
import 'package:finder/widgets/ui/surface_card.dart';

class ConversationCard extends StatelessWidget {
  final ConversationModel convo;

  const ConversationCard({super.key, required this.convo});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final unread = convo.unreadCount > 0;

    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: BeaconSpace.md),
      padding: const EdgeInsets.all(BeaconSpace.md),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chat,
          arguments: {
            ChatArgs.chatId: convo.chatId,
            ChatArgs.userName: convo.name,
            ChatArgs.itemName: convo.itemName,
            ChatArgs.peerId: convo.peerId,
            ChatArgs.peerAvatarUrl: convo.avatarUrl,
            ChatArgs.postId: convo.postId,
            ChatArgs.postOwnerId: convo.postOwnerId,
            ChatArgs.postStatus: convo.postStatus,
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
                      relativeTime(convo.lastUpdatedAt.millisecondsSinceEpoch),
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
                        convo.message.isEmpty ? 'No messages yet' : convo.message,
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
