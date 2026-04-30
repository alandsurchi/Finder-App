import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
import 'package:finder/widgets/fade_in_slide.dart';
import 'package:finder/screens/search_screen.dart';
import 'package:finder/screens/create_post_screen.dart';
import 'package:finder/screens/messages_screen.dart';
import 'package:finder/screens/profile_screen.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/cards/home_item_card.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:finder/features/posts/presentation/posts_filter.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/core/constants/app_categories.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/item_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    final t = AppColorTokens.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
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
  const _HomeContent({Key? key, this.onProfileTap}) : super(key: key);

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

    return SafeArea(
      child: Column(
        children: [
          FadeInSlide(child: _buildHeader(t, profileState)),

          // ── Filter tabs — pinned, never scrolls ──────────────────────────
          FadeInSlide(
            delay: 0.1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: AppCategories.homeCategories.map((c) {
                    final sel = c == filters.category;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => ref
                            .read(postsFilterProvider.notifier)
                            .setCategory(c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF2D8CFF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              _categoryLabel(c),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    sel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Scrollable posts ─────────────────────────────────────────────
          Expanded(
            child: postsStream.when(
              loading: () =>
                  const LoadingWidget(message: 'Loading posts...'),
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
                  padding: const EdgeInsets.only(bottom: 110),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _buildItemCard(items[index], t),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColorTokens t, AsyncValue profileState) {
    final userName = _profileName(profileState);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onProfileTap,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/profile img.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF2D8CFF),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
              ),
              child: const Icon(Icons.notifications_none, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  // ── Action card (Post Lost / Post Found) ────────────────────────────────────
  Widget _buildActionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ItemModel item, AppColorTokens t) {
    return FadeInSlide(
      delay: 0.15,
      child: HomeItemCard(
        item: item,
        badges: [
          if (item.isLost)
            BadgeData(label: 'LOST', color: t.error)
          else
            BadgeData(label: 'FOUND', color: t.success),
          if (item.reward != null)
            BadgeData(label: item.reward!, color: t.warning),
        ],
        buttonLabel: item.isLost ? 'Contact Owner' : 'Contact Finder',
      ),
    );
  }

  String _profileNickName(AsyncValue profileState) {
    return profileState.maybeWhen(
      data: (profile) => profile.nickName.isEmpty ? 'Guest' : profile.nickName,
      orElse: () => 'Guest',
    );
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
    if (category == 'All Items') return 'All items';
    return category;
  }
}
