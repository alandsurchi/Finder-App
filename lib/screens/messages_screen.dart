import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/chat/presentation/open_chat.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/widgets/cards/conversation_card.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/widgets/sheets/user_search_sheet.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  void _onSearch(String q) {
    setState(() => _query = q);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _newChat() async {
    final user = await showUserSearchSheet(
      context,
      title: 'New conversation',
      actionLabel: 'Message',
    );
    if (user == null || !mounted) return;
    await openChatWith(
      context,
      ref,
      peerId: user.uid,
      peerName: user.displayName,
      peerAvatarUrl: user.avatarUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationsState = ref.watch(conversationsStreamProvider);
    final unread = conversationsState.value
            ?.where((c) => c.unreadCount > 0)
            .length ??
        0;
    final navClearance = CustomBottomNavBar.totalHeight(context) + BeaconSpace.lg;

    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: CustomBottomNavBar.totalHeight(context) - 8),
        child: FloatingActionButton.extended(
          onPressed: _newChat,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('New chat'),
        ),
      ),
      body: BeaconBackdrop(
        alignment: const Alignment(1.2, -1.2),
        intensity: 0.8,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredEntrance(
                child: AppPageHeader(
                  title: 'Messages',
                  subtitle: unread > 0
                      ? '$unread unread conversation${unread == 1 ? '' : 's'}'
                      : 'Chat safely with owners and finders',
                  showBack: false,
                  large: true,
                  padding: const EdgeInsets.fromLTRB(
                      BeaconSpace.page, BeaconSpace.md, BeaconSpace.page, BeaconSpace.lg),
                ),
              ),

              StaggeredEntrance(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
                  child: SearchField(
                    controller: _searchCtrl,
                    hint: 'Search conversations…',
                    onChanged: _onSearch,
                  ),
                ),
              ),

              const SizedBox(height: BeaconSpace.lg),

              Expanded(
                child: conversationsState.when(
                  skipError: true,
                  loading: () => const LoadingWidget(
                    message: 'Loading conversations...',
                    variant: LoadingVariant.rows,
                  ),
                  error: (err, _) => ErrorStateWidget(
                    message: describeError(err),
                    onRetry: () => ref.invalidate(conversationsStreamProvider),
                  ),
                  data: (items) {
                    final filteredItems = _query.isEmpty
                        ? items
                        : items.where((c) {
                            final q = _query.toLowerCase();
                            return c.name.toLowerCase().contains(q) ||
                                c.itemName.toLowerCase().contains(q) ||
                                c.message.toLowerCase().contains(q);
                          }).toList();

                    if (filteredItems.isEmpty) {
                      return EmptyWidget(
                        icon: Icons.forum_outlined,
                        title: _query.isEmpty
                            ? 'No conversations yet'
                            : 'No conversations found',
                        subtitle: _query.isEmpty
                            ? 'Contact an owner or finder from any post, or start a new chat.'
                            : 'Try another name or keyword.',
                        actionLabel: _query.isEmpty ? 'New chat' : null,
                        onAction: _query.isEmpty ? _newChat : null,
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          BeaconSpace.page, 0, BeaconSpace.page, navClearance),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, i) {
                        final card = ConversationCard(convo: filteredItems[i]);
                        if (i >= 8) return card;
                        return StaggeredEntrance(
                          index: i,
                          baseDelay: const Duration(milliseconds: 35),
                          child: card,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
