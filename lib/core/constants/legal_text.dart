import 'package:finder/l10n/l10n.dart';

/// In-app copies of the legal documents. The hosted versions live in
/// `backend/public/legal/` and are linked from the store listings; keep the
/// two in step when either changes. The copy itself lives in the `legal*`
/// localization keys (one per heading / paragraph).
class LegalSection {
  final String heading;
  final String body;
  const LegalSection(this.heading, this.body);
}

class LegalDocument {
  final String title;
  final String updated;
  final String intro;
  final List<LegalSection> sections;
  const LegalDocument({
    required this.title,
    required this.updated,
    required this.intro,
    required this.sections,
  });
}

/// Joins paragraphs the way the original copy did (blank line between them).
String _paragraphs(List<String> parts) => parts.join('\n\n');

LegalDocument privacyPolicy(AppLocalizations l10n) => LegalDocument(
      title: l10n.legalPrivacyTitle,
      updated: l10n.legalUpdated,
      intro: l10n.legalPrivacyIntro,
      sections: [
        LegalSection(
          l10n.legalPrivacy1Heading,
          _paragraphs([
            l10n.legalPrivacy1Body1,
            l10n.legalPrivacy1Body2,
            l10n.legalPrivacy1Body3,
            l10n.legalPrivacy1Body4,
            l10n.legalPrivacy1Body5,
            l10n.legalPrivacy1Body6,
          ]),
        ),
        LegalSection(
          l10n.legalPrivacy2Heading,
          _paragraphs([l10n.legalPrivacy2Body1, l10n.legalPrivacy2Body2]),
        ),
        LegalSection(l10n.legalPrivacy3Heading, l10n.legalPrivacy3Body),
        LegalSection(l10n.legalPrivacy4Heading, l10n.legalPrivacy4Body),
        LegalSection(l10n.legalPrivacy5Heading, l10n.legalPrivacy5Body),
        LegalSection(
          l10n.legalPrivacy6Heading,
          _paragraphs([
            l10n.legalPrivacy6Body1,
            l10n.legalPrivacy6Body2,
            l10n.legalPrivacy6Body3,
          ]),
        ),
        LegalSection(l10n.legalPrivacy7Heading, l10n.legalPrivacy7Body),
        LegalSection(l10n.legalPrivacy8Heading, l10n.legalPrivacy8Body),
      ],
    );

LegalDocument termsOfService(AppLocalizations l10n) => LegalDocument(
      title: l10n.legalTermsTitle,
      updated: l10n.legalUpdated,
      intro: l10n.legalTermsIntro,
      sections: [
        LegalSection(l10n.legalTerms1Heading, l10n.legalTerms1Body),
        LegalSection(l10n.legalTerms2Heading, l10n.legalTerms2Body),
        LegalSection(l10n.legalTerms3Heading, l10n.legalTerms3Body),
        LegalSection(
          l10n.legalTerms4Heading,
          _paragraphs([l10n.legalTerms4Body1, l10n.legalTerms4Body2]),
        ),
        LegalSection(l10n.legalTerms5Heading, l10n.legalTerms5Body),
        LegalSection(l10n.legalTerms6Heading, l10n.legalTerms6Body),
        LegalSection(l10n.legalTerms7Heading, l10n.legalTerms7Body),
        LegalSection(l10n.legalTerms8Heading, l10n.legalTerms8Body),
        LegalSection(l10n.legalTerms9Heading, l10n.legalTerms9Body),
        LegalSection(l10n.legalTerms10Heading, l10n.legalTerms10Body),
      ],
    );
