import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../models/item_model.dart';
import '../../../widgets/ui/ui.dart';

/// Tells the owner where their post stands in the review flow: waiting,
/// sent back with a reason, or archived. Null for live posts.
class PostReviewBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final SurfaceTone tone;
  final Color Function(AppColorTokens t) accent;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PostReviewBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.tone,
    required this.accent,
    this.actionLabel,
    this.onAction,
  });

  static PostReviewBanner? forPost(ItemModel post, {VoidCallback? onEdit, VoidCallback? onReopen}) {
    if (post.isPending) {
      return PostReviewBanner(
        icon: Icons.hourglass_top_rounded,
        title: L10n.current.postWaitingForReview,
        body: L10n.current.postWaitingForReviewBody,
        tone: SurfaceTone.accent,
        accent: (t) => t.accentDeep,
      );
    }
    if (post.isRejected) {
      final reason = (post.rejectionReason ?? '').trim();
      return PostReviewBanner(
        icon: Icons.block_rounded,
        title: L10n.current.postRejectedTitle,
        body: reason.isEmpty ? '' : L10n.current.postRejectedReason(reason),
        tone: SurfaceTone.error,
        accent: (t) => t.error,
        actionLabel: onEdit == null ? null : L10n.current.postEditAndResubmit,
        onAction: onEdit,
      );
    }
    if (post.isExpired) {
      return PostReviewBanner(
        icon: Icons.inventory_outlined,
        title: L10n.current.postExpiredTitle,
        body: L10n.current.postExpiredBody,
        tone: SurfaceTone.high,
        accent: (t) => t.onSurfaceVar,
        actionLabel: onReopen == null ? null : L10n.current.commonReopen,
        onAction: onReopen,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final color = accent(t);
    return SurfaceCard(
      tone: tone,
      border: false,
      padding: const EdgeInsets.all(BeaconSpace.md),
      radius: BeaconRadius.lg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: BeaconSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall?.copyWith(color: color)),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(body, style: text.bodySmall),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: BeaconSpace.sm),
                  AppButton.tonal(
                    label: actionLabel!,
                    icon: Icons.edit_outlined,
                    size: AppButtonSize.small,
                    expand: false,
                    onPressed: onAction,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
