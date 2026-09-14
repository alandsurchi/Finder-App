import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/features/chat/presentation/open_chat.dart';
import 'package:finder/features/posts/presentation/saved_items_controller.dart';
import 'package:finder/features/posts/presentation/similar_items_provider.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';
import 'package:finder/widgets/cards/similar_card.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/providers/user_provider.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:finder/screens/edit_post_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finder/screens/location_picker_screen.dart';

class ItemDetailsScreen extends ConsumerWidget {
  const ItemDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final argItem = (args is ItemModel) ? args : ItemModel.empty();
    // Refresh from the server so status / edits made elsewhere show up.
    final fresh = argItem.id.isEmpty
        ? const AsyncValue<ItemModel>.loading()
        : ref.watch(postByIdProvider(argItem.id));
    final item = fresh.value ?? argItem;

    final title = item.title.isEmpty ? 'Item Details' : item.title;
    final description = item.description.isEmpty
        ? 'No description provided yet.'
        : item.description;

    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final ownerProfileAsync = ref.watch(userProfileProvider(item.ownerId));
    final currentUserId = ref.watch(authStateProvider).userId ?? '';
    final isOwner = currentUserId.isNotEmpty && currentUserId == item.ownerId;
    final kind = SignalKindX.ofItem(item);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, ref, item, isOwner),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  BeaconSpace.page, BeaconSpace.sm, BeaconSpace.page, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badges ──────────────────────────────────────────
                  StaggeredEntrance(
                    child: Wrap(
                      spacing: BeaconSpace.sm,
                      runSpacing: BeaconSpace.sm,
                      children: [
                        StatusBadge.signal(kind, withIcon: true),
                        if (item.hasReward)
                          StatusBadge.reward('REWARD \$${item.reward}'),
                        if (item.isResolved) StatusBadge.resolved(),
                        if (item.isVerified) StatusBadge.verified(small: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: BeaconSpace.md),

                  StaggeredEntrance(
                    index: 1,
                    child: Text(
                      title,
                      style: text.headlineMedium?.copyWith(
                        color: item.isResolved ? t.onSurfaceMuted : t.onSurface,
                        decoration:
                            item.isResolved ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: BeaconSpace.sm),

                  StaggeredEntrance(
                    index: 1,
                    child: Row(
                      children: [
                        Icon(Icons.place_outlined, size: 16, color: t.onSurfaceMuted),
                        const SizedBox(width: BeaconSpace.xs),
                        Flexible(
                          child: Text(
                            item.location.isEmpty ? 'Location not specified' : item.location,
                            style: text.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('  ·  ${item.timeAgo}', style: text.bodyMedium),
                      ],
                    ),
                  ),

                  const SizedBox(height: BeaconSpace.lg),

                  StaggeredEntrance(
                    index: 2,
                    child: Text(description, style: text.bodyLarge),
                  ),

                  const SizedBox(height: BeaconSpace.xxl),

                  // ── Primary call to action ───────────────────────────
                  if (!isOwner && !item.isResolved)
                    StaggeredEntrance(
                      index: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: BeaconSpace.xxl),
                        child: AppButton(
                          label: item.isLost ? 'I found this item' : 'This is mine',
                          icon: item.isLost
                              ? Icons.volunteer_activism_outlined
                              : Icons.front_hand_outlined,
                          variant: AppButtonVariant.accent,
                          onPressed: () => _startChat(context, ref, item, ownerProfileAsync.value),
                        ),
                      ),
                    ),

                  if (isOwner && item.isResolved)
                    StaggeredEntrance(
                      index: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: BeaconSpace.xxl),
                        child: SurfaceCard(
                          tone: SurfaceTone.low,
                          child: Row(
                            children: [
                              Icon(Icons.task_alt_rounded, color: t.found),
                              const SizedBox(width: BeaconSpace.md),
                              Expanded(
                                child: Text(
                                  'This post is resolved and hidden from the feed.',
                                  style: text.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  StaggeredEntrance(
                    index: 3,
                    child: _buildDetailsCard(item, context, t),
                  ),

                  const SizedBox(height: BeaconSpace.xxl),

                  StaggeredEntrance(
                    index: 4,
                    child: _buildOwnerCard(item, ownerProfileAsync, context, ref, t, isOwner),
                  ),

                  const SizedBox(height: BeaconSpace.xl),

                  StaggeredEntrance(
                    index: 5,
                    child: _buildActions(context, ref, item, isOwner, ownerProfileAsync.value, t),
                  ),

                  const SizedBox(height: BeaconSpace.xxxl),

                  StaggeredEntrance(
                    index: 6,
                    child: _buildSimilarSection(context, ref, item),
                  ),

                  SizedBox(height: BeaconSpace.huge + MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat ───────────────────────────────────────────────────────────────────
  Future<void> _startChat(
    BuildContext context,
    WidgetRef ref,
    ItemModel item,
    UserModel? owner,
  ) {
    final name = owner?.displayName ??
        ((item.ownerName?.isNotEmpty ?? false) ? item.ownerName! : 'Finder User');
    return openChatWith(
      context,
      ref,
      peerId: item.ownerId,
      peerName: name,
      peerAvatarUrl: owner?.avatarUrl ?? item.ownerAvatarUrl,
      postId: item.id,
      itemName: item.title,
    );
  }

  // ── Sliver app bar with hero image ─────────────────────────────────────────
  Widget _buildSliverAppBar(
      BuildContext context, WidgetRef ref, ItemModel item, bool isOwner) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final topPad = MediaQuery.paddingOf(context).top;
    final saved = ref.watch(savedItemsProvider.select(
        (s) => (s.value ?? const []).any((i) => i.id == item.id)));

    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      stretch: true,
      backgroundColor: t.bg,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(BeaconRadius.xxl + 4),
        child: Container(
          height: BeaconRadius.xxl + 4,
          decoration: BoxDecoration(
            color: t.bg,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(BeaconRadius.xxl + 4)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: BeaconSpace.md),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: t.outline,
              borderRadius: BeaconRadius.rPill,
            ),
          ),
        ),
      ),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 64,
      leading: Center(
        child: AppIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          variant: AppIconButtonVariant.glass,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        if (!isOwner)
          AppIconButton(
            icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            tooltip: saved ? 'Remove from saved' : 'Save item',
            variant: AppIconButtonVariant.glass,
            selected: saved,
            onPressed: () => _toggleSaved(context, ref, item),
          ),
        if (!isOwner) const SizedBox(width: BeaconSpace.sm),
        AppIconButton(
          icon: Icons.share_outlined,
          tooltip: 'Copy item details',
          variant: AppIconButtonVariant.glass,
          onPressed: () => _copyDetails(context, item),
        ),
        const SizedBox(width: BeaconSpace.sm),
        AppIconButton(
          icon: Icons.more_vert_rounded,
          tooltip: 'More actions',
          variant: AppIconButtonVariant.glass,
          onPressed: () => _showMoreSheet(context, ref, item, isOwner),
        ),
        const SizedBox(width: BeaconSpace.md),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final collapsed =
              constraints.biggest.height <= kToolbarHeight + topPad + 24;
          return FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            centerTitle: false,
            titlePadding: const EdgeInsetsDirectional.only(
                start: 64, end: 150, bottom: 18),
            title: AnimatedOpacity(
              duration: BeaconMotion.scaled(context, BeaconMotion.state),
              opacity: collapsed ? 1 : 0,
              child: Text(
                item.title.isEmpty ? 'Item details' : item.title,
                style: text.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                ItemImage(
                  url: item.imagePath,
                  heroTag: 'item-image-${item.id}',
                  fallbackIcon: categoryIcon(item.category),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: const Alignment(0, -0.4),
                      colors: [
                        t.shadow.withValues(alpha: 0.35),
                        t.shadow.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _copyDetails(BuildContext context, ItemModel item) async {
    final text = '${item.isLost ? 'Lost' : 'Found'} item: ${item.title}\n'
        'Location: ${item.location}\n'
        'Details: ${item.description}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ActionFeedback.showInfo(context, 'Item details copied to clipboard.');
  }

  Future<void> _toggleSaved(BuildContext context, WidgetRef ref, ItemModel item) async {
    final result = await ref.read(savedItemsProvider.notifier).toggleSaved(item);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (saved) => ActionFeedback.showSuccess(
        context,
        saved ? 'Saved to your list.' : 'Removed from saved items.',
      ),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  // ── More sheet ─────────────────────────────────────────────────────────────
  void _showMoreSheet(BuildContext context, WidgetRef ref, ItemModel item, bool isOwner) {
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: isOwner ? 'Manage post' : 'More',
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetOption(
              icon: Icons.copy_rounded,
              label: 'Copy details',
              onTap: () {
                Navigator.pop(sheetCtx);
                _copyDetails(context, item);
              },
            ),
            if (isOwner) ...[
              if (!item.isResolved)
                SheetOption(
                  icon: Icons.edit_outlined,
                  label: 'Edit post',
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditPostScreen(post: item)),
                    );
                    ref.invalidate(postByIdProvider(item.id));
                  },
                ),
              SheetOption(
                icon: item.isResolved
                    ? Icons.replay_rounded
                    : Icons.check_circle_outline_rounded,
                label: item.isResolved ? 'Reopen post' : 'Mark as resolved',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  item.isResolved
                      ? _reopen(context, ref, item)
                      : _resolve(context, ref, item);
                },
              ),
              SheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Delete post',
                destructive: true,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmDelete(context, ref, item);
                },
              ),
            ] else ...[
              SheetOption(
                icon: Icons.flag_outlined,
                label: 'Report post',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _report(context, ref, item);
                },
              ),
              SheetOption(
                icon: Icons.block_rounded,
                label: 'Block this member',
                destructive: true,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmBlock(context, ref, item);
                },
              ),
            ],
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  // ── Owner / safety actions ─────────────────────────────────────────────────
  Future<void> _resolve(BuildContext context, WidgetRef ref, ItemModel item) async {
    final result = await ref.read(myPostsProvider.notifier).markResolved(item.id);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {
        ref.invalidate(postByIdProvider(item.id));
        ActionFeedback.showSuccess(context, 'Post marked as resolved.');
      },
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Future<void> _reopen(BuildContext context, WidgetRef ref, ItemModel item) async {
    final result = await ref.read(myPostsProvider.notifier).reopen(item.id);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {
        ref.invalidate(postByIdProvider(item.id));
        ActionFeedback.showSuccess(context, 'Post is active again.');
      },
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ItemModel item) {
    final t = AppColorTokens.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text('"${item.title}" will be removed for everyone. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: t.error,
              foregroundColor: t.onError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await ref.read(myPostsProvider.notifier).deletePost(item.id);
              if (!context.mounted) return;
              result.fold(
                onSuccess: (_) {
                  ActionFeedback.showSuccess(context, 'Post deleted.');
                  Navigator.pop(context);
                },
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _report(BuildContext context, WidgetRef ref, ItemModel item) async {
    const reasons = [
      'Spam or scam',
      'Inappropriate content',
      'Wrong or misleading information',
      'Something else',
    ];
    final reason = await AppBottomSheet.show<String>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: 'Report this post',
        subtitle: 'Tell us what is wrong. Reports are reviewed by the team.',
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in reasons)
              SheetOption(
                icon: Icons.flag_outlined,
                label: r,
                onTap: () => Navigator.pop(sheetCtx, r),
              ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
    if (reason == null || !context.mounted) return;
    try {
      await ref.read(postServiceProvider).reportPost(item.id, reason);
      if (!context.mounted) return;
      ActionFeedback.showSuccess(context, 'Thanks, the post has been reported.');
    } catch (e) {
      if (!context.mounted) return;
      ActionFeedback.showError(context, describeError(e));
    }
  }

  void _confirmBlock(BuildContext context, WidgetRef ref, ItemModel item) {
    final t = AppColorTokens.of(context);
    final name = (item.ownerName?.isNotEmpty ?? false) ? item.ownerName! : 'this member';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Block $name?'),
        content: const Text(
            'You will no longer see each other\'s posts or messages. You can undo this in Privacy & safety.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: t.error,
              foregroundColor: t.onError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await ref.read(blockedUsersProvider.notifier).blockUser(
                    item.ownerId,
                    name: item.ownerName,
                    avatarUrl: item.ownerAvatarUrl,
                  );
              if (!context.mounted) return;
              result.fold(
                onSuccess: (_) {
                  ActionFeedback.showSuccess(context, '$name has been blocked.');
                  Navigator.pop(context);
                },
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  // ── Detail rows card ────────────────────────────────────────────────────────
  Widget _buildDetailsCard(ItemModel item, BuildContext context, AppColorTokens t) {
    return SurfaceCard(
      padding: const EdgeInsets.all(BeaconSpace.sm),
      child: Column(
        children: [
          _detailRow(
            context,
            icon: categoryIcon(item.category),
            label: 'Category',
            value: item.category.isEmpty ? null : item.category,
          ),
          _detailRow(
            context,
            icon: Icons.calendar_today_outlined,
            label: item.isLost ? 'Lost on' : 'Found on',
            value: item.lostOn,
          ),
          _detailRow(
            context,
            icon: Icons.place_outlined,
            label: 'Location',
            value: item.location.isEmpty ? null : item.location,
          ),
          const SizedBox(height: BeaconSpace.sm),
          MapPreview(
            latitude: item.latitude,
            longitude: item.longitude,
            height: 160,
            label: item.location.isEmpty ? 'Location not specified' : item.location,
            onTap: item.hasCoordinates
                ? () => LocationPickerScreen.view(context, item.place!,
                    title: item.title)
                : null,
          ),
          if (item.hasCoordinates) ...[
            const SizedBox(height: BeaconSpace.sm),
            AppButton.ghost(
              label: 'Open in Maps',
              icon: Icons.directions_outlined,
              size: AppButtonSize.medium,
              onPressed: () => _openInMaps(context, item),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openInMaps(BuildContext context, ItemModel item) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${item.latitude},${item.longitude}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ActionFeedback.showError(context, 'Could not open a maps app.');
    }
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? value,
  }) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final displayValue =
        (value == null || value.trim().isEmpty) ? 'Not provided' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: BeaconSpace.sm, vertical: BeaconSpace.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.primaryContainer,
              borderRadius: BeaconRadius.rMd,
            ),
            child: Icon(icon, color: t.primary, size: 20),
          ),
          const SizedBox(width: BeaconSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                const SizedBox(height: 2),
                Text(displayValue, style: text.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Owner card ──────────────────────────────────────────────────────────────
  Widget _buildOwnerCard(
    ItemModel item,
    AsyncValue<UserModel?> ownerProfileAsync,
    BuildContext context,
    WidgetRef ref,
    AppColorTokens t,
    bool isOwner,
  ) {
    final text = Theme.of(context).textTheme;
    final profile = ownerProfileAsync.value;

    final ownerName = isOwner
        ? 'You'
        : (profile?.displayName ??
            ((item.ownerName?.isNotEmpty ?? false) ? item.ownerName! : 'Finder User'));
    final avatarUrl = profile?.avatarUrl.isNotEmpty == true
        ? profile!.avatarUrl
        : item.ownerAvatarUrl;
    final verified = item.isVerified || (profile?.identityVerified ?? false);
    final phone = profile?.phone ?? '';
    final memberSince = profile == null ? null : _monthYear(profile.createdAt.toDate());
    final postsCount = profile?.postsCount;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.isLost ? 'POSTED BY THE OWNER' : 'POSTED BY THE FINDER',
            style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
          ),
          const SizedBox(height: BeaconSpace.md),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(url: avatarUrl, name: ownerName, size: 56),
                  if (verified)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: t.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 2),
                        ),
                        child: Icon(Icons.check_rounded, color: t.onPrimary, size: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ownerName, style: text.titleMedium),
                    const SizedBox(height: 2),
                    if (ownerProfileAsync.isLoading && profile == null)
                      Text('Loading profile…', style: text.bodySmall)
                    else if (profile == null)
                      Text('Profile not available', style: text.bodySmall)
                    else
                      Text(
                        [
                          if (verified) 'Verified member',
                          if (memberSince != null) 'Member since $memberSince',
                          if (postsCount != null)
                            '$postsCount post${postsCount == 1 ? '' : 's'}',
                        ].join(' · '),
                        style: text.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (!isOwner) ...[
            const SizedBox(height: BeaconSpace.lg),
            if (phone.isNotEmpty)
              _contactRow(
                context,
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: phone,
                onTap: () => _launch(context, 'tel:$phone', 'Could not open the phone dialer.'),
              ),
            AppButton(
              label: item.isLost ? 'Chat with owner' : 'Chat with finder',
              icon: Icons.chat_bubble_outline_rounded,
              size: AppButtonSize.medium,
              onPressed: () => _startChat(context, ref, item, profile),
            ),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: BeaconSpace.md),
              AppButton.secondary(
                label: 'Call',
                icon: Icons.phone_outlined,
                size: AppButtonSize.medium,
                onPressed: () => _launch(context, 'tel:$phone', 'Could not open the phone dialer.'),
              ),
            ] else ...[
              const SizedBox(height: BeaconSpace.sm),
              Text(
                'Phone number not shared. In-app chat is the safest way to coordinate.',
                style: text.bodySmall,
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _monthYear(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Future<void> _launch(BuildContext context, String url, String failure) async {
    final uri = Uri.parse(url);
    final ok = await canLaunchUrl(uri) && await launchUrl(uri);
    if (!ok && context.mounted) ActionFeedback.showInfo(context, failure);
  }

  Widget _contactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: BeaconSpace.md),
      child: Material(
        color: t.surfaceLow,
        borderRadius: BeaconRadius.rMd,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BeaconSpace.md, vertical: BeaconSpace.sm),
            child: Row(
              children: [
                Icon(icon, color: t.primary, size: 20),
                const SizedBox(width: BeaconSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label.toUpperCase(),
                          style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                      Text(value, style: text.titleSmall?.copyWith(color: t.primary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: t.onSurfaceMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Owner / safety actions ──────────────────────────────────────────────────
  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    ItemModel item,
    bool isOwner,
    UserModel? owner,
    AppColorTokens t,
  ) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOwner ? 'OWNER ACTIONS' : 'SAFETY',
          style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
        ),
        const SizedBox(height: BeaconSpace.sm),
        Wrap(
          spacing: BeaconSpace.sm,
          runSpacing: BeaconSpace.sm,
          children: [
            if (!isOwner) ...[
              AppButton.ghost(
                label: 'Report post',
                icon: Icons.flag_outlined,
                onPressed: () => _report(context, ref, item),
              ),
              AppButton.ghost(
                label: 'Block member',
                icon: Icons.block_rounded,
                onPressed: () => _confirmBlock(context, ref, item),
              ),
            ] else ...[
              if (!item.isResolved)
                AppButton.tonal(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  size: AppButtonSize.medium,
                  expand: false,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditPostScreen(post: item)),
                    );
                    ref.invalidate(postByIdProvider(item.id));
                  },
                ),
              AppButton.tonal(
                label: item.isResolved ? 'Reopen' : 'Mark as resolved',
                icon: item.isResolved
                    ? Icons.replay_rounded
                    : Icons.check_circle_outline_rounded,
                size: AppButtonSize.medium,
                expand: false,
                onPressed: () => item.isResolved
                    ? _reopen(context, ref, item)
                    : _resolve(context, ref, item),
              ),
              AppButton.danger(
                label: 'Delete post',
                icon: Icons.delete_outline_rounded,
                size: AppButtonSize.medium,
                expand: false,
                onPressed: () => _confirmDelete(context, ref, item),
              ),
            ]
          ],
        ),
      ],
    );
  }

  // ── Similar items section ───────────────────────────────────────────────────
  Widget _buildSimilarSection(BuildContext context, WidgetRef ref, ItemModel item) {
    final similarState = ref.watch(similarItemsProvider(item.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Similar items',
          eyebrow: item.isLost ? 'Found items in this category' : 'Lost items in this category',
          actionLabel: 'View all',
          onAction: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        similarState.when(
          loading: () => const LoadingWidget(message: 'Loading similar items...'),
          error: (err, _) => ErrorStateWidget(
            message: describeError(err),
            onRetry: () => ref.invalidate(similarItemsProvider(item.id)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyWidget(
                icon: Icons.radar_rounded,
                title: 'No similar items yet',
                subtitle: 'Check back later for matches nearby.',
              );
            }
            return SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: BeaconSpace.md),
                itemBuilder: (context, index) => SimilarCard(item: items[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}
