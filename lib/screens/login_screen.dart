import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/social_button.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/core/validation/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthShell(
      icon: Icons.radar_rounded,
      title: l10n.authLoginTitle,
      subtitle: l10n.authLoginSubtitle,
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _emailCtrl,
                label: l10n.authEmailLabel,
                hint: l10n.authEmailHint,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: BeaconSpace.lg),
              AppTextField(
                controller: _passwordCtrl,
                label: l10n.authPasswordLabel,
                hint: l10n.authPasswordHint,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _isLoading ? null : _submit(),
              ),
            ],
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppButton.ghost(
            label: l10n.authForgotPassword,
            onPressed: _sendPasswordReset,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: BeaconSpace.sm, bottom: BeaconSpace.xxxl),
          child: AppButton(
            label: l10n.authSignIn,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
        ),
        LabeledDivider(label: l10n.authOrContinueWith),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xl),
          child: Center(
            child: SocialButton(
              imageAsset: 'assets/images/google_logo.png',
              semanticLabel: l10n.authContinueWithGoogle,
              onTap: _isLoading ? null : _handleGoogleSignIn,
            ),
          ),
        ),
        AuthFooterLink(
          prompt: l10n.authNoAccountPrompt,
          action: l10n.authSignUp,
          onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
        ),
      ],
    );
  }

  /// Sends the user to Home, or to e-mail verification when the account is
  /// not verified yet. The auth state was already updated by the controller.
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
    if (!Validators.isEmail(email)) {
      ActionFeedback.showError(context, l10n.authInvalidEmail);
      return;
    }
    if (!Validators.hasMinLength(password, 6)) {
      ActionFeedback.showError(context, l10n.authPasswordMin6);
      return;
    }

    setState(() => _isLoading = true);
    final res = await ref.read(authControllerProvider.notifier).login(
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    res.fold(
      onSuccess: (_) => _enterApp(),
      onFailure: (failure) => ActionFeedback.showError(context, failure.message),
    );
  }

  void _sendPasswordReset() {
    final email = _emailCtrl.text.trim();
    Navigator.pushNamed(
      context,
      AppRoutes.forgotPassword,
      arguments: email.isNotEmpty ? email : null,
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
