import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> routeArgs = (args is Map<String, dynamic>)
        ? args
        : {};
    final String userName = routeArgs['userName'] as String? ?? 'Finder User';
    final String itemName = routeArgs['itemName'] as String? ?? '';
    final String chatId = routeArgs['chatId'] as String? ?? 'default';
    final messagesState = ref.watch(messagesStreamProvider(chatId));
    final currentUserId = ref.watch(authStateProvider).userId ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildChatHeader(context, userName, itemName, t),
            Divider(color: t.outlineVariant, height: 1, thickness: 1),
            Expanded(
              child: messagesState.when(
                loading: () =>
                    const LoadingWidget(message: 'Loading messages...'),
                error: (err, _) => ErrorStateWidget(message: err.toString()),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const EmptyWidget(
                      icon: Icons.forum_outlined,
                      title: 'No messages yet',
                      subtitle: 'Start the conversation by sending a message.',
                    );
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: BeaconSpace.lg,
                      vertical: BeaconSpace.xl,
                    ),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.sm),
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;
                      final prevSame = index > 0 &&
                          messages[index - 1].senderId == msg.senderId;
                      return _ChatBubble(
                        message: msg.text,
                        time: _formatTime(msg.createdAt.millisecondsSinceEpoch),
                        isMe: isMe,
                        showDoubleTick: isMe,
                        continued: prevSame,
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

  Widget _buildChatHeader(
    BuildContext context,
    String userName,
    String itemName,
    AppColorTokens t,
  ) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          BeaconSpace.md, BeaconSpace.sm, BeaconSpace.sm, BeaconSpace.sm),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            variant: AppIconButtonVariant.ghost,
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: BeaconSpace.xs),
          AppAvatar(name: userName, size: 44, online: true),
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
                      Icon(Icons.inventory_2_outlined, size: 12, color: t.primary),
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
                    'Online',
                    style: text.labelSmall?.copyWith(color: t.found),
                  ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.phone_outlined,
            tooltip: 'Voice call',
            variant: AppIconButtonVariant.ghost,
            onPressed: () => ActionFeedback.showComingSoon(
              context,
              feature: 'Voice calling',
            ),
          ),
          AppIconButton(
            icon: Icons.videocam_outlined,
            tooltip: 'Video call',
            variant: AppIconButtonVariant.ghost,
            onPressed: () => ActionFeedback.showComingSoon(
              context,
              feature: 'Video calling',
            ),
          ),
          AppIconButton(
            icon: Icons.more_vert_rounded,
            tooltip: 'More options',
            variant: AppIconButtonVariant.ghost,
            onPressed: () => ActionFeedback.showInfo(
              context,
              'More chat options will appear here.',
            ),
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
          BeaconSpace.md, BeaconSpace.md, BeaconSpace.md, BeaconSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Plus Button
          AppIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Attach',
            size: 48,
            variant: AppIconButtonVariant.tonal,
            onPressed: () => _showAttachmentOptions(t),
          ),
          const SizedBox(width: BeaconSpace.sm),
          // Text Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 132),
              decoration: BoxDecoration(
                color: t.surfaceLow,
                borderRadius: BeaconRadius.rXxl,
              ),
              padding: const EdgeInsets.only(left: BeaconSpace.lg, right: BeaconSpace.xs),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: text.bodyLarge,
                      cursorColor: t.primary,
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        hintStyle: text.bodyLarge?.copyWith(color: t.onSurfaceMuted),
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
                  IconButton(
                    tooltip: 'Voice message',
                    icon: Icon(Icons.mic_none_rounded, color: t.onSurfaceVar, size: 22),
                    onPressed: () => ActionFeedback.showComingSoon(
                      context,
                      feature: 'Voice message',
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: BeaconSpace.sm),
          // Send Button
          AppIconButton(
            icon: Icons.send_rounded,
            tooltip: 'Send message',
            size: 48,
            variant: AppIconButtonVariant.filled,
            onPressed: () async {
              final text = _controller.text.trim();
              if (text.isEmpty) return;

              final currentUserId = ref.read(authStateProvider).userId ?? '';
              if (currentUserId.isEmpty) return;

              final chatService = ref.read(chatServiceProvider);
              try {
                await chatService.sendMessage(chatId, currentUserId, text);
                _controller.clear();

                // Auto-scroll to latest message
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent + 100,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ActionFeedback.showInfo(context, 'Error sending message: $e');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(int timestampMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showAttachmentOptions(AppColorTokens t) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) => AppBottomSheet(
        title: 'Attach',
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a photo',
              onTap: () => Navigator.pop(context),
            ),
            SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Send photos',
              onTap: () => Navigator.pop(context),
            ),
            SheetOption(
              icon: Icons.attach_file_outlined,
              label: 'Attach a file',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool showDoubleTick;
  final bool continued;

  const _ChatBubble({
    required this.message,
    required this.time,
    required this.isMe,
    this.showDoubleTick = false,
    this.continued = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    const r = Radius.circular(BeaconRadius.xl);
    const tail = Radius.circular(6);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Semantics(
          label: isMe ? 'You said' : 'They said',
          child: Container(
            padding: const EdgeInsets.fromLTRB(
                BeaconSpace.lg, BeaconSpace.md, BeaconSpace.lg, BeaconSpace.sm),
            decoration: BoxDecoration(
              color: isMe ? t.primary : t.surface,
              borderRadius: BorderRadius.only(
                topLeft: (!isMe && continued) ? tail : r,
                topRight: (isMe && continued) ? tail : r,
                bottomLeft: isMe ? r : tail,
                bottomRight: isMe ? tail : r,
              ),
              border: isMe ? null : Border.all(color: t.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: text.bodyLarge?.copyWith(
                    color: isMe ? t.onPrimary : t.onSurface,
                  ),
                ),
                const SizedBox(height: BeaconSpace.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: text.labelSmall?.copyWith(
                        color: isMe
                            ? t.onPrimary.withValues(alpha: 0.7)
                            : t.onSurfaceMuted,
                      ),
                    ),
                    if (showDoubleTick) ...[
                      const SizedBox(width: BeaconSpace.xs),
                      Icon(Icons.done_all_rounded,
                          color: t.onPrimary.withValues(alpha: 0.8), size: 14),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
