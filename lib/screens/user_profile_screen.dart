import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finder/core/utils/hero_tags.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/features/chat/presentation/open_chat.dart';
import 'package:finder/features/posts/presentation/item_details_args.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/providers/post_provider.dart';
import 'package:finder/providers/user_provider.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/profile_cover.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Another member's open posts (newest first).
final userPostsProvider =
    FutureProvider.autoDispose.family<List<ItemModel>, String>((ref, userId) {
  if (userId.isEmpty) return Future.value(const []);
  return ref.read(postServiceProvider).fetchItems(ownerId: userId, limit: 50);
});

/// Public profile of another member: cover, avatar, trust marks, their
/// posts, and a Message button. Opened from chats and post owner cards.
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final userId = args is String ? args : (args is Map ? args['userId']?.toString() ?? '' : '');
    final me = ref.watch(authStateProvider).userId ?? '';
    if (userId.isNotEmpty && userId == me) {
      // My own profile lives on the Profile tab.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.profile);
      });
    }
    final profileAsync = ref.watch(userProfileProvider(userId));
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: profileAsync.when(
        loading: () => SafeArea(child: LoadingWidget(message: l10n.profileLoadingOther)),
        error: (e, _) => SafeArea(
          child: ErrorStateWidget(
            message: describeError(e),
            onRetry: () => ref.invalidate(userProfileProvider(userId)),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return SafeArea(
              child: Column(
                children: [
                  AppPageHeader(title: l10n.commonProfile),
                  Expanded(
                    child: EmptyWidget(
                      icon: Icons.person_off_outlined,
                      title: l10n.profileUnavailableTitle,
                      subtitle: l10n.profileUnavailableSubtitle,
                    ),
                  ),
                ],
              ),
            );
          }
          return _ProfileBody(profile: profile, userId: userId, t: t);
        },
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserModel profile;
  final String userId;
  final AppColorTokens t;
  const _ProfileBody({required this.profile, required this.userId, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final posts = ref.watch(userPostsProvider(userId));
    final topPad = MediaQuery.paddingOf(context).top;
    final firstName = profile.displayName.split(' ').first;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ProfileCover(url: profile.coverUrl, height: 190 + topPad),
              PositionedDirectional(
                top: topPad + BeaconSpace.sm,
                start: BeaconSpace.md,
                child: AppIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: l10n.commonBack,
                  variant: AppIconButtonVariant.glass,
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              PositionedDirectional(
                top: topPad + BeaconSpace.sm,
                end: BeaconSpace.md,
                child: AppIconButton(
                  icon: Icons.more_vert_rounded,
                  tooltip: l10n.profileMore,
                  variant: AppIconButtonVariant.glass,
                  onPressed: () => _showMore(context, ref),
                ),
              ),
              PositionedDirectional(
                start: BeaconSpace.page,
                bottom: -52,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: t.surface, shape: BoxShape.circle),
                  child: AppAvatar(url: profile.avatarUrl, name: profile.displayName, size: 104, ring: true),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(BeaconSpace.page, 60, BeaconSpace.page, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NameWithMarks(
                  name: profile.displayName,
                  verified: profile.identityVerified,
                  admin: profile.isAdmin,
                  style: text.headlineSmall,
                  markSize: 22,
                ),
                if (profile.nickName.isNotEmpty || profile.job.isNotEmpty) ...[
                  const SizedBox(height: BeaconSpace.xs),
                  Text(
                    profile.nickName.isNotEmpty ? '@${profile.nickName.toLowerCase()}' : profile.job,
                    style: text.bodyMedium?.copyWith(color: t.primary),
                  ),
                ],
                const SizedBox(height: BeaconSpace.sm),
                Wrap(
                  spacing: BeaconSpace.sm,
                  runSpacing: BeaconSpace.sm,
                  children: [
                    if (profile.identityVerified || profile.isAdmin) StatusBadge.verified(),
                    if (profile.isAdmin) adminBadge(),
                    StatusBadge.neutral(
                      l10n.profileMemberSince(
                        relativeTime(profile.createdAt.millisecondsSinceEpoch, l10n: l10n)
                            .replaceAll(' ago', ''),
                      ),
                      small: true,
                    ),
                    StatusBadge.neutral(l10n.profilePostsCount(profile.postsCount), small: true),
                  ],
                ),
                if (profile.address.isNotEmpty || (profile.job.isNotEmpty && profile.nickName.isNotEmpty)) ...[
                  const SizedBox(height: BeaconSpace.md),
                  Wrap(
                    spacing: BeaconSpace.lg,
                    runSpacing: BeaconSpace.xs,
                    children: [
                      if (profile.job.isNotEmpty && profile.nickName.isNotEmpty)
                        _Fact(icon: Icons.work_outline_rounded, label: profile.job),
                      if (profile.address.isNotEmpty)
                        _Fact(icon: Icons.place_outlined, label: profile.address),
                    ],
                  ),
                ],
                const SizedBox(height: BeaconSpace.lg),
                AppButton(
                  label: l10n.profileMessageFirstName(firstName),
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => openChatWith(
                    context,
                    ref,
                    peerId: profile.uid,
                    peerName: profile.displayName,
                    peerAvatarUrl: profile.avatarUrl,
                    peerVerified: profile.identityVerified,
                    peerAdmin: profile.isAdmin,
                  ),
                ),
                const SizedBox(height: BeaconSpace.xxl),
                SectionHeader(
                  title: l10n.commonPosts,
                  eyebrow: l10n.profileItemsReported(firstName),
                ),
              ],
            ),
          ),
        ),
        posts.when(
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(BeaconSpace.page),
              child: LoadingWidget(variant: LoadingVariant.rows, skeletonCount: 2),
            ),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: ErrorStateWidget(
              message: describeError(e),
              onRetry: () => ref.invalidate(userPostsProvider(userId)),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return SliverToBoxAdapter(
                child: EmptyWidget(icon: Icons.inventory_2_outlined, title: l10n.profileNoPosts),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.huge),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.md),
                itemBuilder: (context, i) {
                  final item = items[i];
                  final tag = HeroTags.item('${HeroTags.admin}-profile-$userId', item.id);
                  return ItemCard(
                    item: item,
                    layout: ItemCardLayout.row,
                    heroTag: tag,
                    showDescription: false,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.itemDetails,
                      arguments: ItemDetailsArgs(item, heroTag: tag),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showMore(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: profile.displayName,
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetOption(
              icon: Icons.chat_bubble_outline_rounded,
              label: l10n.profileSendMessage,
              onTap: () {
                Navigator.pop(sheetCtx);
                openChatWith(
                  context,
                  ref,
                  peerId: profile.uid,
                  peerName: profile.displayName,
                  peerAvatarUrl: profile.avatarUrl,
                  peerVerified: profile.identityVerified,
                  peerAdmin: profile.isAdmin,
                );
              },
            ),
            if (!profile.isAdmin)
              SheetOption(
                icon: Icons.block_rounded,
                label: l10n.blockUserLabel(profile.displayName),
                subtitle: l10n.blockProfileSubtitle,
                destructive: true,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.blockUserTitle(profile.displayName)),
                      content: Text(l10n.blockProfileConfirmBody),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonBlock)),
                      ],
                    ),
                  );
                  if (ok != true || !context.mounted) return;
                  final result = await ref
                      .read(blockedUsersProvider.notifier)
                      .blockUser(profile.uid, name: profile.displayName, avatarUrl: profile.avatarUrl);
                  if (!context.mounted) return;
                  result.fold(
                    onSuccess: (_) {
                      ActionFeedback.showSuccess(context, l10n.blockUserDone(profile.displayName));
                      Navigator.maybePop(context);
                    },
                    onFailure: (f) => ActionFeedback.showError(context, f.message),
                  );
                },
              )
            else
              SheetOption(
                icon: Icons.shield_rounded,
                label: l10n.profileFinderAdmin,
                subtitle: l10n.blockStaffSubtitle,
                onTap: () => Navigator.pop(sheetCtx),
              ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Fact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: t.onSurfaceMuted),
        const SizedBox(width: BeaconSpace.xs),
        Text(label, style: text.bodySmall?.copyWith(color: t.onSurfaceVar)),
      ],
    );
  }
}
