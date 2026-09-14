import 'package:flutter/material.dart';
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
        label: const Text('New post'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'My posts',
              subtitle: postsAsync.hasValue
                  ? '$active open · $resolved returned'
                  : null,
              actions: [
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Refresh',
                  onPressed: () => ref.read(myPostsProvider.notifier).load(),
                ),
              ],
            ),

            // ── Tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
              child: SegmentedPills(
                options: const ['Open', 'Returned'],
                selectedIndex: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),

            const SizedBox(height: BeaconSpace.lg),

            // ── Content ──
            Expanded(
              child: postsAsync.when(
                loading: () => const LoadingWidget(
                  message: 'Loading posts...',
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
                      title: _tabIndex == 0 ? 'No open posts' : 'No returned items yet',
                      subtitle: _tabIndex == 0
                          ? 'Create your first post to get started.'
                          : 'Posts you mark as returned will appear here.',
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

    return ItemCard(
      item: post,
      layout: ItemCardLayout.row,
      heroTag: 'item-image-${post.id}',
      showDescription: false,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.itemDetails,
        arguments: post,
      ),
      footer: Wrap(
        spacing: BeaconSpace.sm,
        runSpacing: BeaconSpace.sm,
        children: [
          if (!post.isResolved)
            AppButton.tonal(
              label: 'Edit',
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
              label: 'Returned',
              icon: Icons.check_circle_outline_rounded,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () => _confirmResolve(context, ref, post),
            )
          else
            AppButton.tonal(
              label: 'Reopen',
              icon: Icons.replay_rounded,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () async {
                final result =
                    await ref.read(myPostsProvider.notifier).reopen(post.id);
                if (!context.mounted) return;
                result.fold(
                  onSuccess: (_) => ActionFeedback.showSuccess(context, 'Post is active again.'),
                  onFailure: (f) => ActionFeedback.showError(context, f.message),
                );
              },
            ),
          AppIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete post',
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as returned?'),
        content: Text(
            'Mark "${post.title}" as returned? It leaves the Home feed but stays visible in Search.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result =
                  await ref.read(myPostsProvider.notifier).markResolved(post.id);
              if (!context.mounted) return;
              result.fold(
                onSuccess: (_) => ActionFeedback.showSuccess(context, 'Marked as returned.'),
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: const Text('Mark as returned'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ItemModel post) {
    final t = AppColorTokens.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text(
            'Are you sure you want to delete "${post.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
                onSuccess: (_) => ActionFeedback.showSuccess(context, 'Post deleted.'),
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
