import 'package:finder/services/analytics/firebase_analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../../l10n/l10n.dart';
import '../../../providers/chat_provider.dart';
import '../../../routes.dart';
import '../../../widgets/common/action_feedback.dart';
import '../../auth/presentation/auth_state_provider.dart';

/// Route arguments understood by the chat screen.
class ChatArgs {
  static const chatId = 'chatId';
  static const userName = 'userName';
  static const itemName = 'itemName';
  static const peerId = 'peerId';
  static const peerAvatarUrl = 'peerAvatarUrl';
  static const postId = 'postId';
  static const postOwnerId = 'postOwnerId';
  static const postStatus = 'postStatus';
  static const peerVerified = 'peerVerified';
  static const peerAdmin = 'peerAdmin';
}

/// Opens (creating if needed) the conversation with [peerId] and navigates
/// to it. Handles the "message yourself" case and server refusals
/// (blocked, messages disabled) with a toast.
Future<void> openChatWith(
  BuildContext context,
  WidgetRef ref, {
  required String peerId,
  required String peerName,
  String peerAvatarUrl = '',
  String? postId,
  String? itemName,
  String? postOwnerId,
  String? postStatus,
  bool peerVerified = false,
  bool peerAdmin = false,
}) async {
  final l10n = context.l10n;
  final me = ref.read(authStateProvider).userId ?? '';
  if (me.isEmpty) {
    ActionFeedback.showInfo(context, l10n.chatSignInToMessage);
    return;
  }
  if (peerId.isEmpty || peerId == me) {
    ActionFeedback.showInfo(context, l10n.chatOwnPost);
    return;
  }

  try {
    final chatId = await ref.read(chatServiceProvider).createOrGetChat(
          peerId: peerId,
          postId: postId,
          itemName: itemName,
        );
    ref.read(analyticsProvider).logEvent(AnalyticsEvents.chatStarted, parameters: {'from_post': postId == null || postId.isEmpty ? 0 : 1});
    if (!context.mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        ChatArgs.chatId: chatId,
        ChatArgs.userName: peerName,
        ChatArgs.itemName: itemName ?? '',
        ChatArgs.peerId: peerId,
        ChatArgs.peerAvatarUrl: peerAvatarUrl,
        ChatArgs.postId: postId ?? '',
        ChatArgs.postOwnerId: postOwnerId ?? '',
        ChatArgs.postStatus: postStatus ?? '',
        ChatArgs.peerVerified: peerVerified ? '1' : '',
        ChatArgs.peerAdmin: peerAdmin ? '1' : '',
      },
    );
  } catch (e) {
    if (!context.mounted) return;
    ActionFeedback.showError(
      context,
      failureFrom(e, fallback: l10n.chatOpenFailed).message,
    );
  }
}
