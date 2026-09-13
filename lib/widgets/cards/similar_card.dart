import 'package:flutter/material.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/ui/item_card.dart';

/// Compact card for the "similar items" rail on the details screen.
class SimilarCard extends StatelessWidget {
  final ItemModel item;

  const SimilarCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // The rail is a horizontal list, so the card must bring its own width.
    return SizedBox(
      width: 300,
      child: ItemCard(
        item: item,
        layout: ItemCardLayout.compact,
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.itemDetails,
            arguments: item,
          );
        },
      ),
    );
  }
}
