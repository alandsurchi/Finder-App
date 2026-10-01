import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/profile/domain/notification_settings.dart';
import 'package:finder/features/profile/presentation/notification_settings_controller.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final state = ref.watch(notificationSettingsProvider);

    Future<void> apply(NotificationSettings next) async {
      final result =
          await ref.read(notificationSettingsProvider.notifier).update(next);
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
            AppPageHeader(title: l10n.commonNotifications),
            Expanded(
              child: state.when(
                loading: () => LoadingWidget(message: l10n.notifLoadingPreferences),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () => ref.read(notificationSettingsProvider.notifier).load(),
                ),
                data: (s) {
                  final allOff = !s.messages && !s.matches && !s.updates && !s.marketing;
                  return SingleChildScrollView(
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
                          child: SurfaceCard(
                            tone: SurfaceTone.primary,
                            padding: const EdgeInsets.all(BeaconSpace.xl),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.notifStayConnected,
                                          style: text.headlineSmall
                                              ?.copyWith(color: t.onPrimaryContainer)),
                                      const SizedBox(height: BeaconSpace.sm),
                                      Text(
                                        l10n.notifStayConnectedBody,
                                        style: text.bodyMedium?.copyWith(
                                          color: t.onPrimaryContainer.withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: BeaconSpace.md),
                                Icon(Icons.notifications_active_outlined,
                                    color: t.primary, size: 44),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: BeaconSpace.xl),

                        StaggeredEntrance(
                          index: 1,
                          child: SettingsGroup(
                            children: [
                              ToggleTile(
                                icon: Icons.settings_input_antenna_rounded,
                                title: l10n.notifAll,
                                subtitle: allOff
                                    ? l10n.notifAllMuted
                                    : l10n.notifAllOff,
                                value: !allOff,
                                onChanged: (v) => apply(s.copyWith(
                                  messages: v,
                                  matches: v,
                                  updates: v,
                                  marketing: v ? s.marketing : false,
                                )),
                              ),
                            ],
                          ),
                        ),

                        StaggeredEntrance(
                          index: 2,
                          child: SettingsGroup(
                            title: l10n.notifConversations,
                            children: [
                              ToggleTile(
                                icon: Icons.chat_bubble_outline_rounded,
                                title: l10n.notifNewMessage,
                                subtitle: l10n.notifNewMessageSubtitle,
                                value: s.messages,
                                onChanged: (v) => apply(s.copyWith(messages: v)),
                              ),
                            ],
                          ),
                        ),

                        StaggeredEntrance(
                          index: 3,
                          child: SettingsGroup(
                            title: l10n.notifSmartMatching,
                            children: [
                              ToggleTile(
                                icon: Icons.auto_awesome_rounded,
                                title: l10n.notifItemMatch,
                                subtitle: l10n.notifItemMatchSubtitle,
                                value: s.matches,
                                onChanged: (v) => apply(s.copyWith(matches: v)),
                                badge: StatusBadge.custom(
                                  label: l10n.notifSmartBadge,
                                  color: t.accent,
                                  onColor: t.onAccent,
                                  small: true,
                                ),
                              ),
                              ToggleTile(
                                icon: Icons.task_alt_rounded,
                                title: l10n.notifPostUpdates,
                                subtitle: l10n.notifPostUpdatesSubtitle,
                                value: s.updates,
                                onChanged: (v) => apply(s.copyWith(updates: v)),
                              ),
                            ],
                          ),
                        ),

                        StaggeredEntrance(
                          index: 4,
                          child: SettingsGroup(
                            title: l10n.notifFromFinder,
                            children: [
                              ToggleTile(
                                icon: Icons.campaign_outlined,
                                title: l10n.notifTips,
                                subtitle: l10n.notifTipsSubtitle,
                                value: s.marketing,
                                onChanged: (v) => apply(s.copyWith(marketing: v)),
                              ),
                              ToggleTile(
                                icon: Icons.mail_outline_rounded,
                                title: l10n.notifEmailCopies,
                                subtitle: l10n.notifEmailCopiesSubtitle,
                                value: s.email,
                                onChanged: (v) => apply(s.copyWith(email: v)),
                              ),
                            ],
                          ),
                        ),

                        StaggeredEntrance(
                          index: 5,
                          child: Text(
                            l10n.notifFooter,
                            style: text.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
}
