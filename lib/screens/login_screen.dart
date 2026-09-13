import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/social_button.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';
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
    final t = AppColorTokens.of(context);

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialButton(
                imageAsset: 'assets/images/google_logo.png',
                semanticLabel: 'Continue with Google',
                onTap: _isLoading
                    ? null
                    : () {
                        _handleGoogleSignIn();
                      },
              ),
              const SizedBox(width: BeaconSpace.lg),
              SocialButton(
                icon: Icons.apple,
                color: t.onSurface,
                semanticLabel: 'Continue with Apple',
                onTap: () => ActionFeedback.showComingSoon(
                  context,
                  feature: 'Apple sign in',
                ),
              ),
              const SizedBox(width: BeaconSpace.lg),
              SocialButton(
                icon: Icons.facebook,
                color: const Color(0xFF1877F2), // Facebook brand blue
                semanticLabel: 'Continue with Facebook',
                onTap: () => ActionFeedback.showComingSoon(
                  context,
                  feature: 'Facebook sign in',
                ),
              ),
            ],
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

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (!Validators.isEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email'),
        ),
      );
      return;
    }
    if (!Validators.hasMinLength(password, 6)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ref.read(authControllerProvider.notifier).login(
      email: email,
      password: password,
    );

    res.fold(
      onSuccess: (_) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        }
      },
      onFailure: (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
    );
    if (mounted) setState(() => _isLoading = false);
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
    res.fold(
      onSuccess: (_) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        }
      },
      onFailure: (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }
}
