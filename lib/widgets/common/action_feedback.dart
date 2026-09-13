import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Themed snackbars. Static API is stable; visuals come from the theme.
class ActionFeedback {
  static void showInfo(BuildContext context, String message) =>
      _show(context, message, Icons.info_outline_rounded);

  static void showSuccess(BuildContext context, String message) =>
      _show(context, message, Icons.check_circle_outline_rounded, success: true);

  static void showError(BuildContext context, String message) =>
      _show(context, message, Icons.error_outline_rounded, error: true);

  static void showComingSoon(
    BuildContext context, {
    String feature = 'This feature',
  }) =>
      _show(context, '$feature is coming soon.', Icons.auto_awesome_outlined);

  static void _show(
    BuildContext context,
    String message,
    IconData icon, {
    bool success = false,
    bool error = false,
  }) {
    final t = AppColorTokens.of(context);
    final iconColor = error
        ? t.error
        : success
            ? t.found
            : t.accent;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: BeaconSpace.md),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
