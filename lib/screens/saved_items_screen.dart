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
import 'package:finder/l10n/l10n.dart';

class SavedItemsScreen extends ConsumerWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedState = ref.watch(savedItemsProvider);
    final count = savedState.value?.length;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: l10n.postSavedItems,
              subtitle: count == null
                  ? l10n.postSavedSubtitle
                  : l10n.postSavedCount(count),
            ),
            Expanded(
              child: savedState.when(
                loading: () => LoadingWidget(
                  message: l10n.postLoadingSaved,
                  variant: LoadingVariant.list,
                ),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () =>
                      ref.read(savedItemsProvider.notifier).loadSavedItems(),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyWidget(
                      icon: Icons.bookmark_border_rounded,
                      title: l10n.postNoSavedTitle,
                      subtitle: l10n.postNoSavedSubtitle,
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
                                  context, l10n.postRemovedFromSaved),
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
