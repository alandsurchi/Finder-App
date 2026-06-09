import 'package:flutter/material.dart';

class ActionFeedback {
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void showComingSoon(
    BuildContext context, {
    String feature = 'This feature',
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }
}
