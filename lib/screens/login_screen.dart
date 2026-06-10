import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/custom_text_field.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/social_button.dart';
import 'package:finder/providers/auth_provider.dart';
import 'package:finder/core/validation/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo / icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: t.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_rounded, color: t.primary, size: 40),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: t.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log in to continue finding what matters.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: t.onSurfaceVar),
              ),
              const SizedBox(height: 36),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: t.onSurfaceVar,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailCtrl,
                hintText: 'you@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    color: t.onSurfaceVar,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _passwordCtrl,
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                suffixIcon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: t.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _sendPasswordReset,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: t.primary, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
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
                          try {
                            await ref.read(authServiceProvider).loginWithEmailPassword(
                              email: email,
                              password: password,
                            );
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.primary,
                    foregroundColor: t.isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: Divider(color: t.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: t.onSurfaceMuted, fontSize: 13),
                    ),
                  ),
                  Expanded(child: Divider(color: t.divider)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton(
                    icon: Icons.g_mobiledata,
                    color: const Color(0xFFEA4335),
                    onTap: () => ActionFeedback.showComingSoon(
                      context,
                      feature: 'Google sign in',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SocialButton(
                    icon: Icons.apple,
                    color: t.onSurface,
                    onTap: () => ActionFeedback.showComingSoon(
                      context,
                      feature: 'Apple sign in',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SocialButton(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () => ActionFeedback.showComingSoon(
                      context,
                      feature: 'Facebook sign in',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: t.onSurfaceVar, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: t.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailCtrl.text.trim();
    if (!Validators.isEmail(email)) {
      ActionFeedback.showInfo(context, 'Enter your account email first.');
      return;
    }

    ActionFeedback.showInfo(
      context,
      'Password recovery is not supported in Railway mode. Please contact support.',
    );
  }
}
