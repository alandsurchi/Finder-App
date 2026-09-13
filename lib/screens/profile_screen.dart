import 'package:flutter/material.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
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
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/theme/theme_provider.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/providers/post_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh profile every time we visit this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.value ?? UserModel.empty();
    final navClearance = CustomBottomNavBar.totalHeight(context) + BeaconSpace.lg;

    return Scaffold(
      body: BeaconBackdrop(
        alignment: const Alignment(0, -1.3),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.only(bottom: navClearance),
            children: [
              const StaggeredEntrance(
                child: AppPageHeader(
                  title: 'Profile',
                  showBack: false,
                  padding: EdgeInsets.fromLTRB(
                      BeaconSpace.page, BeaconSpace.md, BeaconSpace.page, BeaconSpace.sm),
                ),
              ),
              StaggeredEntrance(index: 1, child: _buildProfileSummaryPanel(t, profile)),
              const SizedBox(height: BeaconSpace.lg),
              StaggeredEntrance(index: 2, child: _buildActionButtons(t)),
              const SizedBox(height: BeaconSpace.xxxl),
              StaggeredEntrance(index: 3, child: _buildMenuSection(t)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummaryPanel(AppColorTokens t, UserModel profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
      child: SurfaceCard(
        padding: const EdgeInsets.fromLTRB(
            BeaconSpace.lg, BeaconSpace.xxl, BeaconSpace.lg, BeaconSpace.lg),
        child: Column(
          children: [
            _buildProfileHeader(t, profile),
            const SizedBox(height: BeaconSpace.xl),
            _buildStats(t),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppColorTokens t, UserModel profile) {
    final text = Theme.of(context).textTheme;
    final name = profile.fullName.isEmpty ? 'Guest User' : profile.fullName;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AppAvatar(url: profile.avatarUrl, name: name, size: 96, ring: true),
            Positioned(
              bottom: 0,
              right: 0,
              child: AppIconButton(
                icon: Icons.camera_alt_rounded,
                tooltip: 'Change photo',
                size: 32,
                iconSize: 16,
                variant: AppIconButtonVariant.filled,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: BeaconSpace.lg),
        Text(name, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: BeaconSpace.xs),
        Text(
          profile.nickName.isEmpty
              ? '@guest_finder'
              : '@${profile.nickName.toLowerCase()}_finder',
          style: text.bodyMedium?.copyWith(color: t.primary),
        ),
      ],
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
        return Container(
          padding: const EdgeInsets.symmetric(vertical: BeaconSpace.md),
          decoration: BoxDecoration(
            color: t.surfaceLow,
            borderRadius: BeaconRadius.rLg,
          ),
          child: Row(
            children: [
              _statItem('Posts', snap.hasData ? '$posts' : '--', t),
              _buildDivider(t),
              _statItem('Found', snap.hasData ? '$found' : '--', t),
              _buildDivider(t),
              _statItem('Trust', snap.hasData ? '$trust%' : '--', t),
            ],
          ),
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
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: text.titleLarge),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
        ],
      ),
    );
  }

  Widget _buildDivider(AppColorTokens t) {
    return Container(height: 28, width: 1, color: t.outlineVariant);
  }

  Widget _buildActionButtons(AppColorTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Edit profile',
              icon: Icons.edit_outlined,
              size: AppButtonSize.medium,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
          ),
          const SizedBox(width: BeaconSpace.md),
          AppIconButton(
            icon: Icons.share_outlined,
            tooltip: 'Share profile',
            variant: AppIconButtonVariant.outlined,
            onPressed: () => ActionFeedback.showInfo(
              context,
              'Profile link copied soon. Sharing flow is being prepared.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(AppColorTokens t) {
    final mode = ref.watch(themeControllerProvider);
    final isDark = mode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsGroup(
            title: 'Account',
            children: [
              SettingsTile(
                icon: Icons.description_outlined,
                title: 'My posts',
                subtitle: 'Manage what you have reported',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyPostsScreen()),
                ),
              ),
              SettingsTile(
                icon: Icons.bookmark_border_rounded,
                title: 'Saved items',
                subtitle: 'Items you are keeping an eye on',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
                ),
              ),
              SettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Get verified',
                subtitle: 'Build trust with a verified badge',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GetVerifiedScreen()),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Preferences',
            children: [
              ToggleTile(
                icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                title: 'Dark mode',
                subtitle: isDark ? 'Nightwatch theme' : 'Daylight theme',
                value: isDark,
                onChanged: (_) =>
                    ref.read(themeControllerProvider.notifier).toggleTheme(),
              ),
              SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                ),
              ),
              SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & safety',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Support & legal',
            children: [
              SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & support',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                ),
              ),
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Finder',
                onTap: () {},
              ),
            ],
          ),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Log out',
                destructive: true,
                showChevron: false,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
