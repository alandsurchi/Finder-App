import 'package:flutter/material.dart';
import 'package:finder/features/notifications/presentation/notification_navigator.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/models/notification_model.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/items/notification_item.dart';
import 'package:finder/features/notifications/presentation/notifications_controller.dart';
import 'package:finder/features/notifications/presentation/notification_style_resolver.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;
    final notificationsState = ref.watch(visibleNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: l10n.commonNotifications,
              subtitle: unreadCount > 0
                  ? l10n.notifUnreadCount(unreadCount)
                  : (notificationsState.hasValue ? l10n.notifCaughtUp : null),
              actions: [
                if (unreadCount > 0)
                  AppButton.ghost(
                    label: l10n.notifMarkAllRead,
                    size: AppButtonSize.small,
                    onPressed: () async {
                      final result = await ref
                          .read(notificationsControllerProvider.notifier)
                          .markAllRead();
                      if (!context.mounted) return;
                      result.fold(
                        onSuccess: (_) {},
                        onFailure: (f) => ActionFeedback.showError(context, f.message),
                      );
                    },
                  ),
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: l10n.commonRefresh,
                  onPressed: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .loadNotifications(),
                ),
              ],
            ),
            Expanded(
              child: notificationsState.when(
                loading: () => LoadingWidget(
                  message: l10n.notifLoading,
                  variant: LoadingVariant.rows,
                ),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .loadNotifications(),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return EmptyWidget(
                      icon: Icons.notifications_none_rounded,
                      title: l10n.notifEmptyTitle,
                      subtitle: l10n.notifEmptySubtitle,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(notificationsControllerProvider.notifier)
                        .loadNotifications(),
                    child: ListView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        BeaconSpace.page,
                        BeaconSpace.xs,
                        BeaconSpace.page,
                        BeaconSpace.xxxl + MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        final displayColor =
                            NotificationStyleResolver.resolveIconColor(n, t);
                        final icon = NotificationStyleResolver.resolveIcon(n);

                        final item = NotificationItem(
                          title: n.title,
                          message: n.message,
                          timeAgo: n.timeAgo,
                          isUnread: n.isUnread,
                          icon: icon,
                          iconColor: displayColor,
                          onTap: () => _open(context, ref, n),
                        );
                        if (index >= 8) return item;
                        return StaggeredEntrance(
                          index: index,
                          baseDelay: const Duration(milliseconds: 35),
                          child: item,
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

  void _open(BuildContext context, WidgetRef ref, NotificationModel n) {
    ref.read(notificationsControllerProvider.notifier).markAsRead(n.id);
    if (n.hasTarget) {
      openNotificationTarget(n.data, posts: ref.read(postServiceProvider));
    } else if (n.type == NotificationType.newMessage) {
      Navigator.pushNamed(context, AppRoutes.messages);
    }
  }
}
