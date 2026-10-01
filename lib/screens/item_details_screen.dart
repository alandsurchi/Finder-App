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
import 'package:finder/features/posts/presentation/item_details_args.dart';
import 'package:finder/features/posts/presentation/post_matches_provider.dart';
import 'package:finder/features/share/share_service.dart';
import 'package:finder/core/utils/hero_tags.dart';
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
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/l10n/l10n.dart';

class ItemDetailsScreen extends ConsumerWidget {
  const ItemDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeArgs = ItemDetailsArgs.from(ModalRoute.of(context)?.settings.arguments);
    final argItem = routeArgs?.item ?? ItemModel.empty();
    final heroTag = routeArgs?.heroTag;
    final matchedPostId = routeArgs?.matchedPostId;
    // Refresh from the server so status / edits made elsewhere show up.
    final fresh = argItem.id.isEmpty
        ? const AsyncValue<ItemModel>.loading()
        : ref.watch(postByIdProvider(argItem.id));
    final item = fresh.value ?? argItem;
    final l10n = context.l10n;

    final title = item.title.isEmpty ? l10n.postItemDetailsTitle : item.title;
    final description = item.description.isEmpty
        ? l10n.postNoDescription
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
          _buildSliverAppBar(context, ref, item, isOwner, heroTag),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  BeaconSpace.page, BeaconSpace.sm, BeaconSpace.page, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (matchedPostId != null && matchedPostId.isNotEmpty && !isOwner)
                    _MatchBanner(
                      item: item,
                      onChat: () => _startChat(context, ref, item, ownerProfileAsync.value),
                    ),
                  // ── Badges ──────────────────────────────────────────
                  StaggeredEntrance(
                    child: Wrap(
                      spacing: BeaconSpace.sm,
                      runSpacing: BeaconSpace.sm,
                      children: [
                        StatusBadge.signal(kind, withIcon: true),
                        if (item.hasReward)
                          StatusBadge.reward(l10n.postRewardAmount('\$${item.reward}')),
                        if (item.isResolved) StatusBadge.resolved(),
                        if (item.isVerified) StatusBadge.verified(small: false),
                        if (item.ownerIsAdmin) adminBadge(small: false),
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
                            item.location.isEmpty ? l10n.commonLocationNotSpecified : item.location,
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
                          label: item.isLost ? l10n.postIFoundThis : l10n.postThisIsMine,
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
                                  l10n.postReturnedOwnerNote,
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

                  if (isOwner && !item.isResolved) ...[
                    StaggeredEntrance(
                      index: 6,
                      child: _buildMatchesSection(context, ref, item),
                    ),
                    const SizedBox(height: BeaconSpace.xxl),
                  ],

                  StaggeredEntrance(
                    index: 7,
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
        ((item.ownerName?.isNotEmpty ?? false) ? item.ownerName! : context.l10n.commonFinderUser);
    return openChatWith(
      context,
      ref,
      peerId: item.ownerId,
      peerName: name,
      peerAvatarUrl: owner?.avatarUrl ?? item.ownerAvatarUrl,
      postId: item.id,
      itemName: item.title,
      postOwnerId: item.ownerId,
      postStatus: item.isResolved ? 'resolved' : 'active',
      peerVerified: item.isVerified || (owner?.identityVerified ?? false),
      peerAdmin: item.ownerIsAdmin || (owner?.isAdmin ?? false),
    );
  }

  // ── Sliver app bar with hero image ─────────────────────────────────────────
  Widget _buildSliverAppBar(
      BuildContext context, WidgetRef ref, ItemModel item, bool isOwner, String? heroTag) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final topPad = MediaQuery.paddingOf(context).top;
    final l10n = context.l10n;
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
          tooltip: l10n.commonBack,
          variant: AppIconButtonVariant.glass,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        if (!isOwner)
          AppIconButton(
            icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            tooltip: saved ? l10n.postRemoveFromSaved : l10n.postSaveItem,
            variant: AppIconButtonVariant.glass,
            selected: saved,
            onPressed: () => _toggleSaved(context, ref, item),
          ),
        if (!isOwner) const SizedBox(width: BeaconSpace.sm),
        Builder(
          builder: (btnCtx) => AppIconButton(
            icon: Icons.ios_share_rounded,
            tooltip: l10n.commonShare,
            variant: AppIconButtonVariant.glass,
            onPressed: () => _share(btnCtx, ref, item),
          ),
        ),
        const SizedBox(width: BeaconSpace.sm),
        AppIconButton(
          icon: Icons.more_vert_rounded,
          tooltip: l10n.postMoreActions,
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
                item.title.isEmpty ? l10n.postItemDetails : item.title,
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
                  heroTag: heroTag,
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

  Future<void> _share(BuildContext context, WidgetRef ref, ItemModel item) async {
    final ok = await ref.read(shareServiceProvider).sharePost(context, item);
    if (!ok && context.mounted) {
      await _copyLink(context, ref, item);
    }
  }

  Future<void> _copyLink(BuildContext context, WidgetRef ref, ItemModel item) async {
    final text = item.shareUrl.isNotEmpty
        ? item.shareUrl
        : ref.read(shareServiceProvider).postText(item);
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ActionFeedback.showInfo(
        context,
        item.shareUrl.isNotEmpty ? context.l10n.postLinkCopied : context.l10n.postDetailsCopied);
  }

  Future<void> _toggleSaved(BuildContext context, WidgetRef ref, ItemModel item) async {
    final result = await ref.read(savedItemsProvider.notifier).toggleSaved(item);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (saved) => ActionFeedback.showSuccess(
        context,
        saved ? context.l10n.postSavedToList : context.l10n.postRemovedFromSaved,
      ),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  // ── More sheet ─────────────────────────────────────────────────────────────
  void _showMoreSheet(BuildContext context, WidgetRef ref, ItemModel item, bool isOwner) {
    final l10n = context.l10n;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: isOwner ? l10n.postManageSheetTitle : l10n.postMoreSheetTitle,
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetOption(
              icon: Icons.ios_share_rounded,
              label: l10n.commonShare,
              subtitle: l10n.postShareSubtitle,
              onTap: () {
                Navigator.pop(sheetCtx);
                _share(context, ref, item);
              },
            ),
            SheetOption(
              icon: Icons.link_rounded,
              label: l10n.postCopyLink,
              onTap: () {
                Navigator.pop(sheetCtx);
                _copyLink(context, ref, item);
              },
            ),
            if (isOwner) ...[
              if (!item.isResolved)
                SheetOption(
                  icon: Icons.edit_outlined,
                  label: l10n.postEditPost,
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
                    : Icons.assignment_turned_in_outlined,
                label: item.isResolved ? l10n.postReopenPost : l10n.commonMarkAsReturned,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  item.isResolved
                      ? _reopen(context, ref, item)
                      : _resolve(context, ref, item);
                },
              ),
              SheetOption(
                icon: Icons.delete_outline_rounded,
                label: l10n.postDeletePost,
                destructive: true,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmDelete(context, ref, item);
                },
              ),
            ] else ...[
              SheetOption(
                icon: Icons.flag_outlined,
                label: l10n.postReportPost,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _report(context, ref, item);
                },
              ),
              if (!item.ownerIsAdmin)
                SheetOption(
                  icon: Icons.block_rounded,
                  label: l10n.postBlockThisMember,
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
        ActionFeedback.showSuccess(context, context.l10n.commonMarkedAsReturned);
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
        ActionFeedback.showSuccess(context, context.l10n.postActiveAgain);
      },
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ItemModel item) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.postDeleteTitle),
        content: Text(l10n.postDeleteBody(item.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
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
                  ActionFeedback.showSuccess(context, l10n.postDeleted);
                  Navigator.pop(context);
                },
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _report(BuildContext context, WidgetRef ref, ItemModel item) async {
    final l10n = context.l10n;
    // The reason sent to the API stays English; only the label is translated.
    const reasons = [
      'Spam or scam',
      'Inappropriate content',
      'Wrong or misleading information',
      'Something else',
    ];
    final reason = await AppBottomSheet.show<String>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: l10n.postReportSheetTitle,
        subtitle: l10n.postReportSheetSubtitle,
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in reasons)
              SheetOption(
                icon: Icons.flag_outlined,
                label: _reportReasonLabel(l10n, r),
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
      ActionFeedback.showSuccess(context, l10n.postReported);
    } catch (e) {
      if (!context.mounted) return;
      ActionFeedback.showError(context, describeError(e));
    }
  }

  static String _reportReasonLabel(AppLocalizations l10n, String reason) {
    switch (reason) {
      case 'Spam or scam':
        return l10n.postReportReasonSpam;
      case 'Inappropriate content':
        return l10n.postReportReasonInappropriate;
      case 'Wrong or misleading information':
        return l10n.postReportReasonMisleading;
      default:
        return l10n.postReportReasonOther;
    }
  }

  void _confirmBlock(BuildContext context, WidgetRef ref, ItemModel item) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;
    final name = (item.ownerName?.isNotEmpty ?? false) ? item.ownerName! : l10n.postThisMember;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.postBlockTitle(name)),
        content: Text(l10n.postBlockBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
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
                  ActionFeedback.showSuccess(context, l10n.postBlocked(name));
                  Navigator.pop(context);
                },
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: Text(l10n.commonBlock),
          ),
        ],
      ),
    );
  }

  // ── Detail rows card ────────────────────────────────────────────────────────
  Widget _buildDetailsCard(ItemModel item, BuildContext context, AppColorTokens t) {
    final l10n = context.l10n;
    return SurfaceCard(
      padding: const EdgeInsets.all(BeaconSpace.sm),
      child: Column(
        children: [
          _detailRow(
            context,
            icon: categoryIcon(item.category),
            label: l10n.postCategory,
            value: item.category.isEmpty ? null : AppCategories.label(l10n, item.category),
          ),
          _detailRow(
            context,
            icon: Icons.calendar_today_outlined,
            label: item.isLost ? l10n.postLostOn : l10n.postFoundOn,
            value: item.lostOn,
          ),
          _detailRow(
            context,
            icon: Icons.place_outlined,
            label: l10n.commonLocation,
            value: item.location.isEmpty ? null : item.location,
          ),
          const SizedBox(height: BeaconSpace.sm),
          MapPreview(
            latitude: item.latitude,
            longitude: item.longitude,
            height: 160,
            label: item.location.isEmpty ? l10n.commonLocationNotSpecified : item.location,
            onTap: item.hasCoordinates
                ? () => LocationPickerScreen.view(context, item.place!,
                    title: item.title)
                : null,
          ),
          if (item.hasCoordinates) ...[
            const SizedBox(height: BeaconSpace.sm),
            AppButton.ghost(
              label: l10n.postOpenInMaps,
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
      ActionFeedback.showError(context, context.l10n.postCouldNotOpenMaps);
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
        (value == null || value.trim().isEmpty) ? context.l10n.postNotProvided : value;
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
    final l10n = context.l10n;
    final profile = ownerProfileAsync.value;

    final ownerName = isOwner
        ? l10n.commonYou
        : (profile?.displayName ??
            ((item.ownerName?.isNotEmpty ?? false) ? item.ownerName! : l10n.commonFinderUser));
    final avatarUrl = profile?.avatarUrl.isNotEmpty == true
        ? profile!.avatarUrl
        : item.ownerAvatarUrl;
    final verified = item.isVerified || (profile?.identityVerified ?? false);
    final phone = profile?.phone ?? '';
    final memberSince = profile == null ? null : _monthYear(l10n, profile.createdAt.toDate());
    final postsCount = profile?.postsCount;

    return SurfaceCard(
      onTap: item.ownerId.isEmpty || isOwner
          ? null
          : () => Navigator.pushNamed(context, AppRoutes.userProfile, arguments: item.ownerId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.isLost ? l10n.postPostedByOwner : l10n.postPostedByFinder,
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
                    PositionedDirectional(
                      end: -2,
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
                    NameWithMarks(
                      name: ownerName,
                      verified: verified,
                      admin: item.ownerIsAdmin || (profile?.isAdmin ?? false),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    if (ownerProfileAsync.isLoading && profile == null)
                      Text(l10n.postLoadingProfile, style: text.bodySmall)
                    else if (profile == null)
                      Text(l10n.postProfileNotAvailable, style: text.bodySmall)
                    else
                      Text(
                        [
                          if (verified) l10n.postVerifiedMember,
                          if (memberSince != null) l10n.postMemberSince(memberSince),
                          if (postsCount != null) l10n.postPostsCount(postsCount),
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
                label: l10n.postPhone,
                value: phone,
                onTap: () => _launch(context, 'tel:$phone', l10n.postCouldNotOpenDialer),
              ),
            AppButton(
              label: item.isLost ? l10n.postChatWithOwner : l10n.postChatWithFinder,
              icon: Icons.chat_bubble_outline_rounded,
              size: AppButtonSize.medium,
              onPressed: () => _startChat(context, ref, item, profile),
            ),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: BeaconSpace.md),
              AppButton.secondary(
                label: l10n.postCall,
                icon: Icons.phone_outlined,
                size: AppButtonSize.medium,
                onPressed: () => _launch(context, 'tel:$phone', l10n.postCouldNotOpenDialer),
              ),
            ] else ...[
              const SizedBox(height: BeaconSpace.sm),
              Text(
                l10n.postPhoneNotShared,
                style: text.bodySmall,
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _monthYear(AppLocalizations l10n, DateTime d) =>
      l10n.postMonthYear(l10n.commonMonthShort('${d.month}'), d.year);

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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOwner ? l10n.postOwnerActions : l10n.postSafety,
          style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
        ),
        const SizedBox(height: BeaconSpace.sm),
        Wrap(
          spacing: BeaconSpace.sm,
          runSpacing: BeaconSpace.sm,
          children: [
            if (!isOwner) ...[
              AppButton.ghost(
                label: l10n.postReportPost,
                icon: Icons.flag_outlined,
                onPressed: () => _report(context, ref, item),
              ),
              AppButton.ghost(
                label: l10n.postBlockMember,
                icon: Icons.block_rounded,
                onPressed: () => _confirmBlock(context, ref, item),
              ),
            ] else ...[
              if (!item.isResolved)
                AppButton.tonal(
                  label: l10n.commonEdit,
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
                label: item.isResolved ? l10n.commonReopen : l10n.commonMarkAsReturned,
                icon: item.isResolved
                    ? Icons.replay_rounded
                    : Icons.assignment_turned_in_outlined,
                size: AppButtonSize.medium,
                expand: false,
                onPressed: () => item.isResolved
                    ? _reopen(context, ref, item)
                    : _resolve(context, ref, item),
              ),
              AppButton.danger(
                label: l10n.postDeletePost,
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
  Widget _buildMatchesSection(BuildContext context, WidgetRef ref, ItemModel item) {
    final matches = ref.watch(postMatchesProvider(item.id));
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.postPossibleMatches,
          eyebrow: item.isLost
              ? l10n.postMatchesEyebrowLost
              : l10n.postMatchesEyebrowFound,
          actionLabel: l10n.commonRefresh,
          onAction: () => ref.invalidate(postMatchesProvider(item.id)),
        ),
        matches.when(
          loading: () => const LoadingWidget(variant: LoadingVariant.rows, skeletonCount: 1),
          error: (err, _) => ErrorStateWidget(
            message: describeError(err),
            onRetry: () => ref.invalidate(postMatchesProvider(item.id)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return SurfaceCard(
                tone: SurfaceTone.low,
                child: Row(
                  children: [
                    Icon(Icons.radar_rounded, color: t.primary),
                    const SizedBox(width: BeaconSpace.md),
                    Expanded(
                      child: Text(
                        item.isLost ? l10n.postNoMatchesLost : l10n.postNoMatchesFound,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.onSurfaceVar),
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: BeaconSpace.md),
                itemBuilder: (context, index) => SimilarCard(
                  item: items[index],
                  heroScope: '${HeroTags.similar}-${item.id}',
                  matchedPostId: item.id,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSimilarSection(BuildContext context, WidgetRef ref, ItemModel item) {
    final similarState = ref.watch(similarItemsProvider(item.id));
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.postSimilarItems,
          eyebrow: item.isLost ? l10n.postSimilarEyebrowLost : l10n.postSimilarEyebrowFound,
          actionLabel: l10n.postViewAll,
          onAction: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        similarState.when(
          loading: () => LoadingWidget(message: l10n.postLoadingSimilar),
          error: (err, _) => ErrorStateWidget(
            message: describeError(err),
            onRetry: () => ref.invalidate(similarItemsProvider(item.id)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return EmptyWidget(
                icon: Icons.radar_rounded,
                title: l10n.postNoSimilarTitle,
                subtitle: l10n.postNoSimilarSubtitle,
              );
            }
            return SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: BeaconSpace.md),
                itemBuilder: (context, index) => SimilarCard(
                  item: items[index],
                  heroScope: '${HeroTags.similar}-${item.id}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Shown when the post was opened from a "possible match" notification.
class _MatchBanner extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onChat;
  const _MatchBanner({required this.item, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: BeaconSpace.sm, bottom: BeaconSpace.lg),
      child: SurfaceCard(
        tone: SurfaceTone.primary,
        padding: const EdgeInsets.all(BeaconSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar_rounded, color: t.primary),
                const SizedBox(width: BeaconSpace.sm),
                Expanded(
                  child: Text(
                    item.isLost ? l10n.postMatchBannerTitleLost : l10n.postMatchBannerTitleFound,
                    style: text.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BeaconSpace.xs),
            Text(
              item.isLost ? l10n.postMatchBannerBodyLost : l10n.postMatchBannerBodyFound,
              style: text.bodySmall?.copyWith(color: t.onSurfaceVar),
            ),
            const SizedBox(height: BeaconSpace.md),
            AppButton(
              label: item.isLost ? l10n.postMessageOwner : l10n.postMessageFinder,
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: onChat,
            ),
          ],
        ),
      ),
    );
  }
}
