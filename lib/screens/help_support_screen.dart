import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/widgets/common/action_feedback.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 50),
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
                      'Help & Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'The Curator',
                      style: TextStyle(
                        color: t.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Hero
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: t.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    children: [
                      const TextSpan(text: 'How can we '),
                      TextSpan(
                        text: 'support',
                        style: TextStyle(color: t.primary),
                      ),
                      const TextSpan(text: ' you\ntoday?'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  "Whether you've lost a treasure or found a memory, our community and support team are here to guide you.",
                  style: TextStyle(
                    color: t.onSurfaceVar,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.divider),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search, color: t.onSurfaceMuted, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: TextStyle(color: t.onSurface, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Search for questions (e.g. 'How to...')",
                            hintStyle: TextStyle(
                              color: t.onSurfaceMuted,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Browse by Category
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Browse by Category',
                  style: TextStyle(
                    color: t.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildCategoryCard(
                      t: t,
                      icon: Icons.person_outline_rounded,
                      iconBg: t.iconBg,
                      iconColor: t.primary,
                      title: 'Account',
                      subtitle:
                          'Privacy settings, password recovery, and profile verification',
                    ),
                    const SizedBox(height: 10),
                    _buildCategoryCard(
                      t: t,
                      icon: Icons.shield_outlined,
                      iconBg: t.iconBg,
                      iconColor: t.primary,
                      title: 'Safety',
                      subtitle: 'Community guidelines and secure meetups',
                    ),
                    const SizedBox(height: 10),
                    _buildCategoryCard(
                      t: t,
                      icon: Icons.camera_alt_outlined,
                      iconBg: t.surfaceHigh,
                      iconColor: t.onSurfaceVar,
                      title: 'Posting Items',
                      subtitle: 'How to create effective reports',
                    ),
                    const SizedBox(height: 10),
                    _buildMessagingCard(t),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Still have questions? banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  decoration: BoxDecoration(
                    color: t.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Still have questions?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Our live support team is active 24/7',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.headset_mic_outlined,
                        color: Colors.white38,
                        size: 42,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Online indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: t.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: t.iconBg,
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: t.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Curator Support is Online',
                      style: TextStyle(
                        color: t.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Direct assistance for\nurgent matters.',
                  style: TextStyle(
                    color: t.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Contact Support button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.primary,
                      foregroundColor: t.isDark ? Colors.black : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => ActionFeedback.showInfo(
                      context,
                      'Opening in-app support chat...',
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Email Us button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.primary,
                      side: BorderSide(color: t.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => ActionFeedback.showInfo(
                      context,
                      'Email support at support@finder.app',
                    ),
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text(
                      'Email Us',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Technical Feedback card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
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
                      Row(
                        children: [
                          Icon(
                            Icons.bug_report_outlined,
                            color: t.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TECHNICAL FEEDBACK',
                            style: TextStyle(
                              color: t.warning,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Found a glitch?',
                        style: TextStyle(
                          color: t.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Help us improve the curator experience by reporting technical issues directly to our engineering team.',
                        style: TextStyle(
                          color: t.onSurfaceVar,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => ActionFeedback.showInfo(
                          context,
                          'Issue reporting flow will open here.',
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Report a Technical Issue',
                              style: TextStyle(
                                color: t.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: t.primary,
                              size: 15,
                            ),
                          ],
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

  Widget _buildCategoryCard({
    required AppColorTokens t,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () => ActionFeedback.showComingSoon(context, feature: title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 14),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: t.onSurfaceVar,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: t.onSurfaceMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagingCard(AppColorTokens t) {
    return GestureDetector(
      onTap: () => ActionFeedback.showComingSoon(
        context,
        feature: 'Messaging help details',
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: t.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.forum_outlined,
                color: t.onSurfaceVar,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messaging',
                    style: TextStyle(
                      color: t.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contacting finders and coordination',
                    style: TextStyle(
                      color: t.onSurfaceVar,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _stackedAvatar('A', const Color(0xFF7C3AED), t),
                      _stackedAvatar(
                        'B',
                        const Color(0xFF0284C7),
                        t,
                        offset: -10,
                      ),
                      _stackedAvatar(
                        'C',
                        const Color(0xFF059669),
                        t,
                        offset: -10,
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: t.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+12',
                          style: TextStyle(
                            color: t.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stackedAvatar(
    String letter,
    Color color,
    AppColorTokens t, {
    double offset = 0,
  }) {
    return Transform.translate(
      offset: Offset(offset, 0),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: t.surface, width: 2),
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
