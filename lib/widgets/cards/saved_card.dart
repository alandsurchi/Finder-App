import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/models/item_model.dart';

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

  Widget _buildFallback(AppColorTokens t) => Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: t.surfaceHigh,
        ),
        child: Center(
            child: Icon(
                item.isLost ? Icons.image_outlined : Icons.pets_outlined,
                size: 50,
                color: t.onSurfaceMuted)),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.imagePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallback(t),
                ),
              ),
              // LOST / FOUND badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: item.isLost ? t.warning : t.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(item.isLost ? 'LOST' : 'FOUND',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      )),
                ),
              ),
              // Reward badge
              if (item.reward != null)
                Positioned(
                  top: 46,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('REWARD \$${item.reward}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        )),
                  ),
                ),
              // Bookmark
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onToggleSave,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: t.surface.withOpacity(0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? t.primary : t.onSurfaceMuted,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Info
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyle(
                      color: t.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    )),
                const SizedBox(height: 6),
                Text(item.description,
                    style: TextStyle(
                        color: t.onSurfaceVar, fontSize: 13, height: 1.5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: t.onSurfaceMuted, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(item.location,
                            style: TextStyle(
                                color: t.onSurfaceVar, fontSize: 13),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: t.onSurfaceMuted, size: 13),
                    const SizedBox(width: 4),
                    Text(item.timeAgo,
                        style: TextStyle(
                            color: t.onSurfaceMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
