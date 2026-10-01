import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/social_button.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/widgets/common/legal_footer.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/core/validation/validators.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthShell(
      icon: Icons.person_add_alt_1_rounded,
      title: l10n.authSignupTitle,
      subtitle: l10n.authSignupSubtitle,
      showBack: true,
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _emailCtrl,
                label: l10n.authEmailAddressLabel,
                hint: l10n.authEmailAddressHint,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: BeaconSpace.lg),
              AppTextField(
                controller: _nameCtrl,
                label: l10n.authNameLabel,
                hint: l10n.authNameHint,
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: BeaconSpace.lg),
              AppTextField(
                controller: _phoneCtrl,
                label: l10n.authPhoneLabel,
                hint: l10n.authPhoneHint,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
              const SizedBox(height: BeaconSpace.lg),
              AppTextField(
                controller: _passwordCtrl,
                label: l10n.authPasswordLabel,
                hint: l10n.authSignupPasswordHint,
                helper: l10n.authPasswordRule,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _isLoading ? null : _submit(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: BeaconSpace.xxl, bottom: BeaconSpace.xxxl),
          child: AppButton(
            label: l10n.authCreateAccount,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
        ),
        LabeledDivider(label: l10n.authOrSignUpWith),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xl),
          child: Center(
            child: SocialButton(
              imageAsset: 'assets/images/google_logo.png',
              semanticLabel: l10n.authSignUpWithGoogle,
              onTap: _isLoading ? null : _handleGoogleSignIn,
            ),
          ),
        ),
        const LegalFooter(),
        const SizedBox(height: BeaconSpace.md),
        AuthFooterLink(
          prompt: l10n.authHaveAccountPrompt,
          action: l10n.authLogIn,
          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
        ),
      ],
    );
  }

  /// Sends the user to Home, or to e-mail verification when the backend
  /// still needs a code (only when SMTP is configured on the server).
  void _enterApp() {
    final status = ref.read(authStateProvider).status;
    final route = status == AuthStatus.unverified
        ? AppRoutes.emailVerification
        : AppRoutes.home;
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (!Validators.isEmail(email)) {
      ActionFeedback.showError(context, l10n.authInvalidEmail);
      return;
    }
    if (!Validators.isStrongPassword(password)) {
      ActionFeedback.showError(context, l10n.authPasswordRule);
      return;
    }

    setState(() => _isLoading = true);
    final res = await ref.read(authControllerProvider.notifier).signup(
      email: email,
      password: password,
      fullName: name,
      phone: phone,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    res.fold(
      onSuccess: (_) => _enterApp(),
      onFailure: (failure) => ActionFeedback.showError(context, failure.message),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final res = await ref.read(authControllerProvider.notifier).loginWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);
    res.fold(
      onSuccess: (_) => _enterApp(),
      onFailure: (failure) => ActionFeedback.showError(context, failure.message),
    );
  }
}
