import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/widgets/custom_text_field.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyEmail() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit verification code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref.read(authControllerProvider.notifier).verifyEmail(code: code);
    if (mounted) setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account verified successfully! Welcome to Finder.')),
        );
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _handleResendCode() async {
    setState(() => _isLoading = true);
    final result = await ref.read(authControllerProvider.notifier).resendVerificationCode();
    if (mounted) setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new verification code has been sent to your email.')),
        );
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: t.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    color: t.primary,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: t.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  'We have sent a 6-digit verification code to your registered email address. Please enter the code below to verify your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: t.onSurfaceVar,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // Form label & custom field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Verification Code',
                    style: TextStyle(
                      color: t.onSurfaceVar,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _codeCtrl,
                  hintText: '6-digit OTP',
                  prefixIcon: Icons.numbers_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerifyEmail,
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
                            'Verify Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Option links
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _isLoading ? null : _handleLogout,
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Cancel / Log Out'),
                      style: TextButton.styleFrom(
                        foregroundColor: t.onSurfaceMuted,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _handleResendCode,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Resend Code'),
                      style: TextButton.styleFrom(
                        foregroundColor: t.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
