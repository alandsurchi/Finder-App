import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
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
import 'package:finder/features/posts/presentation/posts_filter.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/core/constants/app_categories.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/item_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    _HomeContent(onProfileTap: () => setState(() => _currentIndex = 4)),
    const SearchScreen(),
    const CreatePostScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: BeaconMotion.scaled(context, BeaconMotion.state),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _pages[_currentIndex],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Home content ────────────────────────────────────────────────────────────
class _HomeContent extends ConsumerStatefulWidget {
  final VoidCallback? onProfileTap;
  const _HomeContent({this.onProfileTap});

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

            // ── Filter — pinned, never scrolls ───────────────────────────────
            StaggeredEntrance(
              index: 1,
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
                loading: () => const LoadingWidget(
                  message: 'Loading posts...',
                  variant: LoadingVariant.list,
                ),
                error: (err, _) => ErrorStateWidget(
                  message: err.toString(),
                  onRetry: () => ref.refresh(postsStreamProvider),
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
          AppIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            variant: AppIconButtonVariant.glass,
            size: 48,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
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
