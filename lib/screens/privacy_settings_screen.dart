import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/sheets/user_search_sheet.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/features/profile/presentation/privacy_settings_controller.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  Future<void> _blockAnother() async {
    final user = await showUserSearchSheet(
      context,
      title: 'Block a member',
      actionLabel: 'Block',
    );
    if (user == null || !mounted) return;
    final result = await ref.read(blockedUsersProvider.notifier).blockUser(
          user.uid,
          name: user.displayName,
          avatarUrl: user.avatarUrl,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (_) => ActionFeedback.showSuccess(context, '${user.displayName} has been blocked.'),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Future<void> _unblock(String id, String name) async {
    final result = await ref.read(blockedUsersProvider.notifier).unblockUser(id);
    if (!mounted) return;
    result.fold(
      onSuccess: (_) => ActionFeedback.showInfo(context, '$name can contact you again.'),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Future<void> _requestDeletion() async {
    final profile = ref.read(profileControllerProvider).value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request data deletion?'),
        content: const Text(
            'We will open an e-mail to our privacy team. Your account, posts and conversations are removed within 30 days of the request.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final uri = Uri(
      scheme: 'mailto',
      path: 'privacy@finder.app',
      query: 'subject=${Uri.encodeComponent('Data deletion request')}'
          '&body=${Uri.encodeComponent('Please delete the Finder account for ${profile?.email ?? 'my e-mail address'}.')}',
    );
    var ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {}
    if (!ok && mounted) {
      ActionFeedback.showInfo(context, 'No e-mail app found. Write to privacy@finder.app to request deletion.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
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
            const AppPageHeader(title: 'Privacy & safety'),
            Expanded(
              child: settingsState.when(
                loading: () => const LoadingWidget(message: 'Loading settings...'),
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
                            Text('Your data, your control', style: text.headlineMedium),
                            const SizedBox(height: BeaconSpace.sm),
                            Text(
                              'Decide what other members can see and who can reach you. Changes apply immediately.',
                              style: text.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      StaggeredEntrance(
                        index: 1,
                        child: SettingsGroup(
                          title: 'Visibility',
                          children: [
                            ToggleTile(
                              icon: Icons.visibility_outlined,
                              title: 'Show my profile',
                              subtitle:
                                  'Off shows only your name and photo on posts; job, phone and location stay hidden.',
                              value: settings.showProfile,
                              onChanged: (v) => update((s) => s.copyWith(showProfile: v)),
                            ),
                            ToggleTile(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'Allow direct messages',
                              subtitle:
                                  'Let members start a conversation with you. Existing chats stay open.',
                              value: settings.allowMessages,
                              onChanged: (v) => update((s) => s.copyWith(allowMessages: v)),
                            ),
                            ToggleTile(
                              icon: Icons.place_outlined,
                              title: 'Show my city',
                              subtitle: 'Shares the address from your profile with other members.',
                              value: settings.showLocation,
                              onChanged: (v) => update((s) => s.copyWith(showLocation: v)),
                            ),
                            ToggleTile(
                              icon: Icons.phone_outlined,
                              title: 'Hide my phone number',
                              subtitle:
                                  'When on, members can only reach you through in-app chat.',
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
                              padding: const EdgeInsets.only(
                                  left: BeaconSpace.xs, bottom: BeaconSpace.sm),
                              child: Text(
                                'BLOCKED MEMBERS',
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
                                              Text('Blocked members', style: text.titleMedium),
                                              const SizedBox(height: BeaconSpace.xs),
                                              Text(
                                                "Blocked members can't see your posts or message you, and you won't see theirs.",
                                                style: text.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: BeaconSpace.md),
                                        StatusBadge.neutral('$blockedCount total'),
                                      ],
                                    ),
                                  ),

                                  Divider(color: t.outlineVariant, height: 1),

                                  blockedState.when(
                                    loading: () => const Padding(
                                      padding: EdgeInsets.all(BeaconSpace.lg),
                                      child: LoadingWidget(message: 'Loading blocked members...'),
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
                                        return const EmptyWidget(
                                          icon: Icons.block_rounded,
                                          title: 'No blocked members',
                                          subtitle: 'Members you block will appear here.',
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
                                                      label: 'Unblock',
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
                                      label: 'Block another member',
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
                          onTap: _requestDeletion,
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: t.error, size: 22),
                              const SizedBox(width: BeaconSpace.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Request data deletion',
                                        style: text.titleMedium?.copyWith(color: t.error)),
                                    Text('Permanently remove your account and data.',
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
