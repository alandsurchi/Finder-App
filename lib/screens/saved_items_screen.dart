import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/widgets/cards/saved_card.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/features/posts/presentation/saved_items_controller.dart';

class SavedItemsScreen extends ConsumerWidget {
  const SavedItemsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final savedState = ref.watch(savedItemsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Saved Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Keep track of items you're helping to return or find.",
                  style: TextStyle(color: t.onSurfaceVar, fontSize: 13),
                ),
              ),
            ),

            Expanded(
              child: savedState.when(
                loading: () =>
                    const LoadingWidget(message: 'Loading saved items...'),
                error: (err, _) => ErrorStateWidget(message: err.toString()),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyWidget(
                      title: 'No saved items yet',
                      subtitle: 'Items you save will appear here.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SavedCard(
                          item: item,
                          isSaved: true,
                          onToggleSave: () => ref
                              .read(savedItemsProvider.notifier)
                              .toggleSaved(item),
                        ),
                      );
                    },
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
