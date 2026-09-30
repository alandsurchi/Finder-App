import 'package:flutter/material.dart';
import 'package:finder/core/utils/hero_tags.dart';
import 'package:finder/features/posts/presentation/item_details_args.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/ui/item_card.dart';

/// Compact card for the "similar items" rail on the details screen.
class SimilarCard extends StatelessWidget {
  final ItemModel item;
  final String? heroScope;
  final String? matchedPostId;

  const SimilarCard({super.key, required this.item, this.heroScope, this.matchedPostId});

  @override
  Widget build(BuildContext context) {
    // The rail is a horizontal list, so the card must bring its own width.
    return SizedBox(
      width: 300,
      child: ItemCard(
        item: item,
        layout: ItemCardLayout.compact,
        heroTag: heroScope == null ? null : HeroTags.item(heroScope!, item.id),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.itemDetails,
            arguments: ItemDetailsArgs(
              item,
              heroTag: heroScope == null ? null : HeroTags.item(heroScope!, item.id),
              matchedPostId: matchedPostId,
            ),
          );
        },
      ),
    );
  }
}
