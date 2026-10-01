import 'package:flutter/material.dart';
import 'package:finder/screens/admin/admin_console_screen.dart';
import 'package:flutter/services.dart';
import 'package:finder/features/share/share_service.dart';
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
import 'package:finder/l10n/l10n.dart';
import 'package:finder/l10n/locale_controller.dart';
import 'package:finder/features/settings/presentation/language_sheet.dart';
import 'package:finder/widgets/ui/profile_cover.dart';
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
    final l10n = context.l10n;
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.value ?? UserModel.empty();
    final navClearance =
        CustomBottomNavBar.totalHeight(context) + BeaconSpace.lg;

    return Scaffold(
      body: BeaconBackdrop(
        alignment: const Alignment(0, -1.3),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.only(bottom: navClearance),
            children: [
              StaggeredEntrance(
                child: AppPageHeader(
                  title: l10n.commonProfile,
                  showBack: false,
                  padding: const EdgeInsets.fromLTRB(
                    BeaconSpace.page,
                    BeaconSpace.md,
                    BeaconSpace.page,
                    BeaconSpace.sm,
                  ),
                ),
              ),
              StaggeredEntrance(
                index: 1,
                child: _buildProfileSummaryPanel(
                  t,
                  profile,
                  profileState.isLoading,
                ),
              ),
              const SizedBox(height: BeaconSpace.lg),
              StaggeredEntrance(
                index: 2,
                child: _buildActionButtons(t, profile),
              ),
              const SizedBox(height: BeaconSpace.xxxl),
              StaggeredEntrance(index: 3, child: _buildMenuSection(t, profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummaryPanel(
    AppColorTokens t,
    UserModel profile,
    bool loading,
  ) {
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
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openEdit,
                child: ProfileCover(url: profile.coverUrl, height: 140),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                BeaconSpace.lg,
                92,
                BeaconSpace.lg,
                BeaconSpace.lg,
              ),
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

  Widget _buildProfileHeader(
    AppColorTokens t,
    UserModel profile,
    bool loading,
  ) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final name = profile.uid.isEmpty
        ? (loading ? l10n.commonLoading : l10n.profileFinderMember)
        : profile.displayName;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: t.surface,
                shape: BoxShape.circle,
              ),
              child: AppAvatar(
                url: profile.avatarUrl,
                name: name,
                size: 96,
                ring: true,
              ),
            ),
            PositionedDirectional(
              bottom: 0,
              end: 0,
              child: AppIconButton(
                icon: Icons.camera_alt_rounded,
                tooltip: l10n.profileChangePhoto,
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
              child: Text(
                name,
                style: text.headlineSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (profile.identityVerified || profile.isAdmin) ...[
              const SizedBox(width: BeaconSpace.sm),
              Icon(Icons.verified_rounded, color: t.primary, size: 22),
            ],
            if (profile.isAdmin) ...[
              const SizedBox(width: BeaconSpace.xs),
              Icon(Icons.shield_rounded, color: kAdminColor, size: 22),
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
        if (profile.identityVerified || profile.isAdmin) ...[
          const SizedBox(height: BeaconSpace.sm),
          Wrap(
            spacing: BeaconSpace.sm,
            children: [
              if (profile.identityVerified || profile.isAdmin)
                StatusBadge.verified(),
              if (profile.isAdmin) adminBadge(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStats(AppColorTokens t) {
    final l10n = context.l10n;
    final posts = ref.watch(myPostsProvider).value;
    final saved = ref.watch(savedItemsProvider).value;
    final total = posts?.length;
    final resolved = posts?.where((p) => p.isResolved).length;
    final active = (total != null && resolved != null)
        ? total - resolved
        : null;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: BeaconSpace.md),
      decoration: BoxDecoration(
        color: t.surfaceLow,
        borderRadius: BeaconRadius.rLg,
      ),
      child: Row(
        children: [
          _statItem(l10n.profileStatActive, active?.toString() ?? '--', t),
          _buildDivider(t),
          _statItem(l10n.profileStatResolved, resolved?.toString() ?? '--', t),
          _buildDivider(t),
          _statItem(l10n.profileStatSaved, saved?.length.toString() ?? '--', t),
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
          Text(
            label.toUpperCase(),
            style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
          ),
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
    final ok = await ref.read(shareServiceProvider).shareProfile(context, profile);
    if (ok || !mounted) return;
    final lines = [
      profile.displayName,
      if (profile.nickName.isNotEmpty) '@${profile.nickName}',
      if (profile.job.isNotEmpty) profile.job,
      context.l10n.profileShareLine(profile.uid),
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!mounted) return;
    ActionFeedback.showInfo(context, context.l10n.profileCopied);
  }

  Widget _buildActionButtons(AppColorTokens t, UserModel profile) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: l10n.profileEdit,
              icon: Icons.edit_outlined,
              size: AppButtonSize.medium,
              onPressed: _openEdit,
            ),
          ),
          const SizedBox(width: BeaconSpace.md),
          AppIconButton(
            icon: Icons.share_outlined,
            tooltip: l10n.profileCopyDetails,
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
    final l10n = context.l10n;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: l10n.profileAboutTitle,
        subtitle: l10n.profileAboutVersion,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.profileAboutBody,
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
                      Text(l10n.profileSafetyFirst, style: text.titleSmall),
                    ],
                  ),
                  const SizedBox(height: BeaconSpace.xs),
                  Text(
                    l10n.profileSafetyBody,
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BeaconSpace.xl),
            AppButton.tonal(
              label: l10n.commonClose,
              onPressed: () => Navigator.pop(sheetCtx),
            ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(AppColorTokens t, UserModel profile) {
    final mode = ref.watch(themeControllerProvider);
    final isDark = mode == ThemeMode.dark;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsGroup(
            title: l10n.profileAccount,
            children: [
              SettingsTile(
                icon: Icons.description_outlined,
                title: l10n.profileMyPosts,
                subtitle: l10n.profileMyPostsSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyPostsScreen()),
                ),
              ),
              SettingsTile(
                icon: Icons.bookmark_border_rounded,
                title: l10n.profileSavedItems,
                subtitle: l10n.profileSavedItemsSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
                ),
              ),
              if (!profile.isAdmin)
                SettingsTile(
                  icon: Icons.verified_user_outlined,
                  title: profile.identityVerified
                      ? l10n.verifyVerifiedIdentity
                      : l10n.verifyGetVerified,
                  subtitle: profile.identityVerified
                      ? l10n.verifyBadgeVisible
                      : l10n.verifyBuildTrust,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GetVerifiedScreen(),
                    ),
                  ),
                ),
              if (profile.isAdmin)
                SettingsTile(
                  icon: Icons.admin_panel_settings_outlined,
                  iconColor: kAdminColor,
                  title: l10n.profileAdminConsole,
                  subtitle: l10n.profileAdminConsoleSubtitle,
                  trailing: adminBadge(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminConsoleScreen(),
                    ),
                  ),
                ),
            ],
          ),
          SettingsGroup(
            title: l10n.profilePreferences,
            children: [
              ToggleTile(
                icon: isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: l10n.profileDarkMode,
                subtitle: isDark ? l10n.profileNightTheme : l10n.profileDayTheme,
                value: isDark,
                onChanged: (_) =>
                    ref.read(themeControllerProvider.notifier).toggleTheme(),
              ),
              SettingsTile(
                icon: Icons.translate_rounded,
                title: context.l10n.languageTitle,
                subtitle: currentLanguageLabel(context, ref.watch(localeControllerProvider)),
                onTap: () => showLanguageSheet(context, ref),
              ),
              SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: l10n.commonNotifications,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                ),
              ),
              SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: l10n.privacyTitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacySettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: l10n.profileSupportLegal,
            children: [
              SettingsTile(
                icon: Icons.help_outline_rounded,
                title: l10n.helpTitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                ),
              ),
              SettingsTile(
                icon: Icons.description_outlined,
                title: l10n.profileTerms,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalScreen(kind: LegalDocKind.terms),
                  ),
                ),
              ),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.profilePrivacyPolicy,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const LegalScreen(kind: LegalDocKind.privacy),
                  ),
                ),
              ),
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: l10n.profileAboutTitle,
                onTap: _showAbout,
              ),
            ],
          ),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.logout_rounded,
                title: l10n.commonLogOut,
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
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileLogOutTitle),
        content: Text(l10n.profileLogOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonLogOut),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}
