import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

const _kSupportEmail = 'support@finder.app';

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

class _Topic {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_Faq> faqs;
  const _Topic(this.icon, this.title, this.subtitle, this.faqs);
}

const _topics = <_Topic>[
  _Topic(Icons.person_outline_rounded, 'Account',
      'Profile, verification and passwords', [
    _Faq('How do I change my name or photo?',
        'Open Profile, tap "Edit profile", change the fields and save. The new photo shows on all your posts and messages.'),
    _Faq('I forgot my password.',
        'On the sign-in screen tap "Forgot password?". A reset code is sent to your e-mail; enter it together with your new password.'),
    _Faq('What does the verified badge mean?',
        'A verified member confirmed their identity with an ID document and a selfie. Start from Profile → Get verified. Review takes about a day.'),
    _Faq('How do I delete my account?',
        'Go to Privacy & safety → Request data deletion. We remove your posts, conversations and profile within 30 days.'),
  ]),
  _Topic(Icons.shield_outlined, 'Safety', 'Meet-ups and blocking', [
    _Faq('Where should I meet to hand over an item?',
        'Choose a busy public place in daylight, such as a café, a police station or a shopping centre. Bring a friend if you can.'),
    _Faq('Someone is bothering me.',
        'Open the conversation, tap the menu in the top-right corner and choose "Block". They can no longer see your posts or message you. Report the post too if it looks fake.'),
    _Faq('Should I pay a reward before I get my item back?',
        'No. Never send money before you have the item in your hands. Rewards are voluntary and paid at the hand-over.'),
  ]),
  _Topic(Icons.camera_alt_outlined, 'Posting items', 'Writing reports that get matches', [
    _Faq('What makes a good post?',
        'A clear photo, a precise location, the date and time, and distinctive details (scratches, stickers, engravings). Keep serial numbers private until someone proves they own the item.'),
    _Faq('How do I mark an item as returned?',
        'Open the post or go to My posts and choose "Mark as resolved". Everyone who chatted with you about it gets a notification.'),
    _Faq('Can I edit or delete a post?',
        'Yes. From My posts tap Edit, or open the post and use the menu in the top-right corner to edit, resolve or delete it.'),
  ]),
  _Topic(Icons.forum_outlined, 'Messaging', 'Contacting owners and finders', [
    _Faq('How do I contact the owner of a post?',
        'Open the post and tap "Chat with owner" (or "I found this item"). A conversation about that item opens in Messages.'),
    _Faq('Can I send photos?',
        'Yes. In a conversation tap the photo button next to the message field to send a picture as proof.'),
    _Faq('Why can\'t I message someone?',
        'Either one of you blocked the other, or they turned off direct messages in their privacy settings.'),
  ]),
];

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Faq> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.length < 2) return const [];
    return [
      for (final t in _topics)
        for (final f in t.faqs)
          if (f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q)) f,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final matches = _matches;
    final searching = _query.trim().length >= 2;

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
                      StaggeredEntrance(
                        child: RichText(
                          text: TextSpan(
                            style: text.headlineLarge,
                            children: [
                              const TextSpan(text: 'How can we '),
                              TextSpan(text: 'support', style: TextStyle(color: t.primary)),
                              const TextSpan(text: ' you today?'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: BeaconSpace.sm),
                      StaggeredEntrance(
                        index: 1,
                        child: Text(
                          "Whether you've lost a treasure or found a memory, the answers below cover most questions.",
                          style: text.bodyMedium,
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xl),

                      StaggeredEntrance(
                        index: 2,
                        child: SearchField(
                          controller: _searchCtrl,
                          hint: "Search questions (e.g. 'password')",
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      if (searching)
                        StaggeredEntrance(
                          index: 3,
                          child: matches.isEmpty
                              ? SurfaceCard(
                                  tone: SurfaceTone.low,
                                  child: Text(
                                    'No answers match "${_query.trim()}". Try another word or contact us below.',
                                    style: text.bodyMedium,
                                  ),
                                )
                              : SettingsGroup(
                                  title: '${matches.length} answer${matches.length == 1 ? '' : 's'}',
                                  children: [
                                    for (final f in matches)
                                      SettingsTile(
                                        icon: Icons.help_outline_rounded,
                                        title: f.question,
                                        onTap: () => _showAnswer(f),
                                      ),
                                  ],
                                ),
                        )
                      else
                        StaggeredEntrance(
                          index: 3,
                          child: SettingsGroup(
                            title: 'Browse by topic',
                            children: [
                              for (final topic in _topics)
                                SettingsTile(
                                  icon: topic.icon,
                                  title: topic.title,
                                  subtitle: topic.subtitle,
                                  onTap: () => _showTopic(topic),
                                ),
                            ],
                          ),
                        ),

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
                                      Text('Still have questions?',
                                          style: text.titleLarge?.copyWith(color: t.onPrimary)),
                                      const SizedBox(height: BeaconSpace.xs),
                                      Text(
                                        'E-mail us and we reply within one working day.',
                                        style: text.bodyMedium?.copyWith(
                                          color: t.onPrimary.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.headset_mic_outlined,
                                    color: t.onPrimary.withValues(alpha: 0.5), size: 42),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xl),

                      StaggeredEntrance(
                        index: 5,
                        child: AppButton(
                          label: 'E-mail support',
                          icon: Icons.mail_outline_rounded,
                          onPressed: () => _email(
                            subject: 'Finder support request',
                            body: 'Hi Finder team,\n\n',
                          ),
                        ),
                      ),
                      const SizedBox(height: BeaconSpace.md),
                      StaggeredEntrance(
                        index: 5,
                        child: AppButton.secondary(
                          label: 'Copy support address',
                          icon: Icons.copy_rounded,
                          onPressed: () async {
                            await Clipboard.setData(const ClipboardData(text: _kSupportEmail));
                            if (!context.mounted) return;
                            ActionFeedback.showInfo(context, '$_kSupportEmail copied.');
                          },
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xxl),

                      StaggeredEntrance(
                        index: 6,
                        child: SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bug_report_outlined, color: t.accent, size: 18),
                                  const SizedBox(width: BeaconSpace.sm),
                                  Text('TECHNICAL FEEDBACK',
                                      style: text.labelSmall?.copyWith(color: t.accent)),
                                ],
                              ),
                              const SizedBox(height: BeaconSpace.md),
                              Text('Found a glitch?', style: text.titleLarge),
                              const SizedBox(height: BeaconSpace.sm),
                              Text(
                                'Tell us what you did, what you expected and what happened instead. Screenshots help a lot.',
                                style: text.bodyMedium,
                              ),
                              const SizedBox(height: BeaconSpace.md),
                              AppButton.ghost(
                                label: 'Report a technical issue',
                                icon: Icons.arrow_forward_rounded,
                                iconTrailing: true,
                                onPressed: () => _email(
                                  subject: 'Finder bug report',
                                  body: 'What I did:\n\nWhat I expected:\n\nWhat happened:\n\nDevice / platform:\n',
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

  Future<void> _email({required String subject, required String body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _kSupportEmail,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    var ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) {
      await Clipboard.setData(const ClipboardData(text: _kSupportEmail));
      if (!mounted) return;
      ActionFeedback.showInfo(
        context,
        'No e-mail app found. $_kSupportEmail was copied to your clipboard.',
      );
    }
  }

  void _showTopic(_Topic topic) {
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: topic.title,
        subtitle: topic.subtitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final f in topic.faqs)
              SheetOption(
                icon: Icons.help_outline_rounded,
                label: f.question,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showAnswer(f);
                },
              ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }

  void _showAnswer(_Faq faq) {
    final text = Theme.of(context).textTheme;
    AppBottomSheet.show<void>(
      context,
      builder: (sheetCtx) => AppBottomSheet(
        title: faq.question,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(faq.answer, style: text.bodyLarge),
            const SizedBox(height: BeaconSpace.xl),
            AppButton.tonal(
              label: 'Got it',
              onPressed: () => Navigator.pop(sheetCtx),
            ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }
}
