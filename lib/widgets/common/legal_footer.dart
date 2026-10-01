import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/screens/legal_screen.dart';
import 'package:finder/widgets/ui/ui.dart';

/// "By creating an account you agree to the Terms and Privacy Policy."
class LegalFooter extends StatelessWidget {
  const LegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final link = text.bodySmall?.copyWith(
      color: t.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: t.primary,
    );

    void open(LegalDocKind kind) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LegalScreen(kind: kind)),
        );

    return Text.rich(
      TextSpan(
        style: text.bodySmall,
        children: [
          TextSpan(text: l10n.authLegalAgreePrefix),
          TextSpan(
            text: l10n.legalTermsTitle,
            style: link,
            recognizer: TapGestureRecognizer()..onTap = () => open(LegalDocKind.terms),
          ),
          TextSpan(text: l10n.authLegalAgreeAnd),
          TextSpan(
            text: l10n.legalPrivacyTitle,
            style: link,
            recognizer: TapGestureRecognizer()..onTap = () => open(LegalDocKind.privacy),
          ),
          TextSpan(text: l10n.authLegalAgreeSuffix),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
