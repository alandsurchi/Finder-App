import 'package:flutter/material.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
import 'package:finder/screens/search_screen.dart';
import 'package:finder/screens/create_post_screen.dart';
import 'package:finder/screens/messages_screen.dart';
import 'package:finder/screens/profile_screen.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/cards/home_item_card.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:finder/providers/home_tab_provider.dart';
import 'package:finder/features/posts/presentation/posts_filter.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/features/notifications/presentation/notifications_controller.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/core/constants/app_categories.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/item_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Tabs are built on first visit and then kept alive, so scroll positions
  /// and the Post form survive tab switches and nothing is painted twice.
  final Set<int> _built = {HomeTabs.home};

  Widget _page(int i) {
    switch (i) {
      case HomeTabs.home:
        return _HomeContent(
          onProfileTap: () => _select(HomeTabs.profile),
          onReport: (isLost) {
            ref.read(createPrefillProvider.notifier).state = isLost;
            _select(HomeTabs.post);
          },
        );
      case HomeTabs.search:
        return const SearchScreen();
      case HomeTabs.post:
        return CreatePostScreen(
          initialIsLost: ref.watch(createPrefillProvider),
        );
      case HomeTabs.messages:
        return const MessagesScreen();
      default:
        return const ProfileScreen();
    }
  }

  void _select(int i) => ref.read(homeTabProvider.notifier).state = i;

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(homeTabProvider);
    _built.add(index);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: index,
            children: List.generate(
              5,
              (i) => _built.contains(i) ? _page(i) : const SizedBox.shrink(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _NavBarHost(
              currentIndex: index,
              onTap: _select,
            ),
          ),
        ],
      ),
    );
  }
}

/// The only widget that reads the keyboard inset: it hides the bar while
/// the keyboard is open so text fields get the whole screen, without
/// rebuilding the tabs on every keyboard frame.
class _NavBarHost extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _NavBarHost({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Visibility(
      visible: !keyboardOpen,
      maintainState: true,
      child: CustomBottomNavBar(currentIndex: currentIndex, onTap: onTap),
    );
  }
}

// ─── Home content ────────────────────────────────────────────────────────────
class _HomeContent extends ConsumerStatefulWidget {
  final VoidCallback? onProfileTap;
  final ValueChanged<bool>? onReport;
  const _HomeContent({this.onProfileTap, this.onReport});

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final postsStream = ref.watch(postsStreamProvider);
    final filters = ref.watch(postsFilterProvider);
    final profileState = ref.watch(profileControllerProvider);
    final categories = AppCategories.homeCategories;
    final selectedIndex = categories.indexOf(filters.category).clamp(0, categories.length - 1);
    final navClearance = CustomBottomNavBar.totalHeight(context) + BeaconSpace.lg;

