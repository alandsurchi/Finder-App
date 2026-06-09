import 'package:flutter/material.dart';
import '../../../models/notification_model.dart';
import '../../../theme/app_color_tokens.dart';

class NotificationStyleResolver {
  static Color resolveIconColor(NotificationModel n, AppColorTokens t) {
    switch (n.type) {
      case NotificationType.itemMatch:
        return t.success;
      case NotificationType.newMessage:
        return t.primary;
      case NotificationType.postApproved:
        return t.warning;
      case NotificationType.system:
        return t.onSurfaceMuted;
    }
  }

  static IconData resolveIcon(NotificationModel n) {
    switch (n.type) {
      case NotificationType.itemMatch:
        return Icons.check_circle_outline;
      case NotificationType.newMessage:
        return Icons.chat_bubble_outline;
      case NotificationType.postApproved:
        return Icons.verified_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }
}
