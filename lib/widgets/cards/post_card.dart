import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/screens/manage_post_screen.dart';

class PostCard extends StatelessWidget {
  final ItemModel post;

  const PostCard({super.key, required this.post});

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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  post.imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      color: t.surfaceHigh,
                    ),
                    child: Center(
                      child: Icon(
                        post.isLost
                            ? Icons.account_balance_wallet_outlined
                            : Icons.pets,
                        color: t.onSurfaceMuted,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: post.isLost ? t.warning : t.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.isLost ? 'LOST' : 'FOUND',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    post.timeAgo, // Used timeAgo instead of date
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: TextStyle(
                          color: t.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (post.reward != null) ...[
                      // Has Reward
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: t.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: t.warning.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              color: t.warning,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'REWARD',
                              style: TextStyle(
                                color: t.warning,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: t.onSurfaceMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.location,
                      style: TextStyle(color: t.onSurfaceVar, fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: t.primary,
                            foregroundColor: t.isDark
                                ? Colors.black
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ManagePostScreen(
                                  post: ManagePostData(
                                    title: post.title,
                                    imagePath: post.imagePath,
                                    isLost: post.isLost,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Manage Post',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.divider),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          color: t.primary,
                          size: 18,
                        ),
                        onPressed: () async {
                          final summary =
                              '${post.isLost ? 'Lost' : 'Found'} item: ${post.title}\n'
                              'Location: ${post.location}\n'
                              'Details: ${post.description}';
                          await Clipboard.setData(ClipboardData(text: summary));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Post details copied to clipboard.',
                              ),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
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
