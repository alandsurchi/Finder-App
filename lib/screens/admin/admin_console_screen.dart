import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/screens/admin/admin_posts_screen.dart';
import 'package:finder/screens/admin/admin_reports_screen.dart';
import 'package:finder/screens/admin/admin_users_screen.dart';
import 'package:finder/screens/admin/verification_queue_screen.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/identity_marks.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Admin console home: live numbers and the four moderation areas.
class AdminConsoleScreen extends ConsumerWidget {
  const AdminConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final stats = ref.watch(adminStatsProvider);

    void open(Widget screen) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ).then((_) => ref.invalidate(adminStatsProvider));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Admin console',
              subtitle: 'Users, posts, reports and verification',
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: BeaconSpace.sm),
                  child: adminBadge(small: false),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(adminStatsProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.xxl),
                  children: [
                    stats.when(
                      loading: () => const LoadingWidget(variant: LoadingVariant.rows, skeletonCount: 2),
                      error: (e, _) => ErrorStateWidget(
                        message: describeError(e),
                        onRetry: () => ref.invalidate(adminStatsProvider),
                      ),
                      data: (s) => _StatsGrid(stats: s),
                    ),
                    const SizedBox(height: BeaconSpace.xl),
                    Text('Moderation', style: text.titleMedium),
                    const SizedBox(height: BeaconSpace.md),
                    SettingsGroup(
                      children: [
                        SettingsTile(
                          icon: Icons.people_alt_outlined,
                          title: 'Users',
                          subtitle: 'Search, verify, suspend, promote or delete accounts',
                          trailing: _count(stats.value?.users, t),
                          onTap: () => open(const AdminUsersScreen()),
                        ),
                        SettingsTile(
                          icon: Icons.inventory_2_outlined,
                          title: 'Posts',
                          subtitle: 'Every lost and found post, open or returned',
                          trailing: _count(stats.value?.posts, t),
                          onTap: () => open(const AdminPostsScreen()),
                        ),
                        SettingsTile(
                          icon: Icons.flag_outlined,
                          title: 'Reports',
                          subtitle: 'Posts flagged by members',
                          trailing: _count(stats.value?.pendingReports, t,
                              highlight: true),
                          onTap: () => open(const AdminReportsScreen()),
                        ),
                        SettingsTile(
                          icon: Icons.verified_user_outlined,
                          title: 'Identity verification',
                          subtitle: 'Review documents and selfies',
                          trailing: _count(stats.value?.pendingVerifications, t,
                              highlight: true),
                          onTap: () => open(const VerificationQueueScreen()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _count(int? n, AppColorTokens t, {bool highlight = false}) {
    if (n == null) return null;
    if (highlight && n > 0) {
      return StatusBadge.custom(label: '$n', color: t.accent, small: true);
    }
    return StatusBadge.neutral('$n', small: true);
  }
}

class _StatsGrid extends StatelessWidget {
  final AdminStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final cells = [
      ('Members', stats.users, Icons.people_alt_outlined, t.primary),
      ('Verified', stats.verifiedUsers, Icons.verified_rounded, t.primary),
      ('Open posts', stats.openPosts, Icons.inventory_2_outlined, t.lost),
      ('Returned', stats.returnedPosts, Icons.assignment_turned_in_rounded, t.found),
      ('Reports', stats.pendingReports, Icons.flag_outlined, t.accent),
      ('To verify', stats.pendingVerifications, Icons.verified_user_outlined, t.accent),
      ('Suspended', stats.bannedUsers, Icons.block_rounded, t.error),
      ('Messages 24h', stats.messagesToday, Icons.chat_bubble_outline_rounded, t.primary),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: BeaconSpace.md,
      crossAxisSpacing: BeaconSpace.md,
      childAspectRatio: 1.9,
      children: [
        for (final c in cells) _StatTile(label: c.$1, value: c.$2, icon: c.$3, color: c.$4),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SurfaceCard(
      padding: const EdgeInsets.all(BeaconSpace.md),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: BeaconSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value', style: text.titleLarge),
                Text(label, style: text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
