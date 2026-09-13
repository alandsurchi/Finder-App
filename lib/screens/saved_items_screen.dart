import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/widgets/cards/saved_card.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/features/posts/presentation/saved_items_controller.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/widgets/common/action_feedback.dart';

class SavedItemsScreen extends ConsumerWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedState = ref.watch(savedItemsProvider);
    final count = savedState.value?.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Saved items',
              subtitle: count == null
                  ? "Keep track of items you're helping to return or find."
                  : '$count saved · items you are helping to return or find',
            ),
            Expanded(
              child: savedState.when(
                loading: () => const LoadingWidget(
                  message: 'Loading saved items...',
                  variant: LoadingVariant.list,
                ),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () =>
                      ref.read(savedItemsProvider.notifier).loadSavedItems(),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyWidget(
                      icon: Icons.bookmark_border_rounded,
                      title: 'No saved items yet',
                      subtitle: 'Tap the bookmark on any post to keep it here.',
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      BeaconSpace.page,
                      BeaconSpace.xs,
                      BeaconSpace.page,
                      BeaconSpace.xxxl + MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.lg),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return StaggeredEntrance(
                        index: index.clamp(0, 6),
                        child: SavedCard(
                          item: item,
                          isSaved: true,
                          onToggleSave: () async {
                            final result = await ref
                                .read(savedItemsProvider.notifier)
                                .toggleSaved(item);
                            if (!context.mounted) return;
                            result.fold(
                              onSuccess: (_) => ActionFeedback.showInfo(
                                  context, 'Removed from saved items.'),
                              onFailure: (f) =>
                                  ActionFeedback.showError(context, f.message),
                            );
                          },
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
