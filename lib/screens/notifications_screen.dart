import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/widgets/items/notification_item.dart';
import 'package:finder/features/notifications/presentation/notifications_controller.dart';
import 'package:finder/features/notifications/presentation/notification_style_resolver.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final notificationsState = ref.watch(notificationsControllerProvider);

    final unreadCount = notificationsState.value
            ?.where((n) => n.isUnread)
            .length ??
        0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D8CFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
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
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 20),
            onPressed: () => ref
                .read(notificationsControllerProvider.notifier)
                .loadNotifications(),
          ),
        ],
      ),
      body: notificationsState.when(
        loading: () =>
            const LoadingWidget(message: 'Loading notifications...'),
        error: (err, _) => ErrorStateWidget(message: err.toString()),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyWidget(
              title: 'No notifications yet',
              subtitle:
                  'You will receive notifications here when:\n• Someone messages you\n• Your post gets activity\n• A post is resolved',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final displayColor =
                  NotificationStyleResolver.resolveIconColor(n, t);
              final icon = NotificationStyleResolver.resolveIcon(n);

              return GestureDetector(
                onTap: () => ref
                    .read(notificationsControllerProvider.notifier)
                    .markAsRead(index),
                child: NotificationItem(
                  title: n.title,
                  message: n.message,
                  timeAgo: n.timeAgo,
                  isUnread: n.isUnread,
                  icon: icon,
                  iconColor: displayColor,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
