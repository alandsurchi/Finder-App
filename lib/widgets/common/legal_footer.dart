import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:finder/screens/legal_screen.dart';
import 'package:finder/widgets/ui/ui.dart';

/// "By creating an account you agree to the Terms and Privacy Policy."
class LegalFooter extends StatelessWidget {
  const LegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
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
          const TextSpan(text: 'By creating an account you agree to the '),
          TextSpan(
            text: 'Terms of Service',
            style: link,
            recognizer: TapGestureRecognizer()..onTap = () => open(LegalDocKind.terms),
          ),
          const TextSpan(text: ' and the '),
          TextSpan(
            text: 'Privacy Policy',
            style: link,
            recognizer: TapGestureRecognizer()..onTap = () => open(LegalDocKind.privacy),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
