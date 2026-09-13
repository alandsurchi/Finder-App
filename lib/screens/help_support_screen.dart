import 'package:flutter/material.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/ui.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: BeaconBackdrop(
        alignment: const Alignment(1.3, -1.2),
        child: SafeArea(
          child: Column(
            children: [
              const AppPageHeader(title: 'Help & support'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    BeaconSpace.page,
                    0,
                    BeaconSpace.page,
                    BeaconSpace.xxxl + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Hero
                      StaggeredEntrance(
                        child: RichText(
                          text: TextSpan(
                            style: text.headlineLarge,
                            children: [
                              const TextSpan(text: 'How can we '),
                              TextSpan(
                                text: 'support',
                                style: TextStyle(color: t.primary),
                              ),
                              const TextSpan(text: ' you today?'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: BeaconSpace.sm),
                      StaggeredEntrance(
                        index: 1,
                        child: Text(
                          "Whether you've lost a treasure or found a memory, our community and support team are here to guide you.",
                          style: text.bodyMedium,
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xl),

                      // ── Search bar
                      StaggeredEntrance(
                        index: 2,
                        child: SearchField(
                          controller: _searchCtrl,
                          hint: "Search for questions (e.g. 'How to…')",
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      // ── Browse by Category
                      StaggeredEntrance(
                        index: 3,
                        child: SettingsGroup(
                          title: 'Browse by category',
                          children: [
                            SettingsTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Account',
                              subtitle:
                                  'Privacy settings, password recovery, and profile verification',
                              onTap: () => ActionFeedback.showComingSoon(context, feature: 'Account'),
                            ),
                            SettingsTile(
                              icon: Icons.shield_outlined,
                              title: 'Safety',
                              subtitle: 'Community guidelines and secure meetups',
                              onTap: () => ActionFeedback.showComingSoon(context, feature: 'Safety'),
                            ),
                            SettingsTile(
                              icon: Icons.camera_alt_outlined,
                              title: 'Posting items',
                              subtitle: 'How to create effective reports',
                              onTap: () => ActionFeedback.showComingSoon(context, feature: 'Posting Items'),
                            ),
                            SettingsTile(
                              icon: Icons.forum_outlined,
                              title: 'Messaging',
                              subtitle: 'Contacting finders and coordination',
                              onTap: () => ActionFeedback.showComingSoon(
                                context,
                                feature: 'Messaging help details',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Still have questions? banner
                      StaggeredEntrance(
                        index: 4,
                        child: Material(
                          color: t.primary,
                          borderRadius: BeaconRadius.rXl,
                          child: Padding(
                            padding: const EdgeInsets.all(BeaconSpace.xl),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Still have questions?',
                                        style: text.titleLarge?.copyWith(color: t.onPrimary),
                                      ),
                                      const SizedBox(height: BeaconSpace.xs),
                                      Text(
                                        'Our live support team is active 24/7',
                                        style: text.bodyMedium?.copyWith(
                                          color: t.onPrimary.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.headset_mic_outlined,
                                  color: t.onPrimary.withValues(alpha: 0.5),
                                  size: 42,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      // ── Online indicator
                      StaggeredEntrance(
                        index: 5,
                        child: Row(
                          children: [
                            AppAvatar(
                              size: 36,
                              online: true,
                              fallbackIcon: Icons.support_agent_rounded,
                            ),
                            const SizedBox(width: BeaconSpace.md),
                            Text('Support is online', style: text.titleSmall),
                          ],
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.md),

                      StaggeredEntrance(
                        index: 5,
                        child: Text(
                          'Direct assistance for urgent matters.',
                          style: text.headlineSmall,
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.lg),

                      // ── Contact Support button
                      StaggeredEntrance(
                        index: 6,
                        child: AppButton(
                          label: 'Contact support',
                          icon: Icons.chat_bubble_outline_rounded,
                          onPressed: () => ActionFeedback.showInfo(
                            context,
                            'Opening in-app support chat...',
                          ),
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.md),

                      // ── Email Us button
                      StaggeredEntrance(
                        index: 6,
                        child: AppButton.secondary(
                          label: 'Email us',
                          icon: Icons.mail_outline_rounded,
                          onPressed: () => ActionFeedback.showInfo(
                            context,
                            'Email support at support@finder.app',
                          ),
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      // ── Technical Feedback card
                      StaggeredEntrance(
                        index: 7,
                        child: SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bug_report_outlined, color: t.accent, size: 18),
                                  const SizedBox(width: BeaconSpace.sm),
                                  Text(
                                    'TECHNICAL FEEDBACK',
                                    style: text.labelSmall?.copyWith(color: t.accent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: BeaconSpace.md),
                              Text('Found a glitch?', style: text.titleLarge),
                              const SizedBox(height: BeaconSpace.sm),
                              Text(
                                'Help us improve the experience by reporting technical issues directly to our engineering team.',
                                style: text.bodyMedium,
                              ),
                              const SizedBox(height: BeaconSpace.md),
                              AppButton.ghost(
                                label: 'Report a technical issue',
                                icon: Icons.arrow_forward_rounded,
                                iconTrailing: true,
                                onPressed: () => ActionFeedback.showInfo(
                                  context,
                                  'Issue reporting flow will open here.',
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
            ],
          ),
        ),
      ),
    );
  }
}
