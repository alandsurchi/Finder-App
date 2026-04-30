import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/features/profile/presentation/privacy_settings_controller.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final settingsState = ref.watch(privacySettingsProvider);
    final blockedState = ref.watch(blockedUsersProvider);
    final blockedCount = blockedState.maybeWhen(
      data: (users) => users.length,
      orElse: () => 0,
    );

    return settingsState.when(
      loading: () => Scaffold(
        backgroundColor: Colors.transparent,
        body: const LoadingWidget(message: 'Loading settings...'),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ErrorStateWidget(message: err.toString()),
      ),
      data: (settings) => Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Privacy Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Hero text
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Data, Your Control',
                        style: TextStyle(
                          color: t.onSurface,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We believe in digital hospitality. Every setting here is designed to give you peace of mind while staying connected to your community.',
                        style: TextStyle(
                          color: t.onSurfaceVar,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Toggle cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildToggleCard(
                        t: t,
                        icon: Icons.visibility_outlined,
                        iconBg: t.surfaceHigh,
                        iconColor: t.onSurfaceVar,
                        title: 'Show Profile to Public',
                        description:
                            'When enabled, your name and profile picture will be visible to non-logged users. Disabling limits visibility to verified members only.',
                        value: settings.showProfile,
                        onChanged: (v) => ref
                            .read(privacySettingsProvider.notifier)
                            .updateSettings(settings.copyWith(showProfile: v)),
                      ),
                      const SizedBox(height: 12),
                      _buildToggleCard(
                        t: t,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconBg: t.surfaceHigh,
                        iconColor: t.onSurfaceVar,
                        title: 'Allow Direct Messages',
                        description:
                            'Let other members reach out directly. We use encrypted transit to keep your conversations safe.',
                        value: settings.allowMessages,
                        onChanged: (v) => ref
                            .read(privacySettingsProvider.notifier)
                            .updateSettings(
                              settings.copyWith(allowMessages: v),
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildToggleCard(
                        t: t,
                        icon: Icons.location_on_outlined,
                        iconBg: t.iconBg,
                        iconColor: t.primary,
                        title: 'Show My Location',
                        description:
                            'Shares your approximate neighborhood when you post a found item to help others identify local matches faster.',
                        value: settings.showLocation,
                        onChanged: (v) => ref
                            .read(privacySettingsProvider.notifier)
                            .updateSettings(settings.copyWith(showLocation: v)),
                      ),
                      const SizedBox(height: 12),
                      _buildToggleCard(
                        t: t,
                        icon: Icons.phone_outlined,
                        iconBg: t.warning.withOpacity(0.12),
                        iconColor: t.warning,
                        title: 'Hide My Phone',
                        description:
                            'Your phone number will never be shown. Communication happens exclusively through our secure in-app messaging.',
                        value: settings.hidePhone,
                        onChanged: (v) => ref
                            .read(privacySettingsProvider.notifier)
                            .updateSettings(settings.copyWith(hidePhone: v)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Blocked Users
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: t.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Blocked Users',
                                      style: TextStyle(
                                        color: t.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "People you've blocked can't see\nyour posts or message you.",
                                      style: TextStyle(
                                        color: t.onSurfaceVar,
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: t.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$blockedCount',
                                      style: TextStyle(
                                        color: t.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      'total',
                                      style: TextStyle(
                                        color: t.primary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(color: t.divider, height: 1, indent: 16),

                        blockedState.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16),
                            child: LoadingWidget(
                              message: 'Loading blocked users...',
                            ),
                          ),
                          error: (err, _) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: ErrorStateWidget(message: err.toString()),
                          ),
                          data: (users) {
                            if (users.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: EmptyWidget(
                                  title: 'No blocked users',
                                  subtitle: 'Blocked users will appear here.',
                                ),
                              );
                            }
                            return Column(
                              children: List.generate(users.length, (i) {
                                final user = users[i];
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: t.onSurface
                                                .withOpacity(0.2),
                                            child: Text(
                                              user.avatarLabel,
                                              style: TextStyle(
                                                color: t.surface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              user.name,
                                              style: TextStyle(
                                                color: t.onSurface,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => ref
                                                .read(
                                                  blockedUsersProvider.notifier,
                                                )
                                                .unblockUser(user.id),
                                            child: Text(
                                              'Unblock',
                                              style: TextStyle(
                                                color: t.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (i < users.length - 1)
                                      Divider(
                                        color: t.divider,
                                        height: 1,
                                        indent: 56,
                                      ),
                                  ],
                                );
                              }),
                            );
                          },
                        ),

                        Divider(color: t.divider, height: 1, indent: 16),
                        TextButton.icon(
                          onPressed: () => ActionFeedback.showComingSoon(
                            context,
                            feature: 'Block another user',
                          ),
                          icon: Icon(Icons.add, color: t.primary, size: 16),
                          label: Text(
                            'Block another user',
                            style: TextStyle(
                              color: t.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Request Data Deletion
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => ActionFeedback.showInfo(
                      context,
                      'Data deletion request flow will be available from support soon.',
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: t.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Request Data Deletion',
                          style: TextStyle(
                            color: t.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required AppColorTokens t,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: t.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: t.onSurfaceVar,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: t.primary,
          ),
        ],
      ),
    );
  }
}
