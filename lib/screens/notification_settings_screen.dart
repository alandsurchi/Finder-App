import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

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
    return Scaffold(
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
                      'Notification Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Hero card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                  decoration: BoxDecoration(
                    color: t.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stay Connected',
                              style: TextStyle(
                                color: t.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose how you want to be notified. We promise to only reach out for the moments that truly matter to you.',
                              style: TextStyle(
                                color: t.onSurfaceVar,
                                fontSize: 13,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.notifications_outlined,
                        color: t.onSurfaceMuted,
                        size: 48,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Push toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRow(
                  t: t,
                  icon: Icons.settings_input_antenna_rounded,
                  iconBg: t.iconBg,
                  iconColor: t.primary,
                  title: 'Push Notifications',
                  subtitle: 'Main control for all alerts',
                  value: _pushEnabled,
                  onChanged: (v) => setState(() => _pushEnabled = v),
                ),
              ),

              const SizedBox(height: 24),

              _sectionLabel('INTERACTIONS & SOCIAL', t),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _card(t, [
                  _buildGroupRow(
                    t: t,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'New Message',
                    subtitle: 'When someone reaches out about a post',
                    value: _newMessage,
                    onChanged: (v) => setState(() => _newMessage = v),
                  ),
                  Divider(color: t.divider, height: 1, indent: 58),
                  _buildGroupRow(
                    t: t,
                    icon: Icons.comment_outlined,
                    title: 'New Comments on Posts',
                    subtitle: 'Discussion updates on your activity',
                    value: _newComments,
                    onChanged: (v) => setState(() => _newComments = v),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              _sectionLabel('SMART CURATION', t),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _card(t, [
                  _buildGroupRow(
                    t: t,
                    icon: Icons.auto_awesome_rounded,
                    iconColor: t.primary,
                    title: 'Item Match Alerts',
                    subtitle:
                        'Instant alerts when a lost item matches your search',
                    value: _itemMatch,
                    onChanged: (v) => setState(() => _itemMatch = v),
                    badge: _SmartBadge(t: t),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              _sectionLabel('PLATFORM', t),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _card(t, [
                  _buildGroupRow(
                    t: t,
                    icon: Icons.update_rounded,
                    title: 'App Updates',
                    subtitle: 'New features and community improvements',
                    value: _appUpdates,
                    onChanged: (v) => setState(() => _appUpdates = v),
                  ),
                ]),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: t.onSurfaceVar,
                      fontSize: 12,
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(
                        text: 'You can manage email preferences in your ',
                      ),
                      TextSpan(
                        text: 'Account Settings',
                        style: TextStyle(
                          color: t.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: '. We value your privacy.'),
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

  Widget _sectionLabel(String text, AppColorTokens t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      text,
      style: TextStyle(
        color: t.onSurfaceMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    ),
  );

  Widget _card(AppColorTokens t, List<Widget> children) => Container(
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
    child: Column(children: children),
  );

  Widget _buildRow({
    required AppColorTokens t,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        children: [
          Container(
            width: 40,
            height: 40,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: t.onSurfaceVar, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildGroupRow({
    required AppColorTokens t,
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? t.onSurfaceVar, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: t.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (badge != null) ...[const SizedBox(width: 8), badge],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: t.onSurfaceVar, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SmartBadge extends StatelessWidget {
  final AppColorTokens t;
  const _SmartBadge({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: t.warning,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'SMART',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
