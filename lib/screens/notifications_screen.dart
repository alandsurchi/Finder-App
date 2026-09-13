import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final notificationsState = ref.watch(notificationsControllerProvider);

    final unreadCount = notificationsState.value
            ?.where((n) => n.isUnread)
            .length ??
        0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Notifications',
              subtitle: unreadCount > 0
                  ? '$unreadCount unread'
                  : (notificationsState.hasValue ? 'You are all caught up' : null),
              actions: [
                if (unreadCount > 0)
                  AppButton.ghost(
                    label: 'Mark all read',
                    size: AppButtonSize.small,
                    onPressed: () {
                      final notifs = ref
                          .read(notificationsControllerProvider)
                          .value ?? [];
                      for (var i = 0; i < notifs.length; i++) {
                        if (notifs[i].isUnread) {
                          ref
                              .read(notificationsControllerProvider.notifier)
                              .markAsRead(i);
                        }
                      }
                    },
                  ),
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Refresh',
                  onPressed: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .loadNotifications(),
                ),
              ],
            ),
            Expanded(
              child: notificationsState.when(
                loading: () => const LoadingWidget(
                  message: 'Loading notifications...',
                  variant: LoadingVariant.rows,
                ),
                error: (err, _) => ErrorStateWidget(
                  message: err.toString(),
                  onRetry: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .loadNotifications(),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const EmptyWidget(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications yet',
                      subtitle:
                          'You will hear from us when someone messages you, your post gets activity, or an item is resolved.',
                    );
                  }
                  return ListView.builder(
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

                      return StaggeredEntrance(
                        index: index.clamp(0, 8),
                        baseDelay: const Duration(milliseconds: 35),
                        child: NotificationItem(
                          title: n.title,
                          message: n.message,
                          timeAgo: n.timeAgo,
                          isUnread: n.isUnread,
                          icon: icon,
                          iconColor: displayColor,
                          onTap: () => ref
                              .read(notificationsControllerProvider.notifier)
                              .markAsRead(index),
                        ),
                      );
                    },
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
