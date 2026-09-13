import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
import 'package:finder/screens/edit_profile_screen.dart';
import 'package:finder/screens/my_posts_screen.dart';
import 'package:finder/screens/saved_items_screen.dart';
import 'package:finder/screens/privacy_settings_screen.dart';
import 'package:finder/screens/notification_settings_screen.dart';
import 'package:finder/screens/help_support_screen.dart';
import 'package:finder/screens/get_verified_screen.dart';
import 'package:finder/screens/legal_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/theme/theme_provider.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';
import 'package:finder/features/posts/presentation/saved_items_controller.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/providers/my_posts_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh silently every time the tab opens; the shared copy is kept.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
      ref.read(myPostsProvider.notifier).load();
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
              StaggeredEntrance(
                  index: 1, child: _buildProfileSummaryPanel(t, profile, profileState.isLoading)),
              const SizedBox(height: BeaconSpace.lg),
              StaggeredEntrance(index: 2, child: _buildActionButtons(t, profile)),
              const SizedBox(height: BeaconSpace.xxxl),
              StaggeredEntrance(index: 3, child: _buildMenuSection(t, profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummaryPanel(AppColorTokens t, UserModel profile, bool loading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 104,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: t.primaryGradient),
                child: const Stack(
                  fit: StackFit.expand,
                  children: [
                    BeaconGlow(alignment: Alignment(1.1, -0.6), radius: 0.9),
                    BeaconRings(alignment: Alignment(1.05, -0.5), radius: 180, opacity: 0.18),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  BeaconSpace.lg, 56, BeaconSpace.lg, BeaconSpace.lg),
              child: Column(
                children: [
                  _buildProfileHeader(t, profile, loading),
                  const SizedBox(height: BeaconSpace.xl),
                  _buildStats(t),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppColorTokens t, UserModel profile, bool loading) {
    final text = Theme.of(context).textTheme;
    final name = profile.uid.isEmpty
        ? (loading ? 'Loading…' : 'Finder member')
        : profile.displayName;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: t.surface, shape: BoxShape.circle),
              child: AppAvatar(url: profile.avatarUrl, name: name, size: 96, ring: true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: AppIconButton(
                icon: Icons.camera_alt_rounded,
                tooltip: 'Change photo',
                size: 32,
                iconSize: 16,
                variant: AppIconButtonVariant.filled,
                onPressed: _openEdit,
              ),
            ),
          ],
        ),
        const SizedBox(height: BeaconSpace.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(name,
                  style: text.headlineSmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            if (profile.identityVerified) ...[
              const SizedBox(width: BeaconSpace.sm),
              Icon(Icons.verified_rounded, color: t.primary, size: 22),
            ],
          ],
        ),
        const SizedBox(height: BeaconSpace.xs),
        Text(
          profile.nickName.isEmpty
              ? (profile.job.isEmpty ? profile.email : profile.job)
              : '@${profile.nickName.toLowerCase()}',
          style: text.bodyMedium?.copyWith(color: t.primary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (profile.identityVerified) ...[
          const SizedBox(height: BeaconSpace.sm),
          StatusBadge.verified(),
        ],
      ],
    );
  }

  Widget _buildStats(AppColorTokens t) {
    final posts = ref.watch(myPostsProvider).value;
    final saved = ref.watch(savedItemsProvider).value;
    final total = posts?.length;
    final resolved = posts?.where((p) => p.isResolved).length;
    final active = (total != null && resolved != null) ? total - resolved : null;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: BeaconSpace.md),
      decoration: BoxDecoration(
        color: t.surfaceLow,
        borderRadius: BeaconRadius.rLg,
      ),
      child: Row(
        children: [
          _statItem('Active', active?.toString() ?? '--', t),
          _buildDivider(t),
          _statItem('Resolved', resolved?.toString() ?? '--', t),
          _buildDivider(t),
          _statItem('Saved', saved?.length.toString() ?? '--', t),
        ],
      ),
    );
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

  void _openEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  Future<void> _shareProfile(UserModel profile) async {
    final lines = [
      profile.displayName,
      if (profile.nickName.isNotEmpty) '@${profile.nickName}',
      if (profile.job.isNotEmpty) profile.job,
      if (profile.address.isNotEmpty) profile.address,
      'Find me on Finder · member id ${profile.uid}',
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!mounted) return;
    ActionFeedback.showInfo(context, 'Profile details copied to clipboard.');
  }

  Widget _buildActionButtons(AppColorTokens t, UserModel profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Edit profile',
              icon: Icons.edit_outlined,
              size: AppButtonSize.medium,
              onPressed: _openEdit,
            ),
          ),
          const SizedBox(width: BeaconSpace.md),
          AppIconButton(
            icon: Icons.share_outlined,
            tooltip: 'Copy profile details',
            variant: AppIconButtonVariant.outlined,
            onPressed: () => _shareProfile(profile),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: 'About Finder',
        subtitle: 'Version 1.0 · Beacon design',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Finder helps a community reunite lost belongings with their owners. '
              'Report what you lost or found, chat safely inside the app and mark items as resolved when they are back home.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: BeaconSpace.lg),
            SurfaceCard(
              tone: SurfaceTone.low,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: t.primary, size: 18),
                      const SizedBox(width: BeaconSpace.sm),
                      Text('Safety first', style: text.titleSmall),
                    ],
                  ),
                  const SizedBox(height: BeaconSpace.xs),
                  Text(
                    'Meet in public places, never pay a reward before you have your item, and use in-app chat so you can block and report.',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BeaconSpace.xl),
            AppButton.tonal(label: 'Close', onPressed: () => Navigator.pop(sheetCtx)),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(AppColorTokens t, UserModel profile) {
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
                title: profile.identityVerified ? 'Verified identity' : 'Get verified',
                subtitle: profile.identityVerified
                    ? 'Your badge is visible to the community'
                    : 'Build trust with a verified badge',
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
                icon: Icons.description_outlined,
                title: 'Terms of service',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LegalScreen(kind: LegalDocKind.terms)),
                ),
              ),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy policy',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LegalScreen(kind: LegalDocKind.privacy)),
                ),
              ),
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Finder',
                onTap: _showAbout,
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
                onTap: _confirmLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}
