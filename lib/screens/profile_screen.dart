import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/widgets/fade_in_slide.dart';
import 'package:finder/screens/edit_profile_screen.dart';
import 'package:finder/screens/my_posts_screen.dart';
import 'package:finder/screens/saved_items_screen.dart';
import 'package:finder/screens/privacy_settings_screen.dart';
import 'package:finder/screens/notification_settings_screen.dart';
import 'package:finder/screens/help_support_screen.dart';
import 'package:finder/screens/get_verified_screen.dart';
import 'package:finder/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/theme/theme_provider.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/providers/post_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Refresh profile every time we visit this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.value ?? UserModel.empty();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(t),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileSummaryPanel(t, profile),
                const SizedBox(height: 24),
                _buildActionButtons(t),
                const SizedBox(height: 32),
                _buildMenuSection(t),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryPanel(AppColorTokens t, UserModel profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            _buildProfileHeader(t, profile),
            const SizedBox(height: 14),
            _buildStats(t),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppColorTokens t) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppColorTokens t, UserModel profile) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.primary, width: 2),
                  image: profile.avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(profile.avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profile.avatarUrl.isEmpty
                    ? Icon(Icons.person, color: t.onSurfaceVar, size: 40)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: t.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName.isEmpty ? 'Guest User' : profile.fullName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.nickName.isEmpty
                ? '@guest_finder'
                : '@${profile.nickName.toLowerCase()}_finder',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AppColorTokens t) {
    final authState = ref.watch(authStateProvider);
    final uid = authState.userId ?? '';
    return FutureBuilder<Map<String, int>>(
      future: _fetchPostStats(uid),
      builder: (context, snap) {
        final posts = snap.data?['total'] ?? 0;
        final found = snap.data?['found'] ?? 0;
        final trust = snap.data?['trustPct'] ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statItem('Posts', snap.hasData ? '$posts' : '--', t),
            _buildDivider(t),
            _statItem('Found', snap.hasData ? '$found' : '--', t),
            _buildDivider(t),
            _statItem('Trust', snap.hasData ? '$trust%' : '--', t),
          ],
        );
      },
    );
  }

  Future<Map<String, int>> _fetchPostStats(String uid) async {
    if (uid.isEmpty) return {'total': 0, 'found': 0, 'trustPct': 0};
    try {
      final posts = await ref.read(postServiceProvider).fetchItems(ownerId: uid);
      final total = posts.length;
      final found = posts.where((d) => d.isLost == false).length;
      final resolved = posts.where((d) => d.isResolved == true).length;
      final trustPct = total == 0 ? 0 : ((resolved / total) * 100).round();
      return {'total': total, 'found': found, 'trustPct': trustPct};
    } catch (_) {
      return {'total': 0, 'found': 0, 'trustPct': 0};
    }
  }

  Widget _statItem(String label, String value, AppColorTokens t) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider(AppColorTokens t) {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withOpacity(0.28),
      margin: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildActionButtons(AppColorTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: t.isDark ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: t.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.divider),
            ),
            child: IconButton(
              icon: Icon(Icons.share_outlined, color: t.onSurface, size: 20),
              onPressed: () => ActionFeedback.showInfo(
                context,
                'Profile link copied soon. Sharing flow is being prepared.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(AppColorTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuTitle('ACCOUNT SETTINGS', t),
          _buildMenuItem(
            Icons.description_outlined,
            'My Posts',
            t,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPostsScreen()),
            ),
          ),
          _buildMenuItem(
            Icons.bookmark_border_rounded,
            'Saved Items',
            t,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
            ),
          ),
          _buildMenuItem(
            Icons.verified_user_outlined,
            'Get Verified',
            t,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GetVerifiedScreen()),
            ),
          ),
          const SizedBox(height: 24),
          _buildMenuTitle('PREFERENCES', t),
          _buildDarkModeToggle(context),
          _buildMenuItem(
            Icons.notifications_none_rounded,
            'Notifications',
            t,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          _buildMenuItem(
            Icons.lock_outline_rounded,
            'Privacy & Safety',
            t,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
            ),
          ),
          const SizedBox(height: 24),
          _buildMenuTitle('SUPPORT & LEGAL', t),
          _buildMenuItem(
            Icons.help_outline_rounded,
            'Help & Support',
            t,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),
          _buildMenuItem(Icons.info_outline_rounded, 'About Finder', t, () {}),
          const SizedBox(height: 16),
          _buildLogoutItem(t),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMenuTitle(String text, AppColorTokens t) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    AppColorTokens t,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Icon(icon, color: const Color(0xFF2D8CFF), size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.black.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLogoutItem(AppColorTokens t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: t.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.error.withOpacity(0.18)),
      ),
      child: ListTile(
        onTap: () async {
          await ref.read(authControllerProvider.notifier).logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.onboarding,
              (route) => false,
            );
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: t.error.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.error.withOpacity(0.15)),
          ),
          child: Icon(Icons.logout_rounded, color: t.error, size: 20),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            color: t.error,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: t.error.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context) {
    final t = AppColorTokens.of(context);
    final mode = ref.watch(themeControllerProvider);
    final isDark = mode == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: const Color(0xFF2D8CFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isDark ? 'Dark Mode' : 'Light Mode',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                ref.read(themeControllerProvider.notifier).toggleTheme(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isDark ? t.primary : Colors.white.withOpacity(0.25),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    left: isDark ? 26 : 2,
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
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
}
