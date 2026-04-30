import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/cards/conversation_card.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final conversationsState = ref.watch(conversationsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ActionFeedback.showComingSoon(context, feature: 'New conversation'),
        backgroundColor: t.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Icon(
          Icons.edit_outlined,
          color: t.isDark ? Colors.black : Colors.white,
          size: 22,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text(
                'Messages',
                style: TextStyle(
                  color: t.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search, color: t.onSurfaceMuted, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearch,
                        style: TextStyle(color: t.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          hintStyle: TextStyle(
                            color: t.onSurfaceMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── List
            Expanded(
              child: conversationsState.when(
                loading: () =>
                    const LoadingWidget(message: 'Loading conversations...'),
                error: (err, _) => ErrorStateWidget(message: err.toString()),
                data: (items) {
                  final filteredItems = _query.isEmpty
                      ? items
                      : items.where((c) {
                          final q = _query.toLowerCase();
                          // In the future, c.name will be resolved asynchronously. 
                          // For now, if we don't have it, we just use empty string.
                          return c.name.toLowerCase().contains(q) ||
                                 c.message.toLowerCase().contains(q);
                        }).toList();
                        
                  if (filteredItems.isEmpty) {
                    return const EmptyWidget(
                      title: 'No conversations found',
                      subtitle:
                          'Messages will appear here once you start chatting.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, i) =>
                        ConversationCard(convo: filteredItems[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
