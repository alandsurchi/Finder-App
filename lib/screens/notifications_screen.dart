import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final notificationsState = ref.watch(notificationsControllerProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

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
                  message: describeError(err),
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
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(notificationsControllerProvider.notifier)
                        .loadNotifications(),
                    child: ListView.builder(
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
    if (n.type == NotificationType.newMessage) {
      Navigator.pushNamed(context, AppRoutes.messages);
    }
  }
}
