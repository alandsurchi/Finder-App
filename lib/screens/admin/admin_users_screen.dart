import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/identity_marks.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Admin: every account, with verify / suspend / promote / delete actions.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  static const _filters = ['all', 'verified', 'admins', 'banned'];
  final _search = TextEditingController();
  Timer? _debounce;
  int _tab = 0;
  String _query = '';

  String get _key => '${_filters[_tab]}|$_query';

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
    for (final f in _filters) {
      ref.invalidate(adminUsersProvider('$f|$_query'));
    }
    ref.invalidate(adminStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(adminUsersProvider(_key));
    final me = ref.watch(authStateProvider).userId ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'Users', subtitle: 'Accounts on Finder'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
              child: Column(
                children: [
                  SearchField(
                    controller: _search,
                    hint: 'Name, nickname or e-mail',
                    onChanged: _onQuery,
                  ),
                  const SizedBox(height: BeaconSpace.md),
                  SegmentedPills(
                    options: const ['All', 'Verified', 'Admins', 'Suspended'],
                    selectedIndex: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BeaconSpace.lg),
            Expanded(
              child: users.when(
                loading: () => const LoadingWidget(variant: LoadingVariant.rows),
                error: (e, _) => ErrorStateWidget(
                  message: describeError(e),
                  onRetry: _refresh,
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyWidget(
                      icon: Icons.person_search_outlined,
                      title: 'No accounts match',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.xxl),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.md),
                      itemBuilder: (context, i) => _UserRow(
                        user: items[i],
                        isMe: items[i].uid == me,
                        onTap: () => _showActions(items[i], isMe: items[i].uid == me),
                      ),
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

  void _showActions(AdminUser u, {required bool isMe}) {
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: u.name,
        subtitle: u.email,
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetOption(
              icon: u.identityVerified ? Icons.remove_circle_outline : Icons.verified_rounded,
              label: u.identityVerified ? 'Remove verified badge' : 'Mark as verified',
              subtitle: u.identityVerified
                  ? 'The tick disappears from their profile and posts'
                  : 'Grants the tick without a document review',
              onTap: () => _run(sheetCtx, () => _svc.setVerified(u.uid, !u.identityVerified),
                  u.identityVerified ? 'Verified badge removed.' : 'Marked as verified.'),
            ),
            if (!isMe)
              SheetOption(
                icon: u.isAdmin ? Icons.shield_outlined : Icons.shield_rounded,
                label: u.isAdmin ? 'Remove admin role' : 'Make administrator',
                subtitle: u.isAdmin
                    ? 'They lose access to this console'
                    : 'Full access to users, posts and reports',
                onTap: () => _confirmThen(
                  sheetCtx,
                  title: u.isAdmin ? 'Remove admin role?' : 'Make ${u.name} an administrator?',
                  body: u.isAdmin
                      ? '${u.name} will no longer be able to moderate Finder.'
                      : 'Administrators can suspend or delete any account and remove any post.',
                  confirmLabel: u.isAdmin ? 'Remove role' : 'Make admin',
                  action: () => _svc.setAdmin(u.uid, !u.isAdmin),
                  success: u.isAdmin ? 'Admin role removed.' : '${u.name} is now an admin.',
                ),
              ),
            if (!isMe && !u.isAdmin)
              SheetOption(
                icon: u.isBanned ? Icons.lock_open_rounded : Icons.block_rounded,
                label: u.isBanned ? 'Lift suspension' : 'Suspend account',
                subtitle: u.isBanned
                    ? 'They can sign in again'
                    : 'They are signed out and cannot sign in',
                destructive: !u.isBanned,
                onTap: () => _confirmThen(
                  sheetCtx,
                  title: u.isBanned ? 'Lift the suspension?' : 'Suspend ${u.name}?',
                  body: u.isBanned
                      ? 'The account works normally again.'
                      : 'Their posts stay visible. They lose access until you lift the suspension.',
                  confirmLabel: u.isBanned ? 'Lift' : 'Suspend',
                  action: () => _svc.setBanned(u.uid, !u.isBanned),
                  success: u.isBanned ? 'Suspension lifted.' : 'Account suspended.',
                ),
              ),
            if (!isMe && !u.isAdmin)
              SheetOption(
                icon: Icons.delete_forever_outlined,
                label: 'Delete account',
                subtitle: 'Removes the account, its posts and chats. Cannot be undone.',
                destructive: true,
                onTap: () => _confirmThen(
                  sheetCtx,
                  title: 'Delete ${u.name}?',
                  body: 'Everything they posted and every chat they were in is erased permanently.',
                  confirmLabel: 'Delete',
                  action: () => _svc.deleteUser(u.uid),
                  success: 'Account deleted.',
                ),
              ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  AdminConsoleService get _svc => ref.read(adminConsoleServiceProvider);

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

  Future<void> _confirmThen(
    BuildContext sheetCtx, {
    required String title,
    required String body,
    required String confirmLabel,
    required Future<void> Function() action,
    required String success,
  }) async {
    Navigator.pop(sheetCtx);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
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

class _UserRow extends StatelessWidget {
  final AdminUser user;
  final bool isMe;
  final VoidCallback onTap;
  const _UserRow({required this.user, required this.isMe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return SurfaceCard(
      onTap: onTap,
      tone: user.isBanned ? SurfaceTone.error : SurfaceTone.base,
      child: Row(
        children: [
          AppAvatar(url: user.avatarUrl, name: user.name, size: 44),
          const SizedBox(width: BeaconSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NameWithMarks(
                  name: isMe ? '${user.name} (you)' : user.name,
                  verified: user.identityVerified,
                  admin: user.isAdmin,
                  style: text.titleMedium,
                ),
                Text(user.email, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: BeaconSpace.xs),
                Text(
                  '${user.postsCount} post${user.postsCount == 1 ? '' : 's'}'
                  '${user.reportsAgainst > 0 ? ' · ${user.reportsAgainst} report${user.reportsAgainst == 1 ? '' : 's'}' : ''}'
                  ' · joined ${relativeTime(user.createdAtMs)}',
                  style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: BeaconSpace.sm),
          if (user.isBanned)
            StatusBadge.custom(label: 'SUSPENDED', color: t.error, small: true)
          else if (user.isAdmin)
            adminBadge()
          else if (user.identityVerified)
            StatusBadge.verified(),
        ],
      ),
    );
  }
}
