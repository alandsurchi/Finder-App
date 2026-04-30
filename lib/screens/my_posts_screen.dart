import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/routes.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/screens/edit_post_screen.dart';

class MyPostsScreen extends ConsumerStatefulWidget {
  const MyPostsScreen({Key? key}) : super(key: key);

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
    final t = AppColorTokens.of(context);
    final postsAsync = ref.watch(myPostsProvider);

    final allItems = postsAsync.value ?? [];
    final filtered = _tabIndex == 0
        ? allItems.where((p) => !p.isResolved).toList()
        : allItems.where((p) => p.isResolved).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPost).then(
          (_) => ref.read(myPostsProvider.notifier).load(),
        ),
        backgroundColor: t.primary,
        elevation: 4,
        child: Icon(
          Icons.add,
          color: t.isDark ? Colors.black : Colors.white,
          size: 26,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'My Posts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                    onPressed: () => ref.read(myPostsProvider.notifier).load(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: t.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildTab(0, 'Active', t),
                    _buildTab(1, 'Resolved', t),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ──
            Expanded(
              child: postsAsync.when(
                loading: () => const LoadingWidget(message: 'Loading posts...'),
                error: (err, _) => ErrorStateWidget(message: err.toString()),
                data: (_) {
                  if (filtered.isEmpty) {
                    return EmptyWidget(
                      title: _tabIndex == 0 ? 'No active posts' : 'No resolved posts',
                      subtitle: _tabIndex == 0
                          ? 'Tap + to create your first post.'
                          : 'Posts you mark as resolved will appear here.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
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

  Widget _buildTab(int index, String label, AppColorTokens t) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? t.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : t.onSurfaceMuted,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
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

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: post.isResolved ? t.success.withOpacity(0.4) : t.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          if (post.imagePath.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                post.imagePath,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: t.surfaceHigh,
                  child: Center(
                    child: Icon(
                      post.isLost
                          ? Icons.search_rounded
                          : Icons.back_hand_rounded,
                      color: t.onSurfaceMuted,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + badges ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: TextStyle(
                          color: post.isResolved ? t.onSurfaceMuted : t.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: post.isResolved
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _typeBadge(post.isLost ? 'LOST' : 'FOUND',
                        post.isLost ? t.error : t.success, t),
                    if (post.isResolved) ...[
                      const SizedBox(width: 4),
                      _typeBadge('RESOLVED', t.success, t),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                // ── Description ──
                Text(
                  post.description,
                  style: TextStyle(color: t.onSurfaceVar, fontSize: 12, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // ── Meta row ──
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: t.onSurfaceMuted, size: 13),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        post.location.isEmpty ? 'No location' : post.location,
                        style:
                            TextStyle(color: t.onSurfaceMuted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.lostOn != null && post.lostOn!.isNotEmpty) ...[
                      Icon(Icons.calendar_today_outlined,
                          color: t.onSurfaceMuted, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        post.lostOn!,
                        style:
                            TextStyle(color: t.onSurfaceMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // ── Action buttons ──
                Row(
                  children: [
                    // View button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.itemDetails,
                          arguments: post,
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 14),
                        label: const Text('View',
                            style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: t.primary,
                          side: BorderSide(color: t.primary.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit button
                    if (!post.isResolved)
                      Expanded(
                        child: OutlinedButton.icon(
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
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          label: const Text('Edit',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFEA619),
                            side: const BorderSide(
                                color: Color(0xFFFEA619), width: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Resolve button (only if not yet resolved)
                    if (!post.isResolved)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _confirmResolve(context, ref, post),
                          icon: const Icon(Icons.check_circle_outline,
                              size: 14),
                          label: const Text('Resolve',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: t.success,
                            side: BorderSide(
                                color: t.success.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Delete button
                    OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, ref, post),
                      icon: const Icon(Icons.delete_outline, size: 14),
                      label: const Text('Delete',
                          style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.error,
                        side: BorderSide(color: t.error.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String label, Color color, AppColorTokens t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  void _confirmResolve(
      BuildContext context, WidgetRef ref, ItemModel post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Resolved?'),
        content: Text(
            'Mark "${post.title}" as resolved? This will strikethrough the title and move it to the Resolved tab.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(myPostsProvider.notifier).markResolved(post.id);
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ItemModel post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post?'),
        content: Text(
            'Are you sure you want to delete "${post.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(myPostsProvider.notifier).deletePost(post.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
