import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/sheets/user_search_sheet.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/features/profile/presentation/privacy_settings_controller.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';
import 'package:finder/app/di/app_providers.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  Future<void> _blockAnother() async {
    final l10n = context.l10n;
    final user = await showUserSearchSheet(
      context,
      title: l10n.privacyBlockMemberTitle,
      actionLabel: l10n.commonBlock,
    );
    if (user == null || !mounted) return;
    if (user.isAdmin) {
      ActionFeedback.showError(context, l10n.privacyAdminCannotBlock);
      return;
    }
    final result = await ref.read(blockedUsersProvider.notifier).blockUser(
          user.uid,
          name: user.displayName,
          avatarUrl: user.avatarUrl,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (_) => ActionFeedback.showSuccess(context, l10n.blockUserDone(user.displayName)),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Future<void> _unblock(String id, String name) async {
    final result = await ref.read(blockedUsersProvider.notifier).unblockUser(id);
    if (!mounted) return;
    result.fold(
      onSuccess: (_) => ActionFeedback.showInfo(context, context.l10n.blockUnblocked(name)),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Future<void> _deleteAccount() async {
    final profile = ref.read(profileControllerProvider).value;
    final usesGoogle = profile?.usesGoogle ?? false;
    final ctrl = TextEditingController();
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.privacyDeleteAccountTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.privacyDeleteAccountBody,
              style: text.bodyMedium,
            ),
            const SizedBox(height: BeaconSpace.lg),
            AppTextField(
              controller: ctrl,
              label: usesGoogle ? l10n.privacyTypeDeleteLabel : l10n.privacyPasswordLabel,
              hint: usesGoogle ? l10n.privacyTypeDeleteHint : l10n.privacyPasswordHint,
              prefixIcon: usesGoogle ? Icons.warning_amber_rounded : Icons.lock_outline_rounded,
              obscureText: !usesGoogle,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => Navigator.pop(ctx, true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: t.error, foregroundColor: t.onError),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.privacyDeleteAccount),
          ),
        ],
      ),
    );
    final entered = ctrl.text;
    ctrl.dispose();
    if (confirmed != true || !mounted) return;
    if (entered.isEmpty) {
      ActionFeedback.showError(context, usesGoogle ? l10n.privacyTypeDeleteError : l10n.privacyEnterPassword);
      return;
    }

    final result = await ref.read(profileRepositoryProvider).deleteAccount(
          password: usesGoogle ? null : entered,
          confirm: usesGoogle ? entered.trim().toUpperCase() : null,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (_) async {
        ActionFeedback.showInfo(context, l10n.privacyAccountDeleted);
        await ref.read(authControllerProvider.notifier).logout();
      },
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final settingsState = ref.watch(privacySettingsProvider);
    final blockedState = ref.watch(blockedUsersProvider);
    final blockedCount = blockedState.value?.length ?? 0;

    Future<void> update(PrivacySettingsUpdate patch) async {
      final current = settingsState.value;
      if (current == null) return;
      final result = await ref
          .read(privacySettingsProvider.notifier)
          .updateSettings(patch(current));
      if (!context.mounted) return;
      result.fold(
        onSuccess: (_) {},
        onFailure: (f) => ActionFeedback.showError(context, f.message),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(title: l10n.privacyTitle),
            Expanded(
              child: settingsState.when(
                loading: () => LoadingWidget(message: l10n.privacyLoadingSettings),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () => ref.read(privacySettingsProvider.notifier).loadSettings(),
                ),
                data: (settings) => SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    BeaconSpace.page,
                    0,
                    BeaconSpace.page,
                    BeaconSpace.xxxl + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StaggeredEntrance(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.privacyHeadline, style: text.headlineMedium),
                            const SizedBox(height: BeaconSpace.sm),
                            Text(
                              l10n.privacyIntro,
                              style: text.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      StaggeredEntrance(
                        index: 1,
                        child: SettingsGroup(
                          title: l10n.privacyVisibility,
                          children: [
                            ToggleTile(
                              icon: Icons.visibility_outlined,
                              title: l10n.privacyShowProfile,
                              subtitle: l10n.privacyShowProfileSubtitle,
                              value: settings.showProfile,
                              onChanged: (v) => update((s) => s.copyWith(showProfile: v)),
                            ),
                            ToggleTile(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: l10n.privacyAllowMessages,
                              subtitle: l10n.privacyAllowMessagesSubtitle,
                              value: settings.allowMessages,
                              onChanged: (v) => update((s) => s.copyWith(allowMessages: v)),
                            ),
                            ToggleTile(
                              icon: Icons.place_outlined,
                              title: l10n.privacyShowCity,
                              subtitle: l10n.privacyShowCitySubtitle,
                              value: settings.showLocation,
                              onChanged: (v) => update((s) => s.copyWith(showLocation: v)),
                            ),
                            ToggleTile(
                              icon: Icons.phone_outlined,
                              title: l10n.privacyHidePhone,
                              subtitle: l10n.privacyHidePhoneSubtitle,
                              value: settings.hidePhone,
                              onChanged: (v) => update((s) => s.copyWith(hidePhone: v)),
                            ),
                          ],
                        ),
                      ),

                      StaggeredEntrance(
                        index: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: BeaconSpace.xs, bottom: BeaconSpace.sm),
                              child: Text(
                                l10n.privacyBlockedMembersLabel,
                                style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                              ),
                            ),
                            SurfaceCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        BeaconSpace.lg, BeaconSpace.lg, BeaconSpace.lg, BeaconSpace.md),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(l10n.privacyBlockedMembers, style: text.titleMedium),
                                              const SizedBox(height: BeaconSpace.xs),
                                              Text(
                                                l10n.privacyBlockedMembersBody,
                                                style: text.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: BeaconSpace.md),
                                        StatusBadge.neutral(l10n.privacyBlockedTotal(blockedCount)),
                                      ],
                                    ),
                                  ),

                                  Divider(color: t.outlineVariant, height: 1),

                                  blockedState.when(
                                    loading: () => Padding(
                                      padding: const EdgeInsets.all(BeaconSpace.lg),
                                      child: LoadingWidget(message: l10n.privacyLoadingBlocked),
                                    ),
                                    error: (err, _) => Padding(
                                      padding: const EdgeInsets.all(BeaconSpace.lg),
                                      child: ErrorStateWidget(
                                        message: describeError(err),
                                        onRetry: () =>
                                            ref.read(blockedUsersProvider.notifier).loadUsers(),
                                      ),
                                    ),
                                    data: (users) {
                                      if (users.isEmpty) {
                                        return EmptyWidget(
                                          icon: Icons.block_rounded,
                                          title: l10n.privacyNoBlocked,
                                          subtitle: l10n.privacyNoBlockedSubtitle,
                                        );
                                      }
                                      return Column(
                                        children: List.generate(users.length, (i) {
                                          final user = users[i];
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: BeaconSpace.lg,
                                                  vertical: BeaconSpace.sm,
                                                ),
                                                child: Row(
                                                  children: [
                                                    AppAvatar(
                                                      url: user.avatarUrl,
                                                      name: user.name,
                                                      size: 40,
                                                      background: t.surfaceHigh,
                                                    ),
                                                    const SizedBox(width: BeaconSpace.md),
                                                    Expanded(
                                                      child: Text(user.name, style: text.titleSmall),
                                                    ),
                                                    AppButton.ghost(
                                                      label: l10n.commonUnblock,
                                                      size: AppButtonSize.small,
                                                      onPressed: () => _unblock(user.id, user.name),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (i < users.length - 1)
                                                Divider(color: t.outlineVariant, height: 1, indent: 68),
                                            ],
                                          );
                                        }),
                                      );
                                    },
                                  ),

                                  Divider(color: t.outlineVariant, height: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(BeaconSpace.sm),
                                    child: AppButton.ghost(
                                      label: l10n.privacyBlockAnother,
                                      icon: Icons.add_rounded,
                                      onPressed: _blockAnother,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      StaggeredEntrance(
                        index: 3,
                        child: SurfaceCard(
                          tone: SurfaceTone.error,
                          onTap: _deleteAccount,
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: t.error, size: 22),
                              const SizedBox(width: BeaconSpace.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.privacyDeleteAccount,
                                        style: text.titleMedium?.copyWith(color: t.error)),
                                    Text(l10n.privacyDeleteAccountSubtitle,
                                        style: text.bodySmall),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: t.error),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
