import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/custom_text_field.dart';
import 'package:finder/widgets/social_button.dart';
import 'package:finder/providers/auth_provider.dart';
import 'package:finder/core/validation/validators.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

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
    final t = AppColorTokens.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: t.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  color: t.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Get Started For Free',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: t.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your Finder account to report\nand track lost & found items.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: t.onSurfaceVar,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              _label('Email Address', t),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailCtrl,
                hintText: 'yourname@gmail.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _label('Your Name', t),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameCtrl,
                hintText: '@yourname',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _label('Phone Number', t),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _phoneCtrl,
                hintText: '+1 234 567 8900',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _label('Password', t),
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
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final email = _emailCtrl.text.trim();
                          final password = _passwordCtrl.text.trim();
                          final name = _nameCtrl.text.trim();
                          final phone = _phoneCtrl.text.trim();
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
                            await ref.read(authServiceProvider).signUpWithEmailPassword(
                              email: email,
                              password: password,
                              fullName: name,
                              phone: phone,
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
                          'Sign up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(child: Divider(color: t.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Or sign up with',
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
                      feature: 'Google sign up',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SocialButton(
                    icon: Icons.apple,
                    color: t.onSurface,
                    onTap: () => ActionFeedback.showComingSoon(
                      context,
                      feature: 'Apple sign up',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SocialButton(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () => ActionFeedback.showComingSoon(
                      context,
                      feature: 'Facebook sign up',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: t.onSurfaceVar, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                    child: Text(
                      'Log in',
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

  Widget _label(String text, AppColorTokens t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: t.onSurfaceVar,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
