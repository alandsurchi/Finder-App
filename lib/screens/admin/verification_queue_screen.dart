import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/admin/admin_service.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/screens/admin/verification_review_screen.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Admin: identity verification requests, newest first.
class VerificationQueueScreen extends ConsumerStatefulWidget {
  const VerificationQueueScreen({super.key});

  @override
  ConsumerState<VerificationQueueScreen> createState() =>
      _VerificationQueueScreenState();
}

class _VerificationQueueScreenState
    extends ConsumerState<VerificationQueueScreen> {
  static const _statuses = ['pending', 'approved', 'rejected'];
  int _tab = 0;

  String get _status => _statuses[_tab];

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final queue = ref.watch(adminVerificationQueueProvider(_status));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(
              title: 'Review queue',
              subtitle: 'Identity verification requests',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
              child: SegmentedPills(
                options: const ['Pending', 'Approved', 'Rejected'],
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: BeaconSpace.lg),
            Expanded(
              child: queue.when(
                loading: () => const LoadingWidget(variant: LoadingVariant.rows),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () =>
                      ref.invalidate(adminVerificationQueueProvider(_status)),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyWidget(
                      icon: Icons.verified_user_outlined,
                      title: _tab == 0 ? 'Nothing to review' : 'No requests here',
                      subtitle: _tab == 0
                          ? 'New verification requests will show up here.'
                          : null,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(adminVerificationQueueProvider(_status)),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(BeaconSpace.page, 0,
                          BeaconSpace.page, BeaconSpace.xxl),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: BeaconSpace.md),
                      itemBuilder: (context, i) {
                        final r = items[i];
                        return SurfaceCard(
                          onTap: () => _open(r),
                          child: Row(
                            children: [
                              AppAvatar(url: r.avatarUrl, name: r.userName, size: 44),
                              const SizedBox(width: BeaconSpace.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.userName,
                                        style: text.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(r.email,
                                        style: text.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: BeaconSpace.xs),
                                    Text(
                                      '${r.docLabel} · ${relativeTime(r.createdAtMs)}',
                                      style: text.labelSmall
                                          ?.copyWith(color: t.onSurfaceMuted),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: BeaconSpace.sm),
                              _badge(r),
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

  Widget _badge(AdminVerificationRequest r) => switch (r.status) {
        'approved' => StatusBadge.verified(),
        'rejected' => StatusBadge.custom(
            label: 'REJECTED',
            color: AppColorTokens.of(context).error,
            icon: Icons.close_rounded,
            small: true,
          ),
        _ => StatusBadge.neutral('PENDING', small: true),
      };

  Future<void> _open(AdminVerificationRequest r) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => VerificationReviewScreen(request: r)),
    );
    if (changed == true && mounted) {
      for (final s in _statuses) {
        ref.invalidate(adminVerificationQueueProvider(s));
      }
    }
  }
}
