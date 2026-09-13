import 'package:flutter/material.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/ui/app_button.dart';
import 'package:finder/widgets/ui/item_card.dart';

/// Saved-items card. Tapping opens the item; the bookmark toggles saving.
class SavedCard extends StatelessWidget {
  final ItemModel item;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const SavedCard({
    super.key,
    required this.item,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      item: item,
      imageHeight: 180,
      heroTag: 'item-image-${item.id}',
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: item),
      overlay: AppIconButton(
        icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        tooltip: isSaved ? 'Remove from saved' : 'Save item',
        variant: AppIconButtonVariant.glass,
        selected: isSaved,
        size: 40,
        iconSize: 20,
        onPressed: onToggleSave,
      ),
    );
  }
}
