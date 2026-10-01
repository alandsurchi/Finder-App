import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/admin/admin_console_service.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/l10n/l10n.dart';
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
    final l10n = context.l10n;
    final users = ref.watch(adminUsersProvider(_key));
    final me = ref.watch(authStateProvider).userId ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(title: l10n.adminUsersTitle, subtitle: l10n.adminUsersSubtitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
              child: Column(
                children: [
                  SearchField(
                    controller: _search,
                    hint: l10n.adminUsersSearchHint,
                    onChanged: _onQuery,
                  ),
                  const SizedBox(height: BeaconSpace.md),
                  SegmentedPills(
                    options: [
                      l10n.adminFilterAll,
                      l10n.adminVerifiedLabel,
                      l10n.adminFilterAdmins,
                      l10n.adminSuspendedLabel,
                    ],
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
                    return EmptyWidget(
                      icon: Icons.person_search_outlined,
                      title: l10n.adminNoAccountsMatch,
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
    final l10n = context.l10n;
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
              label: u.identityVerified ? l10n.adminRemoveVerifiedBadge : l10n.adminMarkAsVerified,
              subtitle: u.identityVerified
                  ? l10n.adminRemoveBadgeSubtitle
                  : l10n.adminGrantBadgeSubtitle,
              onTap: () => _run(sheetCtx, () => _svc.setVerified(u.uid, !u.identityVerified),
                  u.identityVerified ? l10n.adminVerifiedBadgeRemoved : l10n.adminMarkedAsVerified),
            ),
            if (!isMe)
              SheetOption(
                icon: u.isAdmin ? Icons.shield_outlined : Icons.shield_rounded,
                label: u.isAdmin ? l10n.adminRemoveAdminRole : l10n.adminMakeAdministrator,
                subtitle: u.isAdmin
                    ? l10n.adminLoseConsoleAccess
                    : l10n.adminFullAccess,
                onTap: () => _confirmThen(
                  sheetCtx,
                  title: u.isAdmin ? l10n.adminRemoveAdminRoleTitle : l10n.adminMakeAdminTitle(u.name),
                  body: u.isAdmin
                      ? l10n.adminRemoveAdminBody(u.name)
                      : l10n.adminMakeAdminBody,
                  confirmLabel: u.isAdmin ? l10n.adminRemoveRole : l10n.adminMakeAdmin,
                  action: () => _svc.setAdmin(u.uid, !u.isAdmin),
                  success: u.isAdmin ? l10n.adminRoleRemoved : l10n.adminNowAdmin(u.name),
                ),
              ),
            if (!isMe && !u.isAdmin)
              SheetOption(
                icon: u.isBanned ? Icons.lock_open_rounded : Icons.block_rounded,
                label: u.isBanned ? l10n.adminLiftSuspension : l10n.adminSuspendAccount,
                subtitle: u.isBanned
                    ? l10n.adminCanSignInAgain
                    : l10n.adminSignedOutCannotSignIn,
                destructive: !u.isBanned,
                onTap: () => _confirmThen(
                  sheetCtx,
                  title: u.isBanned ? l10n.adminLiftSuspensionTitle : l10n.adminSuspendTitle(u.name),
                  body: u.isBanned
                      ? l10n.adminLiftBody
                      : l10n.adminSuspendBody,
                  confirmLabel: u.isBanned ? l10n.adminLift : l10n.adminSuspend,
                  action: () => _svc.setBanned(u.uid, !u.isBanned),
                  success: u.isBanned ? l10n.adminSuspensionLifted : l10n.adminAccountSuspended,
                ),
              ),
            if (!isMe && !u.isAdmin)
              SheetOption(
                icon: Icons.delete_forever_outlined,
                label: l10n.adminDeleteAccount,
                subtitle: l10n.adminDeleteAccountSubtitle,
                destructive: true,
                onTap: () => _confirmThen(
                  sheetCtx,
                  title: l10n.adminDeleteTitle(u.name),
                  body: l10n.adminDeleteBody,
                  confirmLabel: l10n.commonDelete,
                  action: () => _svc.deleteUser(u.uid),
                  success: l10n.adminAccountDeleted,
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
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.l10n.commonCancel)),
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
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final meta = [
      l10n.adminPostsCount(user.postsCount),
      if (user.reportsAgainst > 0) l10n.adminReportsCount(user.reportsAgainst),
      l10n.adminJoined(relativeTime(user.createdAtMs, l10n: l10n)),
    ].join(' · ');
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
                  name: isMe ? l10n.adminYouSuffix(user.name) : user.name,
                  verified: user.identityVerified,
                  admin: user.isAdmin,
                  style: text.titleMedium,
                ),
                Text(user.email, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: BeaconSpace.xs),
                Text(
                  meta,
                  style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: BeaconSpace.sm),
          if (user.isBanned)
            StatusBadge.custom(label: l10n.adminBadgeSuspended, color: t.error, small: true)
          else if (user.isAdmin)
            adminBadge()
          else if (user.identityVerified)
            StatusBadge.verified(),
        ],
      ),
    );
  }
}
