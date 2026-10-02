import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/screens/admin/admin_posts_screen.dart';
import 'package:finder/screens/admin/ai_settings_sheet.dart';
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
    final l10n = context.l10n;
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
              title: l10n.adminConsoleTitle,
              subtitle: l10n.adminConsoleSubtitle,
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: BeaconSpace.sm),
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
                    Text(l10n.adminModeration, style: text.titleMedium),
                    const SizedBox(height: BeaconSpace.md),
                    SettingsGroup(
                      children: [
                        SettingsTile(
                          icon: Icons.people_alt_outlined,
                          title: l10n.adminUsersTitle,
                          subtitle: l10n.adminUsersTileSubtitle,
                          trailing: _count(stats.value?.users, t),
                          onTap: () => open(const AdminUsersScreen()),
                        ),
                        SettingsTile(
                          icon: Icons.inventory_2_outlined,
                          title: l10n.commonPosts,
                          subtitle: l10n.adminPostsTileSubtitle,
                          trailing: _count(stats.value?.pendingPosts, t, highlight: true),
                          onTap: () => open(const AdminPostsScreen(initialStatus: 'pending')),
                        ),
                        SettingsTile(
                          icon: Icons.flag_outlined,
                          title: l10n.adminReportsTitle,
                          subtitle: l10n.adminReportsSubtitle,
                          trailing: _count(stats.value?.pendingReports, t,
                              highlight: true),
                          onTap: () => open(const AdminReportsScreen()),
                        ),
                        SettingsTile(
                          icon: Icons.verified_user_outlined,
                          title: l10n.adminVerificationTitle,
                          subtitle: l10n.adminVerificationTileSubtitle,
                          trailing: _count(stats.value?.pendingVerifications, t,
                              highlight: true),
                          onTap: () => open(const VerificationQueueScreen()),
                        ),
                        SettingsTile(
                          icon: Icons.auto_awesome_outlined,
                          title: l10n.adminAiTitle,
                          subtitle: l10n.adminAiSubtitle,
                          onTap: () => showAiSettingsSheet(context, ref),
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
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    final cells = [
      (l10n.adminStatMembers, stats.users, Icons.people_alt_outlined, t.primary),
      (l10n.adminVerifiedLabel, stats.verifiedUsers, Icons.verified_rounded, t.primary),
      (l10n.adminStatToApprove, stats.pendingPosts, Icons.rule_folder_outlined, t.accent),
      (l10n.adminStatRejected, stats.rejectedPosts, Icons.block_rounded, t.error),
      (l10n.adminStatOpenPosts, stats.openPosts, Icons.inventory_2_outlined, t.lost),
      (l10n.commonReturned, stats.returnedPosts, Icons.assignment_turned_in_rounded, t.found),
      (l10n.adminReportsTitle, stats.pendingReports, Icons.flag_outlined, t.accent),
      (l10n.adminStatToVerify, stats.pendingVerifications, Icons.verified_user_outlined, t.accent),
      (l10n.adminSuspendedLabel, stats.bannedUsers, Icons.block_rounded, t.error),
      (l10n.adminStatMessages24h, stats.messagesToday, Icons.chat_bubble_outline_rounded, t.primary),
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
