import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/providers/post_provider.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Admin: posts flagged by members.
class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  static const _statuses = ['pending', 'resolved'];
  int _tab = 0;

  void _refresh() {
    for (final s in _statuses) {
      ref.invalidate(adminReportsProvider(s));
    }
    ref.invalidate(adminStatsProvider);
    ref.invalidate(postsStreamProvider);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final reports = ref.watch(adminReportsProvider(_statuses[_tab]));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'Reports', subtitle: 'Posts flagged by members'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
              child: SegmentedPills(
                options: const ['Open', 'Handled'],
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: BeaconSpace.lg),
            Expanded(
              child: reports.when(
                loading: () => const LoadingWidget(variant: LoadingVariant.rows),
                error: (e, _) => ErrorStateWidget(message: describeError(e), onRetry: _refresh),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyWidget(
                      icon: Icons.flag_outlined,
                      title: _tab == 0 ? 'No open reports' : 'Nothing handled yet',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.xxl),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.md),
                      itemBuilder: (context, i) {
                        final r = items[i];
                        return SurfaceCard(
                          onTap: r.isPending ? () => _showActions(r) : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.flag_rounded, color: t.accent, size: 18),
                                  const SizedBox(width: BeaconSpace.sm),
                                  Expanded(
                                    child: Text(r.postTitle,
                                        style: text.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: BeaconSpace.sm),
                                  if (r.isPending)
                                    StatusBadge.custom(label: 'OPEN', color: t.accent, small: true)
                                  else
                                    StatusBadge.neutral(
                                        (r.resolution ?? 'handled').toUpperCase(),
                                        small: true),
                                ],
                              ),
                              const SizedBox(height: BeaconSpace.xs),
                              Text(
                                r.reason.isEmpty ? 'No reason given' : '"${r.reason}"',
                                style: text.bodyMedium,
                              ),
                              const SizedBox(height: BeaconSpace.xs),
                              Text(
                                'Reported by ${r.reporterName} · ${relativeTime(r.createdAtMs)}'
                                '${r.postOwnerName.isNotEmpty ? ' · post by ${r.postOwnerName}' : ''}',
                                style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                              ),
                            ],
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

  void _showActions(AdminReport r) {
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: r.postTitle,
        subtitle: r.reason.isEmpty ? null : '"${r.reason}"',
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (r.postId.isNotEmpty)
              SheetOption(
                icon: Icons.open_in_new_rounded,
                label: 'Open the post',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  try {
                    final post = await ref.read(postServiceProvider).fetchById(r.postId);
                    if (!mounted) return;
                    Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: post);
                  } catch (e) {
                    if (mounted) ActionFeedback.showError(context, describeError(e));
                  }
                },
              ),
            SheetOption(
              icon: Icons.check_circle_outline_rounded,
              label: 'Dismiss the report',
              subtitle: 'The post stays up',
              onTap: () => _resolve(sheetCtx, r, removePost: false),
            ),
            SheetOption(
              icon: Icons.delete_outline_rounded,
              label: 'Remove the post',
              subtitle: 'Settles every report on it; the owner is notified',
              destructive: true,
              onTap: () => _resolve(sheetCtx, r, removePost: true),
            ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _resolve(BuildContext sheetCtx, AdminReport r, {required bool removePost}) async {
    Navigator.pop(sheetCtx);
    if (removePost) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove this post?'),
          content: Text('"${r.postTitle}" and its chats are deleted. This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    try {
      await ref.read(adminConsoleServiceProvider).resolveReport(r.id, removePost: removePost);
      if (!mounted) return;
      ActionFeedback.showSuccess(context, removePost ? 'Post removed.' : 'Report dismissed.');
      _refresh();
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, describeError(e));
    }
  }
}
