import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/routes.dart';
import 'package:finder/models/item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/chat/presentation/open_chat.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/features/posts/presentation/saved_items_controller.dart';
import 'package:finder/widgets/ui/app_button.dart';
import 'package:finder/widgets/ui/item_card.dart';
import 'package:finder/widgets/ui/status_badge.dart';

/// Legacy badge descriptor. LOST / FOUND / REWARD labels are rendered with
/// the shared Beacon rule; any other label uses the supplied color.
class BadgeData {
  final String label;
  final Color color;
  BadgeData({required this.label, required this.color});
}

/// Feed card: image, status rail, title, meta, save button and a
/// "Contact owner / finder" call to action that opens a chat.
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

  /// The tile layout shows LOST / FOUND on its spine, so those legacy badges
  /// are dropped here; everything else keeps rendering over the image.
  List<Widget>? _badges() {
    if (badges.isEmpty) return null;
    return badges
        .where((b) {
          final upper = b.label.toUpperCase();
          return upper != 'LOST' && upper != 'FOUND';
        })
        .map((b) {
          if (item.reward != null && b.label == item.reward) {
            return StatusBadge.reward('REWARD ${b.label}');
          }
          return StatusBadge.custom(label: b.label.toUpperCase(), color: b.color);
        })
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;

    return ItemCard(
      item: item,
      margin: const EdgeInsets.fromLTRB(
          BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.lg),
      heroTag: 'item-image-${item.id}',
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: item);
      },
      badges: _badges(),
      banner: bannerText,
      overlay: _SaveButton(item: item),
      subtitle: verifiedUser != null
          ? Row(
              children: [
                Icon(Icons.verified_rounded, color: t.primary, size: 14),
                const SizedBox(width: BeaconSpace.xs),
                Text(
                  verifiedUser!,
                  style: text.labelSmall?.copyWith(color: t.primary),
                ),
              ],
            )
          : null,
      footer: AppButton(
        label: buttonLabel,
        icon: Icons.chat_bubble_outline_rounded,
        size: AppButtonSize.medium,
        onPressed: () => openChatWith(
          context,
          ref,
          peerId: item.ownerId,
          peerName: item.ownerName?.isNotEmpty == true ? item.ownerName! : 'Finder User',
          peerAvatarUrl: item.ownerAvatarUrl,
          postId: item.id,
          itemName: item.title,
        ),
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
    final result =
        await ref.read(savedItemsProvider.notifier).toggleSaved(widget.item);
    if (!mounted) return;
    result.fold(
      onSuccess: (saved) => ActionFeedback.showSuccess(
        context,
        saved ? 'Saved to your list.' : 'Removed from saved items.',
      ),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = (ref.watch(savedItemsProvider).value ?? [])
        .any((i) => i.id == widget.item.id);

    return ScaleTransition(
      scale: _ctrl,
      child: AppIconButton(
        icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        tooltip: saved ? 'Remove from saved' : 'Save item',
        variant: AppIconButtonVariant.glass,
        selected: saved,
        size: 40,
        iconSize: 20,
        onPressed: _tap,
      ),
    );
  }
}
