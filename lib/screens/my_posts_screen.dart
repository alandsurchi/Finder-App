import 'package:flutter/material.dart';
import 'package:finder/core/utils/hero_tags.dart';
import 'package:finder/features/posts/presentation/item_details_args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/routes.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/screens/edit_post_screen.dart';
import 'package:finder/l10n/l10n.dart';

class MyPostsScreen extends ConsumerStatefulWidget {
  const MyPostsScreen({super.key});

  @override
  ConsumerState<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends ConsumerState<MyPostsScreen> {
  int _tabIndex = 0; // 0 = Active, 1 = Resolved

  @override
  void initState() {
    super.initState();
    // Refresh every time the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myPostsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(myPostsProvider);
    final l10n = context.l10n;

    final allItems = postsAsync.value ?? [];
    final active = allItems.where((p) => !p.isResolved).length;
    final resolved = allItems.length - active;
    final filtered = _tabIndex == 0
        ? allItems.where((p) => !p.isResolved).toList()
        : allItems.where((p) => p.isResolved).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPost).then(
          (_) => ref.read(myPostsProvider.notifier).load(),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.postNewPost),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: l10n.postMyPosts,
              subtitle: postsAsync.hasValue
                  ? l10n.postOpenReturnedCount(active, resolved)
                  : null,
              actions: [
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: l10n.commonRefresh,
                  onPressed: () => ref.read(myPostsProvider.notifier).load(),
                ),
              ],
            ),

            // ── Tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
              child: SegmentedPills(
                options: [l10n.commonOpen, l10n.commonReturned],
                selectedIndex: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),

            const SizedBox(height: BeaconSpace.lg),

            // ── Content ──
            Expanded(
              child: postsAsync.when(
                loading: () => LoadingWidget(
                  message: l10n.homeLoadingPosts,
                  variant: LoadingVariant.rows,
                ),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () => ref.read(myPostsProvider.notifier).load(),
                ),
                data: (_) {
                  if (filtered.isEmpty) {
                    return EmptyWidget(
                      icon: _tabIndex == 0
                          ? Icons.post_add_rounded
                          : Icons.task_alt_rounded,
                      title: _tabIndex == 0 ? l10n.postNoOpenPosts : l10n.postNoReturnedYet,
                      subtitle: _tabIndex == 0
                          ? l10n.postCreateYourFirst
                          : l10n.postReturnedAppearHere,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        BeaconSpace.page, 0, BeaconSpace.page, 120),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.lg),
                    itemBuilder: (context, index) {
                      return StaggeredEntrance(
                        index: index.clamp(0, 6),
                        child: _PostManageCard(post: filtered[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Individual post management card ───────────────────────────────────────────
class _PostManageCard extends ConsumerWidget {
  final ItemModel post;
  const _PostManageCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;

    return ItemCard(
      item: post,
      layout: ItemCardLayout.row,
      heroTag: HeroTags.item(HeroTags.myPosts, post.id),
      showDescription: false,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.itemDetails,
        arguments: ItemDetailsArgs(post, heroTag: HeroTags.item(HeroTags.myPosts, post.id)),
      ),
      footer: Wrap(
        spacing: BeaconSpace.sm,
        runSpacing: BeaconSpace.sm,
        children: [
          if (!post.isResolved)
            AppButton.tonal(
              label: l10n.commonEdit,
              icon: Icons.edit_outlined,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPostScreen(post: post),
                  ),
                );
                // Refresh list after returning from edit
                ref.read(myPostsProvider.notifier).load();
              },
            ),
          if (!post.isResolved)
            AppButton.secondary(
              label: l10n.commonReturned,
              icon: Icons.check_circle_outline_rounded,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () => _confirmResolve(context, ref, post),
            )
          else
            AppButton.tonal(
              label: l10n.commonReopen,
              icon: Icons.replay_rounded,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () async {
                final result =
                    await ref.read(myPostsProvider.notifier).reopen(post.id);
                if (!context.mounted) return;
                result.fold(
                  onSuccess: (_) => ActionFeedback.showSuccess(context, l10n.postActiveAgain),
                  onFailure: (f) => ActionFeedback.showError(context, f.message),
                );
              },
            ),
          AppIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: l10n.postDeletePost,
            size: 36,
            iconSize: 18,
            variant: AppIconButtonVariant.tonal,
            background: t.errorSurface,
            color: t.error,
            onPressed: () => _confirmDelete(context, ref, post),
          ),
        ],
      ),
    );
  }

  void _confirmResolve(
      BuildContext context, WidgetRef ref, ItemModel post) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.postMarkReturnedTitle),
        content: Text(l10n.postMarkReturnedBody(post.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result =
                  await ref.read(myPostsProvider.notifier).markResolved(post.id);
              if (!context.mounted) return;
              result.fold(
                onSuccess: (_) => ActionFeedback.showSuccess(context, l10n.commonMarkedAsReturned),
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: Text(l10n.commonMarkAsReturned),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ItemModel post) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.postDeleteTitle),
        content: Text(l10n.postDeleteBodyConfirm(post.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: t.error,
              foregroundColor: t.onError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final result =
                  await ref.read(myPostsProvider.notifier).deletePost(post.id);
              if (!context.mounted) return;
              result.fold(
                onSuccess: (_) => ActionFeedback.showSuccess(context, l10n.postDeleted),
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }
}
