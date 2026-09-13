import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/chat/domain/message.dart';
import 'package:finder/features/chat/presentation/open_chat.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:finder/routes.dart';
import 'package:finder/services/image_upload_service.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  bool _uploading = false;
  int _lastCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    return (args is Map) ? Map<String, dynamic>.from(args) : const {};
  }

  String _arg(String key, [String fallback = '']) =>
      _args[key]?.toString().trim().isNotEmpty == true
      ? _args[key].toString()
      : fallback;

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final chatId = _arg(ChatArgs.chatId);
    final userName = _arg(ChatArgs.userName, 'Finder User');
    final itemName = _arg(ChatArgs.itemName);
    final peerId = _arg(ChatArgs.peerId);
    final peerAvatarUrl = _arg(ChatArgs.peerAvatarUrl);
    final postId = _arg(ChatArgs.postId);
    final currentUserId = ref.watch(authStateProvider).userId ?? '';

    if (chatId.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const AppPageHeader(title: 'Conversation'),
              const Expanded(
                child: EmptyWidget(
                  icon: Icons.forum_outlined,
                  title: 'Conversation not found',
                  subtitle: 'Open a chat from a post or from Messages.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final messagesState = ref.watch(chatMessagesProvider(chatId));

    // Scroll to the newest message whenever one arrives.
    ref.listen(chatMessagesProvider(chatId), (prev, next) {
      final count = next.value?.length ?? 0;
      if (count != _lastCount) {
        _lastCount = count;
        _scrollToBottom();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildChatHeader(
              context,
              userName,
              itemName,
              peerId,
              peerAvatarUrl,
              postId,
              t,
            ),
            Divider(color: t.outlineVariant, height: 1, thickness: 1),
            Expanded(
              child: messagesState.when(
                loading: () =>
                    const LoadingWidget(message: 'Loading messages...'),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () =>
                      ref.read(chatMessagesProvider(chatId).notifier).load(),
                ),
                data: (messages) {
                  if (messages.isEmpty) {
                    return EmptyWidget(
                      icon: Icons.forum_outlined,
                      title: 'Say hello to $userName',
                      subtitle: itemName.isEmpty
                          ? 'Start the conversation by sending a message.'
                          : 'Ask about "$itemName" or arrange a safe hand-over.',
                    );
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: BeaconSpace.lg,
                      vertical: BeaconSpace.xl,
                    ),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: BeaconSpace.sm),
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;
                      final prevSame =
                          index > 0 &&
                          messages[index - 1].senderId == msg.senderId;
                      return _ChatBubble(
                        message: msg,
                        isMe: isMe,
                        continued: prevSame,
                        onRetry: msg.failed
                            ? () => _retry(chatId, msg.messageId)
                            : null,
                        onDiscard: msg.failed
                            ? () => ref
                                  .read(chatMessagesProvider(chatId).notifier)
                                  .discard(msg.messageId)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputArea(t, chatId),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildChatHeader(
    BuildContext context,
    String userName,
    String itemName,
    String peerId,
    String peerAvatarUrl,
    String postId,
    AppColorTokens t,
  ) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BeaconSpace.md,
        BeaconSpace.sm,
        BeaconSpace.sm,
        BeaconSpace.sm,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            variant: AppIconButtonVariant.ghost,
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: BeaconSpace.xs),
          AppAvatar(url: peerAvatarUrl, name: userName, size: 44),
          const SizedBox(width: BeaconSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (itemName.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 12,
                        color: t.primary,
                      ),
                      const SizedBox(width: BeaconSpace.xs),
                      Flexible(
                        child: Text(
                          itemName,
                          style: text.labelSmall?.copyWith(color: t.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Direct message',
                    style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                  ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.more_vert_rounded,
            tooltip: 'More options',
            variant: AppIconButtonVariant.ghost,
            onPressed: () => _showMoreSheet(userName, peerId, postId, itemName),
          ),
        ],
      ),
    );
  }

  void _showMoreSheet(
    String userName,
    String peerId,
    String postId,
    String itemName,
  ) {
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: userName,
        subtitle: itemName.isEmpty ? null : 'About "$itemName"',
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (postId.isNotEmpty)
              SheetOption(
                icon: Icons.inventory_2_outlined,
                label: 'View the post',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  try {
                    final post = await ref
                        .read(postServiceProvider)
                        .fetchById(postId);
                    if (!mounted) return;
                    Navigator.pushNamed(
                      context,
                      AppRoutes.itemDetails,
                      arguments: post,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ActionFeedback.showError(context, describeError(e));
                  }
                },
              ),
            if (postId.isNotEmpty)
              SheetOption(
                icon: Icons.flag_outlined,
                label: 'Report the post',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  try {
                    await ref
                        .read(postServiceProvider)
                        .reportPost(postId, 'Reported from chat');
                    if (!mounted) return;
                    ActionFeedback.showSuccess(
                      context,
                      'Thanks, the post has been reported.',
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ActionFeedback.showError(context, describeError(e));
                  }
                },
              ),
            if (peerId.isNotEmpty)
              SheetOption(
                icon: Icons.block_rounded,
                label: 'Block $userName',
                destructive: true,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmBlock(userName, peerId);
                },
              ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  void _confirmBlock(String userName, String peerId) {
    final t = AppColorTokens.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Block $userName?'),
        content: const Text(
          'This conversation will disappear and neither of you can message the other. Undo it any time in Privacy & safety.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: t.error,
              foregroundColor: t.onError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await ref
                  .read(blockedUsersProvider.notifier)
                  .blockUser(peerId, name: userName);
              if (!mounted) return;
              result.fold(
                onSuccess: (_) {
                  ActionFeedback.showSuccess(
                    context,
                    '$userName has been blocked.',
                  );
                  Navigator.pop(context);
                },
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AppColorTokens t, String chatId) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(
        BeaconSpace.md,
        BeaconSpace.md,
        BeaconSpace.md,
        BeaconSpace.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _uploading
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                )
              : AppIconButton(
                  icon: Icons.add_photo_alternate_outlined,
                  tooltip: 'Send a photo',
                  size: 48,
                  variant: AppIconButtonVariant.tonal,
                  onPressed: () => _sendPhoto(chatId),
                ),
          const SizedBox(width: BeaconSpace.sm),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.surfaceLow,
                borderRadius: BeaconRadius.rXxl,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.lg),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendText(chatId),
                  style: text.bodyLarge,
                  cursorColor: t.primary,
                  decoration: InputDecoration(
                    hintText: 'Type a message…',
                    hintStyle: text.bodyLarge?.copyWith(
                      color: t.onSurfaceMuted,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: BeaconSpace.md,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: BeaconSpace.sm),
          AppIconButton(
            icon: Icons.send_rounded,
            tooltip: 'Send message',
            size: 48,
            variant: AppIconButtonVariant.filled,
            onPressed: _sending ? null : () => _sendText(chatId),
          ),
        ],
      ),
    );
  }

  Future<void> _sendText(String chatId) async {
    final value = _controller.text.trim();
    if (value.isEmpty || _sending) return;
    _controller.clear();
    setState(() => _sending = true);
    final result = await ref
        .read(chatMessagesProvider(chatId).notifier)
        .send(text: value);
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      onSuccess: (_) => ref.invalidate(conversationsStreamProvider),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Future<void> _sendPhoto(String chatId) async {
    setState(() => _uploading = true);
    try {
      final url = await ImageUploadService.pickAndUpload(
        folder: 'chat',
        fileName: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (url == null || !mounted) return;
      final result = await ref
          .read(chatMessagesProvider(chatId).notifier)
          .send(imageUrl: url);
      if (!mounted) return;
      result.fold(
        onSuccess: (_) => ref.invalidate(conversationsStreamProvider),
        onFailure: (f) => ActionFeedback.showError(context, f.message),
      );
    } catch (e) {
      if (mounted) {
        ActionFeedback.showError(
          context,
          'Photo upload failed. ${describeError(e)}',
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _retry(String chatId, String localId) async {
    final result = await ref
        .read(chatMessagesProvider(chatId).notifier)
        .retry(localId);
    if (!mounted) return;
    result.fold(
      onSuccess: (_) {},
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool continued;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    this.continued = false,
    this.onRetry,
    this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    const r = Radius.circular(BeaconRadius.xl);
    const tail = Radius.circular(6);
    final failed = message.failed;
    final bg = failed ? t.errorSurface : (isMe ? t.primary : t.surface);
    final fg = failed ? t.error : (isMe ? t.onPrimary : t.onSurface);
    final meta = failed
        ? t.error
        : (isMe ? t.onPrimary.withValues(alpha: 0.7) : t.onSurfaceMuted);

    final bubble = Container(
      padding: message.hasImage
          ? const EdgeInsets.all(BeaconSpace.xs)
          : const EdgeInsets.fromLTRB(
              BeaconSpace.lg,
              BeaconSpace.md,
              BeaconSpace.lg,
              BeaconSpace.sm,
            ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: (!isMe && continued) ? tail : r,
          topRight: (isMe && continued) ? tail : r,
          bottomLeft: isMe ? r : tail,
          bottomRight: isMe ? tail : r,
        ),
        border: (isMe && !failed)
            ? null
            : Border.all(color: failed ? t.error : t.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.hasImage)
            ClipRRect(
              borderRadius: BeaconRadius.rLg,
              child: ItemImage(
                url: message.imageUrl,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
                fallbackIcon: Icons.image_outlined,
              ),
            ),
          if (message.text.isNotEmpty)
            Padding(
              padding: message.hasImage
                  ? const EdgeInsets.fromLTRB(
                      BeaconSpace.md,
                      BeaconSpace.sm,
                      BeaconSpace.md,
                      0,
                    )
                  : EdgeInsets.zero,
              child: Text(
                message.text,
                style: text.bodyLarge?.copyWith(color: fg),
              ),
            ),
          Padding(
            padding: message.hasImage
                ? const EdgeInsets.fromLTRB(
                    BeaconSpace.md,
                    BeaconSpace.xs,
                    BeaconSpace.md,
                    BeaconSpace.xs,
                  )
                : const EdgeInsets.only(top: BeaconSpace.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  failed
                      ? 'Not sent'
                      : clockTime(message.createdAt.millisecondsSinceEpoch),
                  style: text.labelSmall?.copyWith(color: meta),
                ),
                if (isMe && !failed) ...[
                  const SizedBox(width: BeaconSpace.xs),
                  Icon(
                    message.isPending
                        ? Icons.schedule_rounded
                        : Icons.done_all_rounded,
                    color: meta,
                    size: 14,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Semantics(
          label: isMe ? 'You said' : 'They said',
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                duration: BeaconMotion.scaled(context, BeaconMotion.state),
                opacity: message.isPending ? 0.72 : 1,
                child: bubble,
              ),
              if (failed)
                Padding(
                  padding: const EdgeInsets.only(top: BeaconSpace.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton.ghost(
                        label: 'Retry',
                        icon: Icons.refresh_rounded,
                        size: AppButtonSize.small,
                        onPressed: onRetry,
                      ),
                      AppButton.ghost(
                        label: 'Discard',
                        size: AppButtonSize.small,
                        onPressed: onDiscard,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
