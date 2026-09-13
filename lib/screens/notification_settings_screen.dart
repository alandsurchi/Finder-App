import 'package:flutter/material.dart';
import 'package:finder/widgets/ui/ui.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _newMessage = true;
  bool _newComments = true;
  bool _itemMatch = true;
  bool _appUpdates = false;

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'Notifications'),
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
                    // ── Hero card
                    StaggeredEntrance(
                      child: SurfaceCard(
                        tone: SurfaceTone.primary,
                        padding: const EdgeInsets.all(BeaconSpace.xl),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Stay connected',
                                      style: text.headlineSmall
                                          ?.copyWith(color: t.onPrimaryContainer)),
                                  const SizedBox(height: BeaconSpace.sm),
                                  Text(
                                    'Choose how you want to be notified. We only reach out for the moments that truly matter to you.',
                                    style: text.bodyMedium?.copyWith(
                                      color: t.onPrimaryContainer.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: BeaconSpace.md),
                            Icon(Icons.notifications_active_outlined,
                                color: t.primary, size: 44),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.xl),

                    // ── Push toggle
                    StaggeredEntrance(
                      index: 1,
                      child: SettingsGroup(
                        children: [
                          ToggleTile(
                            icon: Icons.settings_input_antenna_rounded,
                            title: 'Push notifications',
                            subtitle: 'Main control for all alerts',
                            value: _pushEnabled,
                            onChanged: (v) => setState(() => _pushEnabled = v),
                          ),
                        ],
                      ),
                    ),

                    StaggeredEntrance(
                      index: 2,
                      child: SettingsGroup(
                        title: 'Interactions & social',
                        children: [
                          ToggleTile(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'New message',
                            subtitle: 'When someone reaches out about a post',
                            value: _newMessage,
                            onChanged: (v) => setState(() => _newMessage = v),
                          ),
                          ToggleTile(
                            icon: Icons.comment_outlined,
                            title: 'New comments on posts',
                            subtitle: 'Discussion updates on your activity',
                            value: _newComments,
                            onChanged: (v) => setState(() => _newComments = v),
                          ),
                        ],
                      ),
                    ),

                    StaggeredEntrance(
                      index: 3,
                      child: SettingsGroup(
                        title: 'Smart matching',
                        children: [
                          ToggleTile(
                            icon: Icons.auto_awesome_rounded,
                            title: 'Item match alerts',
                            subtitle:
                                'Instant alerts when a lost item matches your search',
                            value: _itemMatch,
                            onChanged: (v) => setState(() => _itemMatch = v),
                            badge: StatusBadge.custom(
                              label: 'SMART',
                              color: t.accent,
                              onColor: t.onAccent,
                              small: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    StaggeredEntrance(
                      index: 4,
                      child: SettingsGroup(
                        title: 'Platform',
                        children: [
                          ToggleTile(
                            icon: Icons.update_rounded,
                            title: 'App updates',
                            subtitle: 'New features and community improvements',
                            value: _appUpdates,
                            onChanged: (v) => setState(() => _appUpdates = v),
                          ),
                        ],
                      ),
                    ),

                    StaggeredEntrance(
                      index: 5,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: text.bodySmall,
                          children: [
                            const TextSpan(
                              text: 'You can manage email preferences in your ',
                            ),
                            TextSpan(
                              text: 'Account settings',
                              style: TextStyle(
                                color: t.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: '. We value your privacy.'),
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
    );
  }
}
