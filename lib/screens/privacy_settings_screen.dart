import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/features/profile/presentation/privacy_settings_controller.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final settingsState = ref.watch(privacySettingsProvider);
    final blockedState = ref.watch(blockedUsersProvider);
    final blockedCount = blockedState.maybeWhen(
      data: (users) => users.length,
      orElse: () => 0,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'Privacy & safety'),
            Expanded(
              child: settingsState.when(
                loading: () => const LoadingWidget(message: 'Loading settings...'),
                error: (err, _) => ErrorStateWidget(
                  message: err.toString(),
                  onRetry: () =>
                      ref.read(privacySettingsProvider.notifier).loadSettings(),
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
                      // ── Hero text
                      StaggeredEntrance(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your data, your control', style: text.headlineMedium),
                            const SizedBox(height: BeaconSpace.sm),
                            Text(
                              'Every setting here is designed to give you peace of mind while staying connected to your community.',
                              style: text.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      // ── Toggle cards
                      StaggeredEntrance(
                        index: 1,
                        child: SettingsGroup(
                          title: 'Visibility',
                          children: [
                            ToggleTile(
                              icon: Icons.visibility_outlined,
                              title: 'Show profile to public',
                              subtitle:
                                  'Your name and photo are visible to non-logged users. Off limits visibility to verified members.',
                              value: settings.showProfile,
                              onChanged: (v) => ref
                                  .read(privacySettingsProvider.notifier)
                                  .updateSettings(settings.copyWith(showProfile: v)),
                            ),
                            ToggleTile(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'Allow direct messages',
                              subtitle:
                                  'Let other members reach out directly. Conversations are encrypted in transit.',
                              value: settings.allowMessages,
                              onChanged: (v) => ref
                                  .read(privacySettingsProvider.notifier)
                                  .updateSettings(
                                    settings.copyWith(allowMessages: v),
                                  ),
                            ),
                            ToggleTile(
                              icon: Icons.place_outlined,
                              title: 'Show my location',
                              subtitle:
                                  'Shares your approximate neighborhood when you post a found item.',
                              value: settings.showLocation,
                              onChanged: (v) => ref
                                  .read(privacySettingsProvider.notifier)
                                  .updateSettings(settings.copyWith(showLocation: v)),
                            ),
                            ToggleTile(
                              icon: Icons.phone_outlined,
                              title: 'Hide my phone',
                              subtitle:
                                  'Your number is never shown. Communication happens through secure in-app messaging.',
                              value: settings.hidePhone,
                              onChanged: (v) => ref
                                  .read(privacySettingsProvider.notifier)
                                  .updateSettings(settings.copyWith(hidePhone: v)),
                            ),
                          ],
                        ),
                      ),

                      // ── Blocked Users
                      StaggeredEntrance(
                        index: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: BeaconSpace.xs, bottom: BeaconSpace.sm),
                              child: Text(
                                'BLOCKED USERS',
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
                                              Text('Blocked users', style: text.titleMedium),
                                              const SizedBox(height: BeaconSpace.xs),
                                              Text(
                                                "People you've blocked can't see your posts or message you.",
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
                                      child: LoadingWidget(
                                        message: 'Loading blocked users...',
                                      ),
                                    ),
                                    error: (err, _) => Padding(
                                      padding: const EdgeInsets.all(BeaconSpace.lg),
                                      child: ErrorStateWidget(message: err.toString()),
                                    ),
                                    data: (users) {
                                      if (users.isEmpty) {
                                        return const EmptyWidget(
                                          icon: Icons.block_rounded,
                                          title: 'No blocked users',
                                          subtitle: 'Blocked users will appear here.',
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
                                                      name: user.avatarLabel,
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
                                                      onPressed: () => ref
                                                          .read(
                                                            blockedUsersProvider.notifier,
                                                          )
                                                          .unblockUser(user.id),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (i < users.length - 1)
                                                Divider(
                                                  color: t.outlineVariant,
                                                  height: 1,
                                                  indent: 68,
                                                ),
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
                                      label: 'Block another user',
                                      icon: Icons.add_rounded,
                                      onPressed: () => ActionFeedback.showComingSoon(
                                        context,
                                        feature: 'Block another user',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      // ── Request Data Deletion
                      StaggeredEntrance(
                        index: 3,
                        child: SurfaceCard(
                          tone: SurfaceTone.error,
                          onTap: () => ActionFeedback.showInfo(
                            context,
                            'Data deletion request flow will be available from support soon.',
                          ),
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
