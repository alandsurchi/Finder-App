import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/features/posts/presentation/similar_items_provider.dart';
import 'package:finder/widgets/cards/similar_card.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/providers/user_provider.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsScreen extends ConsumerWidget {
  const ItemDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final item = (args is ItemModel) ? args : ItemModel.empty();
    final title = item.title.isEmpty ? 'Item Details' : item.title;
    final description = item.description.isEmpty
        ? 'No description provided yet.'
        : item.description;

    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final ownerProfileAsync = ref.watch(userProfileProvider(item.ownerId));
    final currentUserId = ref.watch(authStateProvider).userId ?? '';
    final isOwner = currentUserId.isNotEmpty && currentUserId == item.ownerId;
    final kind = SignalKindX.ofItem(item);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image + app bar ──────────────────────────────────────
          _buildSliverAppBar(context, item),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  BeaconSpace.page, BeaconSpace.xl, BeaconSpace.page, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badges ──────────────────────────────────────────
                  StaggeredEntrance(
                    child: Wrap(
                      spacing: BeaconSpace.sm,
                      runSpacing: BeaconSpace.sm,
                      children: [
                        StatusBadge.signal(kind, withIcon: true),
                        if (item.reward != null)
                          StatusBadge.reward('REWARD \$${item.reward}'),
                        if (item.isResolved) StatusBadge.resolved(),
                        if (item.isVerified) StatusBadge.verified(small: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: BeaconSpace.md),

                  // ── Title ───────────────────────────────────────────
                  StaggeredEntrance(
                    index: 1,
                    child: Text(
                      title,
                      style: text.headlineMedium?.copyWith(
                        color: item.isResolved ? t.onSurfaceMuted : t.onSurface,
                        decoration:
                            item.isResolved ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: BeaconSpace.sm),

                  StaggeredEntrance(
                    index: 1,
                    child: Row(
                      children: [
                        Icon(Icons.place_outlined, size: 16, color: t.onSurfaceMuted),
                        const SizedBox(width: BeaconSpace.xs),
                        Flexible(
                          child: Text(
                            item.location.isEmpty ? 'Location not specified' : item.location,
                            style: text.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('  ·  ${item.timeAgo}', style: text.bodyMedium),
                      ],
                    ),
                  ),

                  const SizedBox(height: BeaconSpace.lg),

                  // ── Description ─────────────────────────────────────
                  StaggeredEntrance(
                    index: 2,
                    child: Text(description, style: text.bodyLarge),
                  ),

                  const SizedBox(height: BeaconSpace.xxl),

                  // ── "I Found This Item" button ───────────────────────
                  if (item.isLost)
                    StaggeredEntrance(
                      index: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: BeaconSpace.xxl),
                        child: AppButton(
                          label: 'I found this item',
                          icon: Icons.volunteer_activism_outlined,
                          variant: AppButtonVariant.accent,
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
                        ),
                      ),
                    ),

                  // ── Detail rows card ─────────────────────────────────
                  StaggeredEntrance(
                    index: 3,
                    child: _buildDetailsCard(item, context, t),
                  ),

                  const SizedBox(height: BeaconSpace.xxl),

                  // ── Owner card ───────────────────────────────────────
                  StaggeredEntrance(
                    index: 4,
                    child: _buildOwnerCard(item, ownerProfileAsync, context, ref, t),
                  ),

                  const SizedBox(height: BeaconSpace.xl),

                  // ── Safety / Owner actions ───────────────────────────────────
                  StaggeredEntrance(
                    index: 5,
                    child: _buildSafetyActions(context, ref, item, isOwner, t),
                  ),

                  const SizedBox(height: BeaconSpace.xxxl),

                  // ── Similar Lost Items ───────────────────────────────
                  StaggeredEntrance(
                    index: 6,
                    child: _buildSimilarSection(context, ref, item),
                  ),

                  SizedBox(height: BeaconSpace.huge + MediaQuery.paddingOf(context).bottom),
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
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: t.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 64,
      leading: Center(
        child: AppIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          variant: AppIconButtonVariant.glass,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        AppIconButton(
          icon: Icons.share_outlined,
          tooltip: 'Copy item details',
          variant: AppIconButtonVariant.glass,
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
        const SizedBox(width: BeaconSpace.sm),
        AppIconButton(
          icon: Icons.more_vert_rounded,
          tooltip: 'More actions',
          variant: AppIconButtonVariant.glass,
          onPressed: () => ActionFeedback.showInfo(
            context,
            'More item actions will appear here.',
          ),
        ),
        const SizedBox(width: BeaconSpace.md),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            ItemImage(
              url: item.imagePath,
              heroTag: 'item-image-${item.id}',
              fallbackIcon: categoryIcon(item.category),
            ),
            // Bottom scrim so the image blends into the page.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [t.bg.withValues(alpha: 0), t.bg],
                ),
              ),
            ),
          ],
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
    return SurfaceCard(
      padding: const EdgeInsets.all(BeaconSpace.sm),
      child: Column(
        children: [
          _detailRow(
            context,
            icon: categoryIcon(item.category),
            label: 'Category',
            value: item.category.isEmpty ? null : item.category,
          ),
          _detailRow(
            context,
            icon: Icons.calendar_today_outlined,
            label: item.isLost ? 'Lost on' : 'Found on',
            value: item.lostOn,
          ),
          _detailRow(
            context,
            icon: Icons.place_outlined,
            label: 'Location',
            value: item.location.isEmpty ? null : item.location,
          ),
          if (item.lastSeenAt != null && item.lastSeenAt!.isNotEmpty)
            _detailRow(
              context,
              icon: Icons.near_me_outlined,
              label: 'Last seen at',
              value: item.lastSeenAt,
            ),
          const SizedBox(height: BeaconSpace.sm),
          MapPlaceholder(
            height: 140,
            label: item.location.isEmpty ? 'Location not specified' : item.location,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? value,
  }) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final displayValue = (value == null || value.trim().isEmpty)
        ? 'Not provided'
        : value;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: BeaconSpace.sm, vertical: BeaconSpace.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.primaryContainer,
              borderRadius: BeaconRadius.rMd,
            ),
            child: Icon(icon, color: t.primary, size: 20),
          ),
          const SizedBox(width: BeaconSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                const SizedBox(height: 2),
                Text(displayValue, style: text.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerCard(
    ItemModel item,
    AsyncValue ownerProfileAsync,
    BuildContext context,
    WidgetRef ref,
    AppColorTokens t,
  ) {
    final text = Theme.of(context).textTheme;
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
    final phone = resolvedProfile?.phone ?? '';
    final email = resolvedProfile?.email ?? '';

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.isLost ? 'POSTED BY THE OWNER' : 'POSTED BY THE FINDER',
            style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
          ),
          const SizedBox(height: BeaconSpace.md),
          // ── Avatar + name + trust score ──────────────────────────────────
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(url: avatarUrl, name: ownerName, size: 56),
                  if (item.isVerified)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: t.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 2),
                        ),
                        child: Icon(Icons.check_rounded, color: t.onPrimary, size: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ownerName, style: text.titleMedium),
                    const SizedBox(height: 2),
                    // Trust score
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: t.accent, size: 16),
                        const SizedBox(width: BeaconSpace.xs),
                        Text('$trustScore trust score', style: text.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: BeaconSpace.lg),

          // ── Contact info rows ────────────────────────────────────────────
          if (phone.isNotEmpty)
            _contactRow(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: phone,
              onTap: () async {
                final url = Uri.parse('tel:$phone');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
            ),

          if (email.isNotEmpty)
            _contactRow(
              context,
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: email,
              onTap: () async {
                final url = Uri.parse('mailto:$email');
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
            ),

          if (phone.isEmpty && email.isEmpty && ownerProfileAsync.isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: BeaconSpace.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: t.primary),
                  ),
                  const SizedBox(width: BeaconSpace.sm),
                  Text('Loading contact info…', style: text.bodySmall),
                ],
              ),
            ),

          if (phone.isEmpty && email.isEmpty && !ownerProfileAsync.isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: BeaconSpace.md),
              child: Text(
                'Contact info not provided',
                style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),

          // ── Chat button ──────────────────────────────────────────────────
          AppButton(
            label: item.isLost ? 'Chat with owner' : 'Chat with finder',
            icon: Icons.chat_bubble_outline_rounded,
            size: AppButtonSize.medium,
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
          ),

          const SizedBox(height: BeaconSpace.md),

          // ── Call / Email buttons ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: 'Call',
                  icon: Icons.phone_outlined,
                  size: AppButtonSize.medium,
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
                ),
              ),
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: AppButton.secondary(
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  size: AppButtonSize.medium,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Contact info row helper ─────────────────────────────────────────────────
  Widget _contactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: BeaconSpace.sm),
      child: Material(
        color: t.surfaceLow,
        borderRadius: BeaconRadius.rMd,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BeaconSpace.md, vertical: BeaconSpace.sm),
            child: Row(
              children: [
                Icon(icon, color: t.primary, size: 20),
                const SizedBox(width: BeaconSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label.toUpperCase(),
                          style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                      Text(value,
                          style: text.titleSmall?.copyWith(color: t.primary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: t.onSurfaceMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Safety actions ──────────────────────────────────────────────────────────
  Widget _buildSafetyActions(BuildContext context, WidgetRef ref, ItemModel item, bool isOwner, AppColorTokens t) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOwner ? 'OWNER ACTIONS' : 'SAFETY',
          style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
        ),
        const SizedBox(height: BeaconSpace.sm),
        Wrap(
          spacing: BeaconSpace.sm,
          runSpacing: BeaconSpace.sm,
          children: [
            if (!isOwner) ...[
              AppButton.ghost(
                label: 'Report post',
                icon: Icons.flag_outlined,
                onPressed: () async {
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
              AppButton.tonal(
                label: item.isResolved ? 'Resolved' : 'Mark as resolved',
                icon: Icons.check_circle_outline_rounded,
                size: AppButtonSize.medium,
                expand: false,
                onPressed: item.isResolved
                    ? null
                    : () async {
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
              AppButton.danger(
                label: 'Delete post',
                icon: Icons.delete_outline_rounded,
                size: AppButtonSize.medium,
                expand: false,
                onPressed: () async {
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
        SectionHeader(
          title: 'Similar items',
          eyebrow: 'Found recently in the area',
          actionLabel: 'View all',
          onAction: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        similarState.when(
          loading: () =>
              const LoadingWidget(message: 'Loading similar items...'),
          error: (err, _) => ErrorStateWidget(message: err.toString()),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyWidget(
                icon: Icons.radar_rounded,
                title: 'No similar items yet',
                subtitle: 'Check back later for matches nearby.',
              );
            }
            return SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: BeaconSpace.md),
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
