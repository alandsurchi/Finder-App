import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finder/app/di/app_providers.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/features/chat/domain/message.dart';
import 'package:finder/features/chat/domain/chat_presence.dart';
import 'package:finder/features/chat/presentation/chat_widgets.dart';
import 'package:finder/features/chat/presentation/image_viewer_screen.dart';
import 'package:finder/features/chat/presentation/message_ticks.dart';
import 'package:finder/features/chat/presentation/photo_caption_sheet.dart';
import 'package:finder/features/chat/presentation/open_chat.dart';
import 'package:finder/features/chat/presentation/voice_message_bubble.dart';
import 'package:finder/features/chat/presentation/voice_player_controller.dart';
import 'package:finder/features/chat/presentation/voice_recorder_button.dart';
import 'package:finder/features/notifications/presentation/notifications_controller.dart';
import 'package:finder/features/posts/presentation/item_details_args.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:finder/routes.dart';
import 'package:finder/services/push/push_service.dart';
import 'package:finder/services/chat/chat_socket.dart' show conversationsRefreshTickProvider;
import 'package:finder/services/voice_recorder_service.dart';
import 'package:finder/widgets/sheets/image_source_sheet.dart';
import 'package:finder/models/conversation_model.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scroll = ScrollController();
  final Map<String, GlobalKey> _bubbleKeys = {};

  final GlobalKey<VoiceRecorderButtonState> _micKey = GlobalKey();
  bool _sending = false;
  bool _uploading = false;
  RecorderPhase _recorderPhase = RecorderPhase.idle;
  double _lockProgress = 0;
  bool _revealedUnread = false;
  bool _hasText = false;

  bool get _recording => _recorderPhase != RecorderPhase.idle;
  bool _awayFromBottom = false;
  int _newWhileAway = 0;
  int _lastCount = 0;
  String? _highlightId;
  String? _seenChatId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = _arg(ChatArgs.chatId);
    if (id.isEmpty) return;
    // Tell the push layer which chat is on screen so its messages refresh
    // the thread instead of showing a banner.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(activeChatIdProvider.notifier).state = id;
    });
    if (_seenChatId != id) {
      _seenChatId = id;
      _markSeen(id);
    }
  }

  @override
  void deactivate() {
    final id = _arg(ChatArgs.chatId);
    if (ref.read(activeChatIdProvider) == id) {
      ref.read(activeChatIdProvider.notifier).state = null;
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// The chat is on screen: its notifications count as seen, here and on
  /// the server, so the bell badge drops right away.
  void _markSeen(String chatId) {
    ref.read(notificationsControllerProvider.notifier).markChatSeen(chatId);
    ref.read(chatServiceProvider).markRead(chatId).then((_) {
      if (mounted) ref.invalidate(conversationsStreamProvider);
    }).catchError((_) {});
  }

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    return (args is Map) ? Map<String, dynamic>.from(args) : const {};
  }

  String _arg(String key, [String fallback = '']) =>
      _args[key]?.toString().trim().isNotEmpty == true
          ? _args[key].toString()
          : fallback;

  // ── Scrolling ──────────────────────────────────────────────────────────────

  void _onScroll() {
    if (!_scroll.hasClients) return;
    // The list is reversed: offset 0 is the newest message.
    final away = _scroll.offset > 240;
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
      final id = _arg(ChatArgs.chatId);
      if (id.isNotEmpty) ref.read(chatMessagesProvider(id).notifier).loadOlder();
    }
    if (away != _awayFromBottom) {
      setState(() {
        _awayFromBottom = away;
        if (!away) _newWhileAway = 0;
      });
    }
  }

  void _scrollToLatest({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      if (animate) {
        _scroll.animateTo(0, duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
      } else {
        _scroll.jumpTo(0);
      }
    });
  }

  Future<void> _revealMessage(String id) async {
    final key = _bubbleKeys[id];
    final ctx = key?.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(ctx,
          alignment: 0.4, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      _flash(id);
      return;
    }
    // Not built yet (far up): scroll towards the top and try again.
    if (_scroll.hasClients) {
      await _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      final again = _bubbleKeys[id]?.currentContext;
      if (again != null) {
        await Scrollable.ensureVisible(again,
            alignment: 0.4, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
        _flash(id);
      }
    }
  }

  void _flash(String id) {
    setState(() => _highlightId = id);
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _highlightId == id) setState(() => _highlightId = null);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;
    final chatId = _arg(ChatArgs.chatId);
    final userName = _arg(ChatArgs.userName, l10n.commonFinderUser);
    final itemName = _arg(ChatArgs.itemName);
    final peerId = _arg(ChatArgs.peerId);
    final peerAvatarUrl = _arg(ChatArgs.peerAvatarUrl);
    final postId = _arg(ChatArgs.postId);
    final peerIsAdmin = _arg(ChatArgs.peerAdmin) == '1';
    final currentUserId = ref.watch(authStateProvider).userId ?? '';
    final postOwnerId = _arg(ChatArgs.postOwnerId);
    final isPostOwner =
        postId.isNotEmpty && postOwnerId.isNotEmpty && postOwnerId == currentUserId;
    final liveStatus =
        isPostOwner ? ref.watch(postByIdProvider(postId)).value?.isResolved : null;
    final isReturned = liveStatus ?? (_arg(ChatArgs.postStatus) == 'resolved');

    if (chatId.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AppPageHeader(title: l10n.chatConversationTitle),
              Expanded(
                child: EmptyWidget(
                  icon: Icons.forum_outlined,
                  title: l10n.chatNotFoundTitle,
                  subtitle: l10n.chatNotFoundSubtitle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final messagesState = ref.watch(chatMessagesProvider(chatId));
    final replyDraft = ref.watch(replyDraftProvider(chatId));

    ref.listen(chatMessagesProvider(chatId), (prev, next) {
      final list = next.value;
      if (list == null) return;
      if (!_revealedUnread) {
        // Open where the reader left off, like WhatsApp.
        _revealedUnread = true;
        final firstUnread = ref.read(chatMessagesProvider(chatId).notifier).firstUnreadId;
        if (firstUnread != null) {
          _lastCount = list.length;
          WidgetsBinding.instance.addPostFrameCallback((_) => _revealMessage(firstUnread));
          return;
        }
      }
      final count = list.length;
      if (count == _lastCount) return;
      final grew = count > _lastCount;
      _lastCount = count;
      if (!grew) return;
      final last = list.last;
      final mine = last.senderId == currentUserId;
      if (mine || !_awayFromBottom) {
        _scrollToLatest();
      } else {
        setState(() => _newWhileAway++);
      }
      if (!mine) _markSeen(chatId);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildChatHeader(
              context,
              chatId: chatId,
              userName: userName,
              itemName: itemName,
              peerId: peerId,
              peerAvatarUrl: peerAvatarUrl,
              postId: postId,
              t: t,
              isPostOwner: isPostOwner,
              isReturned: isReturned,
              peerIsAdmin: peerIsAdmin,
            ),
            Divider(color: t.outlineVariant, height: 1, thickness: 1),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: messagesState.when(
                      loading: () => LoadingWidget(message: l10n.chatLoadingMessages),
                      error: (err, _) => ErrorStateWidget(
                        message: describeError(err),
                        onRetry: () => ref.read(chatMessagesProvider(chatId).notifier).load(),
                      ),
                      data: (messages) => _buildList(
                        context,
                        chatId: chatId,
                        messages: messages,
                        currentUserId: currentUserId,
                        userName: userName,
                        itemName: itemName,
                      ),
                    ),
                  ),
                  if (_awayFromBottom)
                    PositionedDirectional(
                      end: BeaconSpace.lg,
                      bottom: BeaconSpace.md,
                      child: ScrollToLatestPill(
                        newCount: _newWhileAway,
                        onTap: _scrollToLatest,
                      ),
                    ),
                ],
              ),
            ),
            if (replyDraft != null)
              _buildReplyBar(t, chatId, replyDraft, currentUserId, userName),
            _buildInputArea(t, chatId, replyDraft),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context, {
    required String chatId,
    required List<Message> messages,
    required String currentUserId,
    required String userName,
    required String itemName,
  }) {
    if (messages.isEmpty) {
      final l10n = context.l10n;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismissKeyboard,
        child: EmptyWidget(
          icon: Icons.forum_outlined,
          title: l10n.chatSayHello(userName),
          subtitle: itemName.isEmpty
              ? l10n.chatStartSubtitle
              : l10n.chatAskAbout(itemName),
        ),
      );
    }

    // Newest first: the list is reversed so the bottom stays put when
    // messages arrive and the keyboard opens.
    final ordered = messages.reversed.toList(growable: false);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _dismissKeyboard,
      child: ListView.builder(
        controller: _scroll,
        reverse: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(
          horizontal: BeaconSpace.lg,
          vertical: BeaconSpace.lg,
        ),
        itemCount: ordered.length + 1,
        itemBuilder: (context, index) {
          if (index == ordered.length) {
            final ctrl = ref.watch(chatMessagesProvider(chatId).notifier);
            return ctrl.loadingOlder
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: BeaconSpace.md),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                : const SizedBox.shrink();
          }
          final msg = ordered[index];
          final older = index + 1 < ordered.length ? ordered[index + 1] : null;
          final newer = index > 0 ? ordered[index - 1] : null;
          final isMe = msg.senderId == currentUserId;
          final day = DateTime.fromMillisecondsSinceEpoch(msg.createdAt.millisecondsSinceEpoch);
          final olderDay = older == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(older.createdAt.millisecondsSinceEpoch);
          final newDay = olderDay == null ||
              olderDay.year != day.year ||
              olderDay.month != day.month ||
              olderDay.day != day.day;
          final continued = !newDay && older != null && older.senderId == msg.senderId;
          final tight = newer != null && newer.senderId == msg.senderId;
          final key = _bubbleKeys.putIfAbsent(msg.messageId, GlobalKey.new);

          final ctrl = ref.read(chatMessagesProvider(chatId).notifier);
          return Column(
            key: key,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (newDay) DaySeparator(day: day),
              if (ctrl.firstUnreadId == msg.messageId && ctrl.unreadOnOpen > 0)
                UnreadDivider(count: ctrl.unreadOnOpen),
              Padding(
                padding: EdgeInsets.only(bottom: tight ? BeaconSpace.xs : BeaconSpace.sm),
                child: SwipeToReply(
                  enabled: !msg.deleted && !msg.failed && !msg.isLocal,
                  onReply: () => _setReply(chatId, msg),
                  child: _ChatBubble(
                    message: msg,
                    isMe: isMe,
                    continued: continued,
                    highlighted: _highlightId == msg.messageId,
                    peerName: userName,
                    onLongPress: () => _showMessageActions(chatId, msg, isMe),
                    onQuoteTap: msg.replyTo == null ? null : () => _revealMessage(msg.replyTo!.id),
                    onRetry: msg.failed ? () => _retry(chatId, msg.messageId) : null,
                    onDiscard: msg.failed
                        ? () => ref.read(chatMessagesProvider(chatId).notifier).discard(msg.messageId)
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildChatHeader(
    BuildContext context, {
    required String chatId,
    required String userName,
    required String itemName,
    required String peerId,
    required String peerAvatarUrl,
    required String postId,
    required AppColorTokens t,
    required bool isPostOwner,
    required bool isReturned,
    required bool peerIsAdmin,
  }) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final canOpenProfile = peerId.isNotEmpty;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        BeaconSpace.md,
        BeaconSpace.sm,
        BeaconSpace.sm,
        BeaconSpace.sm,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: l10n.commonBack,
            variant: AppIconButtonVariant.ghost,
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: BeaconSpace.xs),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BeaconRadius.rLg,
                onTap: canOpenProfile ? () => _openProfile(peerId) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xs, horizontal: BeaconSpace.xs),
                  child: Row(
                    children: [
                      AppAvatar(url: peerAvatarUrl, name: userName, size: 44),
                      const SizedBox(width: BeaconSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NameWithMarks(
                              name: userName,
                              verified: _arg(ChatArgs.peerVerified) == '1',
                              admin: peerIsAdmin,
                              style: text.titleMedium,
                            ),
                            _PresenceLine(chatId: chatId, peerId: peerId),
                            if (itemName.isNotEmpty)
                              InkWell(
                                borderRadius: BeaconRadius.rSm,
                                onTap: postId.isEmpty ? null : () => _openPost(postId, itemName),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 12, color: t.primary),
                                      const SizedBox(width: BeaconSpace.xs),
                                      Flexible(
                                        child: Text(
                                          itemName,
                                          style: text.labelSmall?.copyWith(
                                            color: t.primary,
                                            decoration: postId.isEmpty ? null : TextDecoration.underline,
                                            decorationColor: t.primary.withValues(alpha: 0.5),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (postId.isNotEmpty)
                                        Icon(Icons.chevron_right_rounded, size: 14, color: t.primary),
                                      if (isReturned) ...[
                                        const SizedBox(width: BeaconSpace.xs),
                                        StatusBadge.resolved(small: true),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                            else
                              Text(
                                canOpenProfile ? l10n.chatDirectMessageViewProfile : l10n.chatDirectMessage,
                                style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AppIconButton(
            icon: Icons.more_vert_rounded,
            tooltip: l10n.commonMoreOptions,
            variant: AppIconButtonVariant.ghost,
            onPressed: () => _showMoreSheet(
                userName, peerId, postId, itemName, isPostOwner, isReturned, peerIsAdmin),
          ),
        ],
      ),
    );
  }

  void _openProfile(String peerId) {
    Navigator.pushNamed(context, AppRoutes.userProfile, arguments: peerId);
  }

  Future<void> _openPost(String postId, String itemName) async {
    try {
      final post = await ref.read(postServiceProvider).fetchById(postId);
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: ItemDetailsArgs(post));
    } catch (e) {
      if (!mounted) return;
      ActionFeedback.showError(context, describeError(e));
    }
  }

  void _showMoreSheet(
    String userName,
    String peerId,
    String postId,
    String itemName,
    bool isPostOwner,
    bool isReturned,
    bool peerIsAdmin,
  ) {
    final l10n = context.l10n;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: userName,
        subtitle: itemName.isEmpty ? null : l10n.chatAboutItem(itemName),
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (peerId.isNotEmpty)
              SheetOption(
                icon: Icons.person_outline_rounded,
                label: l10n.commonViewProfile,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _openProfile(peerId);
                },
              ),
            if (isPostOwner)
              SheetOption(
                icon: isReturned ? Icons.replay_rounded : Icons.assignment_turned_in_outlined,
                label: isReturned ? l10n.chatReopenPost : l10n.commonMarkAsReturned,
                subtitle: isReturned ? l10n.chatReopenSubtitle : l10n.chatReturnedSubtitle,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmReturned(postId, itemName, isReturned);
                },
              ),
            if (postId.isNotEmpty)
              SheetOption(
                icon: Icons.inventory_2_outlined,
                label: l10n.chatViewPost,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _openPost(postId, itemName);
                },
              ),
            if (postId.isNotEmpty)
              SheetOption(
                icon: Icons.flag_outlined,
                label: l10n.chatReportPost,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  try {
                    await ref.read(postServiceProvider).reportPost(postId, 'Reported from chat');
                    if (!mounted) return;
                    ActionFeedback.showSuccess(context, l10n.chatPostReported);
                  } catch (e) {
                    if (!mounted) return;
                    ActionFeedback.showError(context, describeError(e));
                  }
                },
              ),
            if (peerId.isNotEmpty && !peerIsAdmin)
              SheetOption(
                icon: Icons.block_rounded,
                label: l10n.blockUserLabel(userName),
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

  /// Owner shortcut: mark the post returned (or reopen it) from the chat.
  Future<void> _confirmReturned(String postId, String itemName, bool isReturned) async {
    final chatId = _arg(ChatArgs.chatId);
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isReturned ? l10n.chatReopenTitle : l10n.chatMarkReturnedTitle),
        content: Text(
          isReturned ? l10n.chatReopenBody(itemName) : l10n.chatMarkReturnedBody(itemName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isReturned ? l10n.commonReopen : l10n.commonMarkAsReturned),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final notifier = ref.read(myPostsProvider.notifier);
    final result = isReturned ? await notifier.reopen(postId) : await notifier.markResolved(postId);
    if (!mounted) return;
    result.fold(
      onSuccess: (_) async {
        ref.invalidate(postByIdProvider(postId));
        ref.invalidate(conversationsStreamProvider);
        ActionFeedback.showSuccess(
            context, isReturned ? l10n.chatPostReopened : l10n.commonMarkedAsReturned);
        if (chatId.isNotEmpty) {
          await ref.read(chatMessagesProvider(chatId).notifier).send(
                text: isReturned ? l10n.chatAutoReopened : l10n.chatAutoReturned,
              );
        }
      },
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  void _confirmBlock(String userName, String peerId) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.blockUserTitle(userName)),
        content: Text(l10n.blockChatConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: t.error, foregroundColor: t.onError),
            onPressed: () async {
              Navigator.pop(ctx);
              final result =
                  await ref.read(blockedUsersProvider.notifier).blockUser(peerId, name: userName);
              if (!mounted) return;
              result.fold(
                onSuccess: (_) {
                  ActionFeedback.showSuccess(context, l10n.blockUserDone(userName));
                  Navigator.pop(context);
                },
                onFailure: (f) => ActionFeedback.showError(context, f.message),
              );
            },
            child: Text(l10n.commonBlock),
          ),
        ],
      ),
    );
  }

  // ── Message actions ────────────────────────────────────────────────────────

  void _setReply(String chatId, Message msg) {
    ref.read(replyDraftProvider(chatId).notifier).state = ReplyPreview.ofMessage(msg);
    _focus.requestFocus();
  }

  void _showMessageActions(String chatId, Message msg, bool isMe) {
    HapticFeedback.selectionClick();
    final l10n = context.l10n;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: isMe ? l10n.chatYourMessage : l10n.chatMessage,
        subtitle: msg.text.isNotEmpty
            ? (msg.text.length > 80 ? '${msg.text.substring(0, 79)}…' : msg.text)
            : (msg.hasAudio ? l10n.msgVoiceMessage : (msg.hasImage ? l10n.msgPhoto : null)),
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!msg.deleted && !msg.isLocal)
              SheetOption(
                icon: Icons.reply_rounded,
                label: l10n.chatReply,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _setReply(chatId, msg);
                },
              ),
            if (!msg.deleted && !msg.isLocal)
              SheetOption(
                icon: Icons.shortcut_rounded,
                label: l10n.chatForward,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _forward(msg);
                },
              ),
            if (msg.text.isNotEmpty)
              SheetOption(
                icon: Icons.copy_rounded,
                label: l10n.chatCopyText,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await Clipboard.setData(ClipboardData(text: msg.text));
                  if (!mounted) return;
                  ActionFeedback.showInfo(context, l10n.commonCopied);
                },
              ),
            if (msg.failed) ...[
              SheetOption(
                icon: Icons.refresh_rounded,
                label: l10n.commonTryAgain,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _retry(chatId, msg.messageId);
                },
              ),
              SheetOption(
                icon: Icons.delete_outline_rounded,
                label: l10n.commonDiscard,
                destructive: true,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  ref.read(chatMessagesProvider(chatId).notifier).discard(msg.messageId);
                },
              ),
            ] else ...[
              if (!msg.isLocal)
                SheetOption(
                  icon: Icons.visibility_off_outlined,
                  label: l10n.chatDeleteForMe,
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    final r = await ref.read(chatMessagesProvider(chatId).notifier).hideMessage(msg.messageId);
                    if (!mounted) return;
                    r.fold(onSuccess: (_) {}, onFailure: (f) => ActionFeedback.showError(context, f.message));
                  },
                ),
              if (isMe && !msg.deleted && !msg.isLocal)
                SheetOption(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.chatDeleteForEveryone,
                  destructive: true,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _confirmDelete(chatId, msg);
                  },
                ),
            ],
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  /// Pick another conversation and send a copy of [msg] there.
  void _forward(Message msg) {
    final l10n = context.l10n;
    final me = ref.read(authStateProvider).userId ?? '';
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => Consumer(
        builder: (context, ref, _) {
          final convos = ref.watch(conversationsStreamProvider).value ?? const <ConversationModel>[];
          return AppBottomSheet(
            title: l10n.chatForwardTo,
            child: convos.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(BeaconSpace.lg),
                    child: Text(l10n.msgNoConversations, style: Theme.of(context).textTheme.bodyMedium),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final c in convos)
                        SheetOption(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: c.name,
                          subtitle: c.itemName.isEmpty ? null : c.itemName,
                          onTap: () async {
                            Navigator.pop(sheetCtx);
                            try {
                              await ref.read(chatServiceProvider).sendMessage(c.chatId, forwardOf: msg.messageId);
                              ref.read(conversationsRefreshTickProvider.notifier).state++;
                              if (c.chatId == _arg(ChatArgs.chatId)) {
                                ref.read(chatMessagesProvider(c.chatId).notifier).load();
                              }
                              if (!mounted) return;
                              ActionFeedback.showSuccess(this.context, l10n.chatForwardSent);
                            } catch (e) {
                              if (!mounted) return;
                              ActionFeedback.showError(this.context, describeError(e));
                            }
                          },
                        ),
                      const SizedBox(height: BeaconSpace.lg),
                    ],
                  ),
          );
        },
      ),
    );
    // `me` keeps the sender id handy for future per-chat rules.
    assert(me.isNotEmpty || true);
  }

  Future<void> _confirmDelete(String chatId, Message msg) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatDeleteTitle),
        content: Text(l10n.chatDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final result = await ref.read(chatMessagesProvider(chatId).notifier).deleteMessage(msg.messageId);
    if (!mounted) return;
    result.fold(
      onSuccess: (_) => ref.invalidate(conversationsStreamProvider),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  // ── Composer ───────────────────────────────────────────────────────────────

  Widget _buildReplyBar(
      AppColorTokens t, String chatId, ReplyPreview reply, String currentUserId, String userName) {
    return Container(
      color: t.surface,
      padding: const EdgeInsetsDirectional.fromSTEB(BeaconSpace.lg, BeaconSpace.sm, BeaconSpace.md, 0),
      child: ReplyQuote(
        reply: reply,
        authorName: reply.senderId == currentUserId ? context.l10n.commonYou : userName,
        onTap: () => _revealMessage(reply.id),
        onClose: () => ref.read(replyDraftProvider(chatId).notifier).state = null,
      ),
    );
  }

  Widget _buildInputArea(AppColorTokens t, String chatId, ReplyPreview? replyDraft) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final recorder = ref.read(voiceRecorderProvider);
    final canRecord = !kIsWeb && recorder.supported;
    final showMic = canRecord && (!_hasText || _recording) && !_sending;

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
          if (!_recording) ...[
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
                    tooltip: l10n.chatSendPhoto,
                    size: 48,
                    variant: AppIconButtonVariant.tonal,
                    onPressed: () => _sendPhoto(chatId),
                  ),
            const SizedBox(width: BeaconSpace.sm),
          ],
          Expanded(
            child: _recording
                ? VoiceRecordingBar(
                    recorder: recorder,
                    locked: _recorderPhase == RecorderPhase.locked,
                    lockProgress: _lockProgress,
                    onCancel: () => _micKey.currentState?.cancelFromBar(),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.surfaceLow,
                      borderRadius: BeaconRadius.rXxl,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.lg),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onChanged: (v) => ref
                            .read(chatMessagesProvider(chatId).notifier)
                            .sendTyping(v.trim().isNotEmpty),
                        onSubmitted: (_) => _sendText(chatId),
                        style: text.bodyLarge,
                        cursorColor: t.primary,
                        decoration: InputDecoration(
                          hintText: replyDraft != null ? l10n.chatWriteReplyHint : l10n.chatTypeMessageHint,
                          hintStyle: text.bodyLarge?.copyWith(color: t.onSurfaceMuted),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: BeaconSpace.md),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: BeaconSpace.sm),
          AnimatedSwitcher(
            duration: BeaconMotion.scaled(context, BeaconMotion.press),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: showMic
                ? VoiceRecorderButton(
                    key: _micKey,
                    recorder: recorder,
                    onPhaseChanged: (p) => setState(() {
                      _recorderPhase = p;
                      if (p != RecorderPhase.holding) _lockProgress = 0;
                    }),
                    onLockProgress: (v) => setState(() => _lockProgress = v),
                    onPermissionDenied: () =>
                        ActionFeedback.showError(context, l10n.chatMicPermission),
                    onRecorded: (rec) => _sendVoice(chatId, rec),
                  )
                : AppIconButton(
                    key: const ValueKey('send'),
                    icon: Icons.send_rounded,
                    tooltip: l10n.chatSendMessage,
                    size: 48,
                    variant: AppIconButtonVariant.filled,
                    onPressed: _sending ? null : () => _sendText(chatId),
                  ),
          ),
        ],
      ),
    );
  }

  ReplyPreview? _takeReply(String chatId) {
    final reply = ref.read(replyDraftProvider(chatId));
    if (reply != null) ref.read(replyDraftProvider(chatId).notifier).state = null;
    return reply;
  }

  Future<void> _sendText(String chatId) async {
    final value = _controller.text.trim();
    if (value.isEmpty || _sending) return;
    _controller.clear();
    ref.read(chatMessagesProvider(chatId).notifier).sendTyping(false);
    setState(() => _sending = true);
    final reply = _takeReply(chatId);
    final result =
        await ref.read(chatMessagesProvider(chatId).notifier).send(text: value, replyTo: reply);
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      onSuccess: (_) => ref.invalidate(conversationsStreamProvider),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Future<void> _sendVoice(String chatId, VoiceRecording rec) async {
    final reply = _takeReply(chatId);
    final result = await ref.read(chatMessagesProvider(chatId).notifier).send(
          localAudioPath: rec.path,
          audioMs: rec.durationMs,
          waveform: rec.waveform,
          replyTo: reply,
        );
    if (!mounted) return;
    result.fold(
      onSuccess: (_) => ref.invalidate(conversationsStreamProvider),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Future<void> _sendPhoto(String chatId) async {
    final source = await showImageSourceSheet(context, title: context.l10n.chatSendPhoto);
    if (source == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final uploads = ref.read(imageUploadServiceProvider);
      final bytes = await uploads.pickBytes(source: source);
      if (bytes == null || !mounted) return;
      final caption = await showPhotoCaptionSheet(context, bytes);
      if (caption == null || !mounted) return;
      final url = await uploads.uploadBytes(bytes, folder: 'chat');
      if (!mounted) return;
      final reply = _takeReply(chatId);
      final result = await ref
          .read(chatMessagesProvider(chatId).notifier)
          .send(text: caption, imageUrl: url, replyTo: reply);
      if (!mounted) return;
      result.fold(
        onSuccess: (_) => ref.invalidate(conversationsStreamProvider),
        onFailure: (f) => ActionFeedback.showError(context, f.message),
      );
    } catch (e) {
      if (mounted) {
        ActionFeedback.showError(context, context.l10n.photoUploadFailed(describeError(e)));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _retry(String chatId, String localId) async {
    final result = await ref.read(chatMessagesProvider(chatId).notifier).retry(localId);
    if (!mounted) return;
    result.fold(
      onSuccess: (_) {},
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }
}

class _ChatBubble extends ConsumerWidget {
  final Message message;
  final bool isMe;
  final bool continued;
  final bool highlighted;
  final String peerName;
  final VoidCallback? onLongPress;
  final VoidCallback? onQuoteTap;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.peerName,
    this.continued = false,
    this.highlighted = false,
    this.onLongPress,
    this.onQuoteTap,
    this.onRetry,
    this.onDiscard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    const r = Radius.circular(BeaconRadius.xl);
    const tail = Radius.circular(6);
    final failed = message.failed;
    final deleted = message.deleted;
    final bg = failed ? t.errorSurface : (isMe ? t.primary : t.surface);
    final fg = failed ? t.error : (isMe ? t.onPrimary : t.onSurface);
    final meta = failed ? t.error : (isMe ? t.onPrimary.withValues(alpha: 0.7) : t.onSurfaceMuted);
    final mediaOnly = (message.hasImage || message.hasAudio) && message.text.isEmpty;
    final replyTo = message.replyTo;

    final bubble = AnimatedContainer(
      duration: BeaconMotion.scaled(context, BeaconMotion.state),
      padding: message.hasImage && !deleted
          ? const EdgeInsets.all(BeaconSpace.xs)
          : const EdgeInsets.fromLTRB(BeaconSpace.lg, BeaconSpace.md, BeaconSpace.lg, BeaconSpace.sm),
      decoration: BoxDecoration(
        color: highlighted ? Color.alphaBlend(t.accent.withValues(alpha: 0.35), bg) : bg,
        borderRadius: BorderRadiusDirectional.only(
          topStart: (!isMe && continued) ? tail : r,
          topEnd: (isMe && continued) ? tail : r,
          bottomStart: isMe ? r : tail,
          bottomEnd: isMe ? tail : r,
        ),
        border: (isMe && !failed) ? null : Border.all(color: failed ? t.error : t.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyTo != null && !deleted)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  message.hasImage ? BeaconSpace.xs : 0, 0, message.hasImage ? BeaconSpace.xs : 0, BeaconSpace.sm),
              child: ReplyQuote(
                reply: replyTo,
                authorName: replyTo.senderId == message.senderId
                    ? (isMe ? l10n.commonYou : peerName)
                    : (isMe ? peerName : l10n.commonYou),
                onPrimary: isMe && !failed,
                onTap: onQuoteTap,
              ),
            ),
          if (!deleted && message.forwarded)
            Padding(
              padding: const EdgeInsets.only(bottom: BeaconSpace.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shortcut_rounded, size: 13, color: meta),
                  const SizedBox(width: BeaconSpace.xs),
                  Text(l10n.chatForwarded,
                      style: text.labelSmall?.copyWith(color: meta, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          if (deleted)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block_rounded, size: 14, color: meta),
                const SizedBox(width: BeaconSpace.xs),
                Text(
                  l10n.msgDeleted,
                  style: text.bodyMedium?.copyWith(color: meta, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          if (!deleted && message.hasImage)
            Semantics(
              button: true,
              label: l10n.chatOpenPhoto,
              child: GestureDetector(
                onTap: () => ImageViewerScreen.open(context, message.imageUrl, heroTag: 'msg-${message.messageId}'),
                child: Hero(
                  tag: 'msg-${message.messageId}',
                  child: ClipRRect(
                    borderRadius: BeaconRadius.rLg,
                    child: ItemImage(
                      url: message.imageUrl,
                      width: 220,
                      height: 220,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.image_outlined,
                    ),
                  ),
                ),
              ),
            ),
          if (!deleted && message.hasAudio)
            VoiceMessageBubble(message: message, isMe: isMe && !failed, fg: fg, muted: meta),
          if (!deleted && message.text.isNotEmpty)
            Padding(
              padding: message.hasImage
                  ? const EdgeInsets.fromLTRB(BeaconSpace.md, BeaconSpace.sm, BeaconSpace.md, 0)
                  : EdgeInsets.zero,
              child: SelectionContainer.disabled(
                child: Text(message.text, style: text.bodyLarge?.copyWith(color: fg)),
              ),
            ),
          Padding(
            padding: message.hasImage && !deleted
                ? const EdgeInsets.fromLTRB(BeaconSpace.md, BeaconSpace.xs, BeaconSpace.md, BeaconSpace.xs)
                : EdgeInsets.only(top: mediaOnly ? 0 : BeaconSpace.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  failed ? l10n.chatNotSent : clockTime(message.createdAt.millisecondsSinceEpoch),
                  style: text.labelSmall?.copyWith(color: meta),
                ),
                if (isMe && !failed && !deleted) ...[
                  const SizedBox(width: BeaconSpace.xs),
                  MessageTicks(message: message, color: meta),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Semantics(
          label: isMe ? l10n.chatYouSaid : l10n.chatTheySaid,
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: onLongPress,
                child: AnimatedOpacity(
                  duration: BeaconMotion.scaled(context, BeaconMotion.state),
                  opacity: message.isPending ? 0.72 : 1,
                  child: bubble,
                ),
              ),
              if (failed)
                Padding(
                  padding: const EdgeInsets.only(top: BeaconSpace.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton.ghost(
                        label: l10n.commonRetry,
                        icon: Icons.refresh_rounded,
                        size: AppButtonSize.small,
                        onPressed: onRetry,
                      ),
                      AppButton.ghost(
                        label: l10n.commonDiscard,
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

/// Keeps the shared voice player alive while any chat is open and stops
/// it when the screen goes away.
class VoicePlayerScope extends ConsumerWidget {
  final Widget child;
  const VoicePlayerScope({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(voicePlayerProvider);
    return child;
  }
}

/// "typing…", "online" or "last seen …" under the peer's name.
class _PresenceLine extends ConsumerWidget {
  final String chatId;
  final String peerId;
  const _PresenceLine({required this.chatId, required this.peerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final typing = chatId.isEmpty ? false : ref.watch(typingProvider(chatId));
    PresenceInfo? presence = peerId.isEmpty ? null : ref.watch(presenceProvider)[peerId];
    if (presence == null) {
      final convo = (ref.watch(conversationsStreamProvider).value ?? const <ConversationModel>[])
          .where((c) => c.chatId == chatId)
          .firstOrNull;
      if (convo != null && (convo.isOnline || convo.peerLastSeenMs != null)) {
        presence = PresenceInfo(online: convo.isOnline, lastSeenMs: convo.peerLastSeenMs);
      }
    }
    String? label;
    Color color = t.onSurfaceMuted;
    if (typing) {
      label = l10n.chatTyping;
      color = t.primary;
    } else if (presence != null && presence.online) {
      label = l10n.chatOnline;
      color = t.found;
    } else if (presence?.lastSeenMs != null) {
      label = l10n.chatLastSeen(relativeTime(presence!.lastSeenMs, l10n: l10n));
    }
    return AnimatedSize(
      duration: BeaconMotion.scaled(context, BeaconMotion.state),
      alignment: AlignmentDirectional.topStart,
      child: label == null
          ? const SizedBox.shrink()
          : Text(label, style: text.labelSmall?.copyWith(color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
