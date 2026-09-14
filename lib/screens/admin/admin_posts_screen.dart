import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/providers/post_provider.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/identity_marks.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Admin: every post with moderation actions.
class AdminPostsScreen extends ConsumerStatefulWidget {
  final String initialStatus;
  const AdminPostsScreen({super.key, this.initialStatus = 'all'});

  @override
  ConsumerState<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends ConsumerState<AdminPostsScreen> {
  static const _statuses = ['all', 'active', 'resolved', 'reported'];
  final _search = TextEditingController();
  Timer? _debounce;
  late int _tab = _statuses.indexOf(widget.initialStatus).clamp(0, 3);
  String _query = '';

  String get _key => '${_statuses[_tab]}|$_query';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQuery(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  void _refresh() {
    for (final s in _statuses) {
      ref.invalidate(adminPostsProvider('$s|$_query'));
    }
    ref.invalidate(adminStatsProvider);
    ref.invalidate(postsStreamProvider);
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(adminPostsProvider(_key));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'Posts', subtitle: 'Everything on the feed'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
              child: Column(
                children: [
                  SearchField(
                    controller: _search,
                    hint: 'Title, description, owner',
                    onChanged: _onQuery,
                  ),
                  const SizedBox(height: BeaconSpace.md),
                  SegmentedPills(
                    options: const ['All', 'Open', 'Returned', 'Reported'],
                    selectedIndex: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BeaconSpace.lg),
            Expanded(
              child: posts.when(
                loading: () => const LoadingWidget(variant: LoadingVariant.rows),
                error: (e, _) => ErrorStateWidget(message: describeError(e), onRetry: _refresh),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyWidget(icon: Icons.inventory_2_outlined, title: 'No posts here');
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.xxl),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.md),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return ItemCard(
                          item: item,
                          layout: ItemCardLayout.row,
                          onTap: () => _showActions(item),
                          subtitle: NameWithMarks(
                            name: item.ownerName ?? 'Finder User',
                            verified: item.isVerified,
                            admin: item.ownerIsAdmin,
                            style: Theme.of(context).textTheme.labelSmall,
                            markSize: 14,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(ItemModel item) {
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: item.title,
        subtitle: 'by ${item.ownerName ?? 'Finder User'} · ${item.isResolved ? 'returned' : 'open'}',
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetOption(
              icon: Icons.open_in_new_rounded,
              label: 'Open the post',
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: item);
              },
            ),
            SheetOption(
              icon: item.isResolved ? Icons.replay_rounded : Icons.assignment_turned_in_outlined,
              label: item.isResolved ? 'Reopen the post' : 'Mark as returned',
              onTap: () => _run(
                sheetCtx,
                () => ref.read(adminConsoleServiceProvider).setPostStatus(
                    item.id, item.isResolved ? 'active' : 'resolved'),
                item.isResolved ? 'Post reopened.' : 'Marked as returned.',
              ),
            ),
            SheetOption(
              icon: Icons.delete_outline_rounded,
              label: 'Remove the post',
              subtitle: 'The owner is notified with your reason',
              destructive: true,
              onTap: () async {
                Navigator.pop(sheetCtx);
                final reason = await _askReason();
                if (reason == null || !mounted) return;
                try {
                  await ref.read(adminConsoleServiceProvider).deletePost(item.id, reason: reason);
                  if (!mounted) return;
                  ActionFeedback.showSuccess(context, 'Post removed.');
                  _refresh();
                } catch (e) {
                  if (mounted) ActionFeedback.showError(context, describeError(e));
                }
              },
            ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  Future<String?> _askReason() {
    final ctrl = TextEditingController();
    return AppBottomSheet.show<String>(
      context,
      builder: (ctx) => AppBottomSheet(
        title: 'Remove this post?',
        subtitle: 'A short reason is sent to the owner.',
        actions: [
          AppButton.ghost(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
          AppButton.danger(
            label: 'Remove',
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          ),
        ],
        child: AppTextField(
          controller: ctrl,
          label: 'Reason (optional)',
          hint: 'e.g. Not a lost or found item',
          autofocus: true,
          maxLines: 3,
        ),
      ),
    );
  }

  Future<void> _run(BuildContext sheetCtx, Future<void> Function() action, String success) async {
    Navigator.pop(sheetCtx);
    try {
      await action();
      if (!mounted) return;
      ActionFeedback.showSuccess(context, success);
      _refresh();
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, describeError(e));
    }
  }
}
