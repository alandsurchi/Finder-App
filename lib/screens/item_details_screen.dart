import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/features/posts/presentation/similar_items_provider.dart';
import 'package:finder/widgets/cards/similar_card.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/providers/user_provider.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsScreen extends ConsumerWidget {
  const ItemDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final item = (args is ItemModel) ? args : ItemModel.empty();
    final title = item.title.isEmpty ? 'Item Details' : item.title;
    final description = item.description.isEmpty
        ? 'No description provided yet.'
        : item.description;

    final t = AppColorTokens.of(context);
    final ownerProfileAsync = ref.watch(userProfileProvider(item.ownerId));
    final currentUserId = ref.watch(authStateProvider).userId ?? '';
    final isOwner = currentUserId.isNotEmpty && currentUserId == item.ownerId;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ── Hero image + app bar ──────────────────────────────────────
          _buildSliverAppBar(context, item),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badges ──────────────────────────────────────────
                  Row(
                    children: [
                      _badge(
                        item.isLost ? 'LOST' : 'FOUND',
                        item.isLost ? t.error : t.success,
                        t,
                      ),
                      if (item.reward != null) ...[
                        const SizedBox(width: 8),
                        _badge('REWARD: \$${item.reward}', t.warning, t),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Title ───────────────────────────────────────────
                  Text(
                    item.isResolved ? '$title (RESOLVED)' : title,
                    style: TextStyle(
                      color: item.isResolved
                          ? Colors.white.withOpacity(0.55)
                          : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      decoration: item.isResolved ? TextDecoration.lineThrough : null,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Description ─────────────────────────────────────
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Detail rows card ─────────────────────────────────
                  _buildDetailsCard(item, context, t),

                  const SizedBox(height: 16),

                  // ── "I Found This Item" button ───────────────────────
                  if (item.isLost)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.primary,
                          foregroundColor: t.isDark
                              ? Colors.black
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final ownerName =
                              (item.ownerName == null ||
                                  item.ownerName!.isEmpty)
                              ? 'Finder User'
                              : item.ownerName!;
                          
                          final ownerId = item.ownerId;
                          final currentUserId = ref.read(authStateProvider).userId ?? '';
                          if (currentUserId.isEmpty) {
                            ActionFeedback.showInfo(context, 'Please log in to message the owner.');
                            return;
                          }
                          if (ownerId.isEmpty || ownerId == currentUserId) {
                            ActionFeedback.showInfo(context, 'You cannot message yourself.');
                            return;
                          }
                          
                          try {
                            // Show loading visually if you want, but for now just await
                            final chatService = ref.read(chatServiceProvider);
                            final chatId = await chatService.createOrGetChat(currentUserId, ownerId, item.id, item.title);
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.chat,
                                arguments: {
                                  'chatId': chatId,
                                  'userName': ownerName,
                                },
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ActionFeedback.showInfo(context, 'Error creating chat: $e');
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.volunteer_activism_outlined,
                          size: 20,
                        ),
                        label: const Text(
                          'I Found This Item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── Owner card ───────────────────────────────────────
                  _buildOwnerCard(item, ownerProfileAsync, context, ref, t),

                  const SizedBox(height: 16),

                  // ── Safety / Owner actions ───────────────────────────────────
                  _buildSafetyActions(context, ref, item, isOwner, t),

                  const SizedBox(height: 28),

                  // ── Similar Lost Items ───────────────────────────────
                  _buildSimilarSection(context, ref, item),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver app bar with hero image ─────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context, ItemModel item) {
    final t = AppColorTokens.of(context);
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: t.surface.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: t.onSurface, size: 20),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: t.onSurface),
          onPressed: () async {
            final text =
                '${item.isLost ? 'Lost' : 'Found'} item: ${item.title}\n'
                'Location: ${item.location}\n'
                'Details: ${item.description}';
            await Clipboard.setData(ClipboardData(text: text));
            if (!context.mounted) return;
            ActionFeedback.showInfo(
              context,
              'Item details copied to clipboard.',
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: t.onSurface),
          onPressed: () => ActionFeedback.showInfo(
            context,
            'More item actions will appear here.',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          item.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  item.isLost
                      ? t.error.withOpacity(0.8)
                      : t.primary.withOpacity(0.8),
                  t.bg,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Icon(
                item.isLost
                    ? Icons.account_balance_wallet_outlined
                    : Icons.vpn_key_outlined,
                color: t.onSurfaceMuted,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Badge helper ────────────────────────────────────────────────────────────
  Widget _badge(String label, Color color, AppColorTokens t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Detail rows card ────────────────────────────────────────────────────────
  Widget _buildDetailsCard(
    ItemModel item,
    BuildContext context,
    AppColorTokens t,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow(
            icon: Icons.category_outlined,
            label: 'CATEGORY',
            value: item.category.isEmpty ? null : item.category,
            t: t,
          ),
          _detailDivider(t),
          _detailRow(
            icon: Icons.calendar_today_outlined,
            label: item.isLost ? 'LOST ON' : 'FOUND ON',
            value: item.lostOn,
            t: t,
          ),
          _detailDivider(t),
          _detailRow(
            icon: Icons.location_on_outlined,
            label: 'LOCATION',
            value: item.location.isEmpty ? null : item.location,
            t: t,
          ),
          if (item.lastSeenAt != null && item.lastSeenAt!.isNotEmpty) ...[
            _detailDivider(t),
            _detailRow(
              icon: Icons.place_outlined,
              label: 'LAST SEEN AT',
              value: item.lastSeenAt,
              t: t,
            ),
          ],
          _detailDivider(t),
          // Map placeholder with location label
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          t.surfaceHigh,
                          t.surfaceHigh.withOpacity(0.8),
                          t.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  CustomPaint(painter: _MapGridPainter(), child: Container()),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: t.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.location.isEmpty ? 'Location not specified' : item.location,
                            style: TextStyle(
                              color: t.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String? value,
    required AppColorTokens t,
  }) {
    final displayValue = (value == null || value.trim().isEmpty)
        ? 'Not provided'
        : value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: t.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: t.onSurfaceMuted,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: t.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailDivider(AppColorTokens t) =>
      Divider(color: t.divider, height: 1);

  Widget _buildOwnerCard(
    ItemModel item,
    AsyncValue ownerProfileAsync,
    BuildContext context,
    WidgetRef ref,
    AppColorTokens t,
  ) {
    final resolvedProfile = ownerProfileAsync.value;

    // Name: prefer fresh profile, fall back to snapshot on the post
    final ownerName = resolvedProfile?.fullName.isNotEmpty == true
        ? resolvedProfile!.fullName
        : (resolvedProfile?.nickName.isNotEmpty == true
            ? resolvedProfile!.nickName
            : (item.ownerName?.isNotEmpty == true
                ? item.ownerName!
                : 'Unknown Owner'));

    // Trust score stored on the post document
    final trustScore = item.ownerTrustScore == null
        ? (resolvedProfile != null ? '–' : 'N/A')
        : item.ownerTrustScore!.toStringAsFixed(1);

    final avatarUrl = resolvedProfile?.avatarUrl ?? '';
    final avatarLabel = ownerName.isNotEmpty ? ownerName[0].toUpperCase() : '?';
    final phone = resolvedProfile?.phone ?? '';
    final email = resolvedProfile?.email ?? '';

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + name + trust score ──────────────────────────────────
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: t.primaryContainer,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            avatarLabel,
                            style: TextStyle(
                              color: t.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  if (item.isVerified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: t.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 1.5),
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ownerName,
                      style: TextStyle(
                        color: t.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Trust score
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: t.warning, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '$trustScore Trust Score',
                          style: TextStyle(
                              color: t.onSurfaceVar, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Contact info rows ────────────────────────────────────────────
          if (phone.isNotEmpty)
            _contactRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: phone,
              onTap: () async {
                final url = Uri.parse('tel:$phone');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
              t: t,
            ),

          if (email.isNotEmpty)
            _contactRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
              onTap: () async {
                final url = Uri.parse('mailto:$email');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
              t: t,
            ),

          if (phone.isEmpty && email.isEmpty && ownerProfileAsync.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: t.primary),
                  ),
                  const SizedBox(width: 8),
                  Text('Loading contact info…',
                      style: TextStyle(
                          color: t.onSurfaceMuted, fontSize: 12)),
                ],
              ),
            ),

          if (phone.isEmpty && email.isEmpty && !ownerProfileAsync.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Contact info not provided',
                style: TextStyle(
                    color: t.onSurfaceMuted,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ),

          const SizedBox(height: 12),

          // ── Chat button ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: t.isDark ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final ownerId = item.ownerId;
                final currentUserId =
                    ref.read(authStateProvider).userId ?? '';
                if (currentUserId.isEmpty) {
                  ActionFeedback.showInfo(
                      context, 'Please log in to message the owner.');
                  return;
                }
                if (ownerId.isEmpty || ownerId == currentUserId) {
                  ActionFeedback.showInfo(
                      context, 'You cannot message yourself.');
                  return;
                }
                try {
                  final chatService = ref.read(chatServiceProvider);
                  final chatId = await chatService.createOrGetChat(
                      currentUserId, ownerId, item.id, item.title);
                  if (context.mounted) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: {
                        'chatId': chatId,
                        'userName': ownerName,
                      },
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ActionFeedback.showInfo(
                        context, 'Error creating chat: $e');
                  }
                }
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text(
                'Chat with Owner',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Call / Email buttons ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.onSurface,
                    side: BorderSide(color: t.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () async {
                    if (phone.isEmpty) {
                      ActionFeedback.showInfo(
                          context, 'Owner phone number is not available.');
                      return;
                    }
                    final url = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else if (context.mounted) {
                      ActionFeedback.showInfo(
                          context, 'Could not launch phone dialer.');
                    }
                  },
                  icon: Icon(Icons.phone_outlined,
                      size: 16, color: t.onSurfaceVar),
                  label: Text('Call',
                      style: TextStyle(fontSize: 13, color: t.onSurface)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.onSurface,
                    side: BorderSide(color: t.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () async {
                    if (email.isEmpty) {
                      ActionFeedback.showInfo(
                          context, 'Owner email is not available.');
                      return;
                    }
                    final url = Uri.parse('mailto:$email');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else if (context.mounted) {
                      ActionFeedback.showInfo(
                          context, 'Could not launch email client.');
                    }
                  },
                  icon: Icon(Icons.email_outlined,
                      size: 16, color: t.onSurfaceVar),
                  label: Text('Email',
                      style: TextStyle(fontSize: 13, color: t.onSurface)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Contact info row helper ─────────────────────────────────────────────────
  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required AppColorTokens t,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: t.iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: t.primary, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        color: t.onSurfaceMuted,
                        fontSize: 10,
                        letterSpacing: 0.8),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: t.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: t.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Safety actions ──────────────────────────────────────────────────────────
  Widget _buildSafetyActions(BuildContext context, WidgetRef ref, ItemModel item, bool isOwner, AppColorTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOwner ? 'OWNER ACTIONS' : 'SAFETY ACTIONS',
          style: TextStyle(
            color: t.onSurfaceMuted,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (!isOwner) ...[
              _safetyAction(
                icon: Icons.flag_outlined,
                label: 'Report Post',
                color: t.error,
                onTap: () async {
                  final reporterId = ref.read(authStateProvider).userId ?? '';
                  if (reporterId.isEmpty) {
                    ActionFeedback.showInfo(context, 'Please log in to report.');
                    return;
                  }
                  try {
                    await ref.read(postServiceProvider).reportPost(item.id, reporterId, 'Inappropriate content or spam');
                    if (context.mounted) {
                      ActionFeedback.showInfo(context, 'Post reported successfully.');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ActionFeedback.showInfo(context, 'Error reporting post: $e');
                    }
                  }
                },
              ),
            ] else ...[
              _safetyAction(
                icon: Icons.check_circle_outline,
                label: item.isResolved ? 'Resolved' : 'Mark as Resolved',
                color: item.isResolved ? t.onSurfaceMuted : t.success,
                onTap: () async {
                  if (item.isResolved) return;
                  try {
                    await ref.read(postServiceProvider).markAsResolved(item.id);
                    if (context.mounted) {
                      ActionFeedback.showInfo(context, 'Post marked as resolved!');
                      Navigator.pop(context); // Go back to refresh
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ActionFeedback.showInfo(context, 'Error resolving post: $e');
                    }
                  }
                },
              ),
              const SizedBox(width: 16),
              _safetyAction(
                icon: Icons.delete_outline,
                label: 'Delete Post',
                color: t.error,
                onTap: () async {
                  try {
                    await ref.read(postServiceProvider).deletePost(item.id);
                    if (context.mounted) {
                      ActionFeedback.showInfo(context, 'Post deleted successfully.');
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ActionFeedback.showInfo(context, 'Error deleting post: $e');
                    }
                  }
                },
              ),
            ]
          ],
        ),
      ],
    );
  }

  Widget _safetyAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Similar items section ───────────────────────────────────────────────────
  Widget _buildSimilarSection(
    BuildContext context,
    WidgetRef ref,
    ItemModel item,
  ) {
    final similarState = ref.watch(similarItemsProvider(item.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Similar Lost Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  'Found recently in the area',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            Builder(
              builder: (ctx) {
                final t2 = AppColorTokens.of(ctx);
                return TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.search),
                  icon: Text(
                    'View All',
                    style: TextStyle(
                      color: t2.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  label: Icon(Icons.arrow_forward, color: t2.primary, size: 14),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        similarState.when(
          loading: () =>
              const LoadingWidget(message: 'Loading similar items...'),
          error: (err, _) => ErrorStateWidget(message: err.toString()),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyWidget(
                title: 'No similar items yet',
                subtitle: 'Check back later for matches nearby.',
              );
            }
            return SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SimilarCard(item: items[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Subtle map grid painter ────────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // To cleanly use t.divider we could pass t, but as this is a CustomPainter without context access in current signature:
    // Let's use a subtle neutral fallback that works across themes, or require AppColorTokens injection.
    // For now:
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Simulate a road
    final road = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 6;
    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width, size.height * 0.45),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.45, size.height),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
