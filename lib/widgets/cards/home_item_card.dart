import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/routes.dart';
import 'package:finder/models/item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/features/posts/presentation/saved_items_controller.dart';

class BadgeData {
  final String label;
  final Color color;
  BadgeData({required this.label, required this.color});
}

class HomeItemCard extends ConsumerWidget {
  final ItemModel item;
  final String? verifiedUser;
  final String buttonLabel;
  final List<BadgeData> badges;
  final String? bannerText;
  final Color? lostBadgeColor;
  final Color? rewardBadgeColor;

  const HomeItemCard({
    super.key,
    required this.item,
    this.verifiedUser,
    required this.buttonLabel,
    this.badges = const [],
    this.bannerText,
    this.lostBadgeColor,
    this.rewardBadgeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: item);
      },
      child: Builder(
        builder: (context) {
          final t = AppColorTokens.of(context);
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        item.imagePath,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            color: t.surfaceHigh,
                          ),
                          child: Center(
                            child: Icon(
                              item.isLost
                                  ? Icons.laptop_mac_outlined
                                  : Icons.vpn_key_outlined,
                              color: t.onSurfaceMuted,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (bannerText != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                t.bg.withOpacity(0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            bannerText!,
                            style: TextStyle(
                              color: t.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    if (badges.isNotEmpty)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Row(
                          children: badges
                              .map(
                                (b) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: b.color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      b.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _SaveButton(item: item),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              color: t.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.timeAgo,
                            style: TextStyle(
                              color: t.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (verifiedUser != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.verified, color: t.primary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              verifiedUser!,
                              style: TextStyle(
                                color: t.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: t.onSurfaceVar,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: t.onSurfaceMuted,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.location,
                            style: TextStyle(
                              color: t.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: t.primary,
                            foregroundColor: t.isDark
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final currentUserId = ref.read(authStateProvider).userId ?? '';
                            final ownerId = item.ownerId;
                            
                            if (currentUserId.isEmpty) {
                              ActionFeedback.showInfo(context, 'Please log in to message the owner.');
                              return;
                            }
                            if (ownerId.isEmpty || ownerId == currentUserId) {
                              ActionFeedback.showInfo(context, 'You cannot message yourself.');
                              return;
                            }
                            
                            try {
                              final chatService = ref.read(chatServiceProvider);
                              final chatId = await chatService.createOrGetChat(currentUserId, ownerId, item.id, item.title);
                              
                              if (context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.chat,
                                  arguments: {
                                    'chatId': chatId,
                                    'userName': item.ownerName?.isNotEmpty == true ? item.ownerName! : 'Finder User',
                                    'itemName': item.title,
                                  },
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ActionFeedback.showInfo(context, 'Error creating chat: $e');
                              }
                            }
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 16),
                          label: Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Save / Bookmark button ────────────────────────────────────────────────────
class _SaveButton extends ConsumerStatefulWidget {
  final ItemModel item;
  const _SaveButton({required this.item});

  @override
  ConsumerState<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends ConsumerState<_SaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.82,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    await _ctrl.reverse();
    await _ctrl.forward();
    final notifier = ref.read(savedItemsProvider.notifier);
    await notifier.toggleSaved(widget.item);
    if (mounted) {
      final isSaved = (ref.read(savedItemsProvider).value ?? [])
          .any((i) => i.id == widget.item.id);
      ActionFeedback.showInfo(
        context,
        isSaved ? 'Saved to your list!' : 'Removed from saved items.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = (ref.watch(savedItemsProvider).value ?? [])
        .any((i) => i.id == widget.item.id);
    final t = AppColorTokens.of(context);

    return GestureDetector(
      onTap: _tap,
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: saved
                ? t.primary.withOpacity(0.15)
                : t.surface.withOpacity(0.9),
            shape: BoxShape.circle,
            border: saved
                ? Border.all(color: t.primary.withOpacity(0.4))
                : null,
          ),
          child: Icon(
            saved ? Icons.bookmark_rounded : Icons.bookmark_border,
            color: saved ? t.primary : t.onSurface,
            size: 18,
          ),
        ),
      ),
    );
  }
}
