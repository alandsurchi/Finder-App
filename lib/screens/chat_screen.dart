import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildChatHeader(context, userName, itemName, t),
            Divider(color: t.divider, height: 1, thickness: 1),
            Expanded(
              child: messagesState.when(
                loading: () =>
                    const LoadingWidget(message: 'Loading messages...'),
                error: (err, _) => ErrorStateWidget(message: err.toString()),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const EmptyWidget(
                      title: 'No messages yet',
                      subtitle: 'Start the conversation by sending a message.',
                    );
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;
                      return _ChatBubble(
                        message: msg.text,
                        time: _formatTime(msg.createdAt.millisecondsSinceEpoch),
                        isMe: isMe,
                        showDoubleTick: isMe,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            onPressed: () => Navigator.maybePop(context),
          ),
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.surfaceHigh,
                  border: Border.all(color: t.divider, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Icon(Icons.person, color: t.onSurfaceVar, size: 26),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: t.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.bg, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (itemName.isNotEmpty)
                  Text(
                    'Re: $itemName',
                    style: TextStyle(
                      color: t.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'Online',
                    style: TextStyle(
                      color: t.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.white, size: 22),
            onPressed: () => ActionFeedback.showComingSoon(
              context,
              feature: 'Voice calling',
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.videocam_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => ActionFeedback.showComingSoon(
              context,
              feature: 'Video calling',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
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
    return Container(
      color: t.bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Plus Button
          GestureDetector(
            onTap: () => _showAttachmentOptions(t),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: t.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.add, color: t.primary, size: 26),
            ),
          ),
          const SizedBox(width: 12),
          // Text Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 120),
              decoration: BoxDecoration(
                color: t.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.only(left: 20, right: 6),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      style: TextStyle(color: t.onSurface, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: t.onSurfaceMuted,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: t.onSurfaceVar, size: 24),
                    onPressed: () => ActionFeedback.showComingSoon(
                      context,
                      feature: 'Voice message',
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send Button
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: t.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: t.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: t.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: t.primary),
              title: Text('Take a photo', style: TextStyle(color: t.onSurface)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: t.primary),
              title: Text('Send photos', style: TextStyle(color: t.onSurface)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.attach_file_outlined, color: t.primary),
              title: Text(
                'Attach a file',
                style: TextStyle(color: t.onSurface),
              ),
              onTap: () => Navigator.pop(context),
            ),
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

  const _ChatBubble({
    required this.message,
    required this.time,
    required this.isMe,
    this.showDoubleTick = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMe ? t.primary.withOpacity(0.18) : t.surfaceHigh,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isMe
                  ? const Radius.circular(18)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(18),
            ),
            border: Border.all(
              color: isMe ? t.primary.withOpacity(0.3) : t.divider,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: t.onSurface,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(color: t.onSurfaceMuted, fontSize: 11),
                  ),
                  if (showDoubleTick) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.done_all, color: t.primary, size: 14),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.divider, width: 1),
            color: t.surfaceHigh,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.surface,
                    boxShadow: [
                      BoxShadow(
                        color: t.primary.withOpacity(0.25),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: t.primary,
                    size: 38,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, t.bg],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  const _ToolbarIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return GestureDetector(
      onTap: () => ActionFeedback.showInfo(context, 'Toolbar action tapped.'),
      child: Icon(icon, color: t.onSurfaceVar, size: 22),
    );
  }
}
