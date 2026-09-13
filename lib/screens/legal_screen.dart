import 'package:flutter/material.dart';
import 'package:finder/core/config/app_config.dart';
import 'package:finder/core/constants/legal_text.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

enum LegalDocKind { privacy, terms }

/// Privacy policy / terms of service, rendered in-app with a link to the
/// hosted copy.
class LegalScreen extends StatelessWidget {
  final LegalDocKind kind;
  const LegalScreen({super.key, required this.kind});

  LegalDocument get _doc =>
      kind == LegalDocKind.privacy ? privacyPolicy : termsOfService;

  String get _url => kind == LegalDocKind.privacy
      ? AppConfig.privacyPolicyUrl
      : AppConfig.termsUrl;

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final doc = _doc;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: doc.title,
              subtitle: doc.updated,
              actions: [
                AppIconButton(
                  icon: Icons.open_in_new_rounded,
                  tooltip: 'Open web version',
                  onPressed: () async {
                    final ok = await launchUrl(Uri.parse(_url),
                        mode: LaunchMode.externalApplication);
                    if (!ok && context.mounted) {
                      ActionFeedback.showInfo(context, 'Could not open $_url');
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  BeaconSpace.page,
                  0,
                  BeaconSpace.page,
                  BeaconSpace.xxxl + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  StaggeredEntrance(
                    child: SurfaceCard(
                      tone: SurfaceTone.primary,
                      child: Text(doc.intro,
                          style: text.bodyLarge?.copyWith(color: t.onPrimaryContainer)),
                    ),
                  ),
                  const SizedBox(height: BeaconSpace.xl),
                  for (var i = 0; i < doc.sections.length; i++)
                    StaggeredEntrance(
                      index: (i + 1).clamp(0, 8),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: BeaconSpace.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.sections[i].heading, style: text.titleMedium),
                            const SizedBox(height: BeaconSpace.sm),
                            Text(doc.sections[i].body, style: text.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
