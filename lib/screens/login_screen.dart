import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return AuthShell(
      icon: Icons.radar_rounded,
      title: 'Welcome back',
      subtitle: 'Log in to continue finding what matters.',
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'you@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: BeaconSpace.lg),
              AppTextField(
                controller: _passwordCtrl,
                label: 'Password',
                hint: 'Your password',
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
          alignment: Alignment.centerRight,
          child: AppButton.ghost(
            label: 'Forgot password?',
            onPressed: _sendPasswordReset,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: BeaconSpace.sm, bottom: BeaconSpace.xxxl),
          child: AppButton(
            label: 'Sign in',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
        ),
        const LabeledDivider(label: 'Or continue with'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xl),
          child: Center(
            child: SocialButton(
              imageAsset: 'assets/images/google_logo.png',
              semanticLabel: 'Continue with Google',
              onTap: _isLoading ? null : _handleGoogleSignIn,
            ),
          ),
        ),
        AuthFooterLink(
          prompt: "Don't have an account?",
          action: 'Sign up',
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
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (!Validators.isEmail(email)) {
      ActionFeedback.showError(context, 'Enter a valid email address.');
      return;
    }
    if (!Validators.hasMinLength(password, 6)) {
      ActionFeedback.showError(context, 'Password must be at least 6 characters.');
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
