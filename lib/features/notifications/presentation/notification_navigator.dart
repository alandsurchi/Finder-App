import 'package:flutter/material.dart';

import '../../../app/router/root_navigator.dart';
import '../../../l10n/l10n.dart';
import '../../../routes.dart';
import '../../../screens/admin/verification_queue_screen.dart';
import '../../../services/post_service.dart';
import '../../chat/presentation/open_chat.dart';
import '../../posts/presentation/item_details_args.dart';

/// Opens the screen a notification points at, from its `data` payload.
///
/// The same payload arrives through the notifications list, a foreground
/// banner, a background tap and a cold start, so all of them funnel here.
///   - `type: message`       → the chat (chatId, peer*, itemName, postId)
///   - `postId` (any type)   → post details
///   - `type: verification`  → Get verified
///   - anything else         → the notifications list
Future<void> openNotificationTarget(
  Map<String, dynamic> data, {
  required PostService posts,
}) async {
  final nav = rootNavigatorKey.currentState;
  if (nav == null) return;
  String v(String key) => data[key]?.toString() ?? '';

  final type = v('type');
  final chatId = v('chatId');
  final postId = v('postId');

  if (type == 'message' && chatId.isNotEmpty) {
    nav.pushNamed(
      AppRoutes.chat,
      arguments: {
        ChatArgs.chatId: chatId,
        ChatArgs.userName: v('peerName').isEmpty ? L10n.current.commonFinderUser : v('peerName'),
        ChatArgs.itemName: v('itemName'),
        ChatArgs.peerId: v('peerId'),
        ChatArgs.peerAvatarUrl: v('peerAvatarUrl'),
        ChatArgs.postId: postId,
      },
    );
    return;
  }

  if (type == 'verification') {
    nav.pushNamed(AppRoutes.getVerified);
    return;
  }

  if (type == 'verification_request') {
    // Admin: someone submitted documents; open the review queue.
    nav.push(MaterialPageRoute(builder: (_) => const VerificationQueueScreen()));
    return;
  }

  if (postId.isNotEmpty) {
    try {
      final item = await posts.fetchById(postId);
      nav.pushNamed(
        AppRoutes.itemDetails,
        arguments: ItemDetailsArgs(
          item,
          matchedPostId: type == 'match' && v('myPostId').isNotEmpty ? v('myPostId') : null,
        ),
      );
      return;
    } catch (_) {
      // Post may have been deleted: fall through to the list.
    }
  }

  nav.pushNamed(AppRoutes.notifications);
}
