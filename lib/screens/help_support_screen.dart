import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finder/l10n/l10n.dart';
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

List<_Topic> _topics(AppLocalizations l10n) => [
      _Topic(Icons.person_outline_rounded, l10n.profileAccount, l10n.helpTopicAccountSubtitle, [
        _Faq(l10n.helpFaqChangeNameQ, l10n.helpFaqChangeNameA),
        _Faq(l10n.helpFaqForgotPasswordQ, l10n.helpFaqForgotPasswordA),
        _Faq(l10n.helpFaqVerifiedBadgeQ, l10n.helpFaqVerifiedBadgeA),
        _Faq(l10n.helpFaqDeleteAccountQ, l10n.helpFaqDeleteAccountA),
      ]),
      _Topic(Icons.shield_outlined, l10n.helpTopicSafety, l10n.helpTopicSafetySubtitle, [
        _Faq(l10n.helpFaqMeetQ, l10n.helpFaqMeetA),
        _Faq(l10n.helpFaqBotheringQ, l10n.helpFaqBotheringA),
        _Faq(l10n.helpFaqRewardQ, l10n.helpFaqRewardA),
      ]),
      _Topic(Icons.camera_alt_outlined, l10n.helpTopicPosting, l10n.helpTopicPostingSubtitle, [
        _Faq(l10n.helpFaqGoodPostQ, l10n.helpFaqGoodPostA),
        _Faq(l10n.helpFaqMarkReturnedQ, l10n.helpFaqMarkReturnedA),
        _Faq(l10n.helpFaqEditPostQ, l10n.helpFaqEditPostA),
      ]),
      _Topic(Icons.forum_outlined, l10n.helpTopicMessaging, l10n.helpTopicMessagingSubtitle, [
        _Faq(l10n.helpFaqContactOwnerQ, l10n.helpFaqContactOwnerA),
        _Faq(l10n.helpFaqSendPhotosQ, l10n.helpFaqSendPhotosA),
        _Faq(l10n.helpFaqCantMessageQ, l10n.helpFaqCantMessageA),
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

  List<_Faq> _matchesIn(List<_Topic> topics) {
    final q = _query.trim().toLowerCase();
    if (q.length < 2) return const [];
    return [
      for (final t in topics)
        for (final f in t.faqs)
          if (f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q)) f,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final topics = _topics(l10n);
    final matches = _matchesIn(topics);
    final searching = _query.trim().length >= 2;

    return Scaffold(
      body: BeaconBackdrop(
        alignment: const Alignment(1.3, -1.2),
        child: SafeArea(
          child: Column(
            children: [
              AppPageHeader(title: l10n.helpTitle),
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
                              TextSpan(text: l10n.helpHeroPrefix),
                              TextSpan(text: l10n.helpHeroAccent, style: TextStyle(color: t.primary)),
                              TextSpan(text: l10n.helpHeroSuffix),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: BeaconSpace.sm),
                      StaggeredEntrance(
                        index: 1,
                        child: Text(
                          l10n.helpIntro,
                          style: text.bodyMedium,
                        ),
                      ),

                      const SizedBox(height: BeaconSpace.xl),

                      StaggeredEntrance(
                        index: 2,
                        child: SearchField(
                          controller: _searchCtrl,
                          hint: l10n.helpSearchHint,
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
                                    l10n.helpNoAnswers(_query.trim()),
                                    style: text.bodyMedium,
                                  ),
                                )
                              : SettingsGroup(
                                  title: l10n.helpAnswersCount(matches.length),
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
                            title: l10n.helpBrowseByTopic,
                            children: [
                              for (final topic in topics)
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
                                      Text(l10n.helpStillQuestions,
                                          style: text.titleLarge?.copyWith(color: t.onPrimary)),
                                      const SizedBox(height: BeaconSpace.xs),
                                      Text(
                                        l10n.helpEmailReply,
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
                          label: l10n.helpEmailSupport,
                          icon: Icons.mail_outline_rounded,
                          onPressed: () => _email(
                            subject: l10n.helpEmailSubject,
                            body: l10n.helpEmailBody,
                          ),
                        ),
                      ),
                      const SizedBox(height: BeaconSpace.md),
                      StaggeredEntrance(
                        index: 5,
                        child: AppButton.secondary(
                          label: l10n.helpCopyAddress,
                          icon: Icons.copy_rounded,
                          onPressed: () async {
                            await Clipboard.setData(const ClipboardData(text: _kSupportEmail));
                            if (!context.mounted) return;
                            ActionFeedback.showInfo(context, l10n.helpAddressCopied(_kSupportEmail));
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
                                  Text(l10n.helpTechnicalFeedback,
                                      style: text.labelSmall?.copyWith(color: t.accent)),
                                ],
                              ),
                              const SizedBox(height: BeaconSpace.md),
                              Text(l10n.helpFoundGlitch, style: text.titleLarge),
                              const SizedBox(height: BeaconSpace.sm),
                              Text(
                                l10n.helpGlitchBody,
                                style: text.bodyMedium,
                              ),
                              const SizedBox(height: BeaconSpace.md),
                              AppButton.ghost(
                                label: l10n.helpReportIssue,
                                icon: Icons.arrow_forward_rounded,
                                iconTrailing: true,
                                onPressed: () => _email(
                                  subject: l10n.helpBugSubject,
                                  body: l10n.helpBugBody,
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
      ActionFeedback.showInfo(context, context.l10n.helpNoEmailApp(_kSupportEmail));
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
              label: context.l10n.helpGotIt,
              onPressed: () => Navigator.pop(sheetCtx),
            ),
            const SizedBox(height: BeaconSpace.lg),
          ],
        ),
      ),
    );
  }
}