    return BeaconBackdrop(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StaggeredEntrance(child: _buildHeader(t, profileState)),

            // ── Quick actions — the two things this app is for ──────────────
            StaggeredEntrance(
              index: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: _ReportTile(
                        kind: SignalKind.lost,
                        title: 'Report lost',
                        subtitle: 'Ask the community',
                        onTap: () => widget.onReport?.call(true),
                      ),
                    ),
                    const SizedBox(width: BeaconSpace.md),
                    Expanded(
                      child: _ReportTile(
                        kind: SignalKind.found,
                        title: 'Report found',
                        subtitle: 'Return it home',
                        onTap: () => widget.onReport?.call(false),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Filter — pinned, never scrolls ───────────────────────────────
            StaggeredEntrance(
              index: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
                child: SegmentedPills(
                  options: categories.map(_categoryLabel).toList(),
                  selectedIndex: selectedIndex,
                  onChanged: (i) => ref
                      .read(postsFilterProvider.notifier)
                      .setCategory(categories[i]),
                ),
              ),
            ),

            const SizedBox(height: BeaconSpace.lg),

            // ── Scrollable posts ─────────────────────────────────────────────
            Expanded(
              child: postsStream.when(
                skipError: true,
                loading: () => const LoadingWidget(
                  message: 'Loading posts...',
                  variant: LoadingVariant.list,
                ),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () => ref.invalidate(postsStreamProvider),
                ),
                data: (allPosts) {
                  final items = allPosts.where((p) {
                    if (filters.category == 'Lost') return p.isLost;
                    if (filters.category == 'Found') return !p.isLost;
                    return true;
                  }).toList();
                  if (items.isEmpty) {
                    return EmptyWidget(
                      icon: Icons.explore_off_outlined,
                      title: filters.category == 'Lost'
                          ? 'No lost items'
                          : filters.category == 'Found'
                              ? 'No found items'
                              : 'No posts yet',
                      subtitle: filters.category == 'All Items'
                          ? 'Create the first post to get started.'
                          : 'Try switching to All Items.',
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: navClearance, top: BeaconSpace.xs),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _buildItemCard(items[index], index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorTokens t, AsyncValue profileState) {
    final text = Theme.of(context).textTheme;
    final userName = _profileName(profileState);
    final avatarUrl = profileState.maybeWhen(
      data: (profile) => profile.avatarUrl as String? ?? '',
      orElse: () => '',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          BeaconSpace.page, BeaconSpace.md, BeaconSpace.page, BeaconSpace.xl),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: 'Open profile',
              child: InkWell(
                borderRadius: BeaconRadius.rPill,
                onTap: widget.onProfileTap,
                child: Padding(
                  padding: const EdgeInsets.all(BeaconSpace.xs),
                  child: Row(
                    children: [
                      AppAvatar(url: avatarUrl, name: userName, size: 48),
                      const SizedBox(width: BeaconSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greeting(), style: text.bodySmall),
                            Text(
                              userName,
                              style: text.headlineSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _NotificationBell(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ItemModel item, int index) {
    return StaggeredEntrance(
      index: index.clamp(0, 6),
      baseDelay: const Duration(milliseconds: 40),
      child: HomeItemCard(
        item: item,
        buttonLabel: item.isLost ? 'Contact Owner' : 'Contact Finder',
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _profileName(AsyncValue profileState) {
    return profileState.maybeWhen(
      data: (profile) {
        if (profile.fullName.isNotEmpty) return profile.fullName;
        if (profile.nickName.isNotEmpty) return profile.nickName;
        return 'Guest';
      },
      orElse: () => 'Guest',
    );
  }

  String _categoryLabel(String category) {
    if (category == 'All Items') return 'All';
    return category;
  }
}

/// Bell with an unread count badge.
class _NotificationBell extends ConsumerWidget {
  final VoidCallback onPressed;
  const _NotificationBell({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final unread = ref.watch(unreadNotificationsCountProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconButton(
          icon: unread > 0
              ? Icons.notifications_active_outlined
              : Icons.notifications_none_rounded,
          tooltip: unread > 0
              ? 'Notifications, $unread unread'
              : 'Notifications',
          variant: AppIconButtonVariant.glass,
          size: 48,
          onPressed: onPressed,
        ),
        if (unread > 0)
          Positioned(
            right: -2,
            top: -2,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: t.lost,
                  borderRadius: BeaconRadius.rPill,
                  border: Border.all(color: t.bg, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: text.labelSmall?.copyWith(
                    color: t.onLost,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Signal-colored hero tile: gradient fill, icon disc, title + subtitle.
class _ReportTile extends StatelessWidget {
  final SignalKind kind;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReportTile({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final color = kind.color(t);
    final on = kind.onColor(t);
    return Semantics(
      button: true,
      label: title,
      child: PressScale(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BeaconRadius.rXl,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, t.shadow, 0.18)!],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: t.isDark ? 0.25 : 0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BeaconRadius.rXl,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    bottom: -22,
                    child: Icon(kind.icon, size: 96,
                        color: on.withValues(alpha: 0.10)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(BeaconSpace.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: on.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(kind.icon, size: 18, color: on),
                        ),
                        const SizedBox(height: BeaconSpace.lg),
                        Text(title, style: text.titleMedium?.copyWith(color: on)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: text.bodySmall?.copyWith(
                                color: on.withValues(alpha: 0.82))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
