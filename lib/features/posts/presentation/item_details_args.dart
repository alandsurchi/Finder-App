import '../../../models/item_model.dart';

/// Arguments for the item details route.
///
/// [heroTag] is the tag of the image the user tapped, so the details page
/// can fly the same image; screens that open a post without a picture on
/// screen (notifications, links, chat) leave it null and get a plain
/// transition. [matchedPostId] is set when the post was opened from a
/// "possible match" notification: it is the viewer's own post the new one
/// may correspond to.
class ItemDetailsArgs {
  final ItemModel item;
  final String? heroTag;
  final String? matchedPostId;

  const ItemDetailsArgs(this.item, {this.heroTag, this.matchedPostId});

  /// Accepts both the new args and a bare [ItemModel] (older call sites).
  static ItemDetailsArgs? from(Object? args) {
    if (args is ItemDetailsArgs) return args;
    if (args is ItemModel) return ItemDetailsArgs(args);
    return null;
  }
}
