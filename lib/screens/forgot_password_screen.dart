import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/custom_text_field.dart';
import 'package:finder/core/validation/validators.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  int _step = 1; // 1: Email Request, 2: Code verification & password reset
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        _emailCtrl.text = args;
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetCode() async {
    final email = _emailCtrl.text.trim();
    if (!Validators.isEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref.read(authControllerProvider.notifier).forgotPassword(email: email);
    setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent! Check your inbox or console logs.')),
        );
        setState(() => _step = 2);
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm = _confirmPasswordCtrl.text.trim();

    if (code.length != 6 || int.tryParse(code) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit numeric verification code')),
      );
      return;
    }

    if (!Validators.hasMinLength(password, 6)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref.read(authControllerProvider.notifier).resetPassword(
          email: email,
          code: code,
          newPassword: password,
        );
    setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully! Please log in.')),
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
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
              // Back Button / App bar helper
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                  onPressed: () {
                    if (_step == 2) {
                      setState(() => _step = 1);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Decorative recovery icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: t.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _step == 1 ? Icons.lock_reset_rounded : Icons.mark_email_read_outlined,
                  color: t.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Recovery title & description
              Text(
                _step == 1 ? 'Forgot Password' : 'Verify & Reset',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: t.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _step == 1
                    ? 'Enter your email address and we will send you a 6-digit verification code.'
                    : 'We have sent a verification code to ${_emailCtrl.text.trim()}. Please verify and type a new password.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: t.onSurfaceVar, height: 1.5),
              ),
              const SizedBox(height: 36),

              if (_step == 1) ..._buildEmailStep(t) else ..._buildResetStep(t),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmailStep(AppColorTokens t) {
    return [
      _label('Email Address', t),
      const SizedBox(height: 8),
      CustomTextField(
        controller: _emailCtrl,
        hintText: 'yourname@example.com',
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 32),

      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSendResetCode,
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
                  'Send Verification Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
      const SizedBox(height: 24),

      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Cancel and Log In',
          style: TextStyle(color: t.primary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }

  List<Widget> _buildResetStep(AppColorTokens t) {
    return [
      _label('Verification Code', t),
      const SizedBox(height: 8),
      CustomTextField(
        controller: _codeCtrl,
        hintText: '6-digit OTP',
        prefixIcon: Icons.numbers_rounded,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),

      _label('New Password', t),
      const SizedBox(height: 8),
      CustomTextField(
        controller: _passwordCtrl,
        hintText: 'Min. 6 characters',
        prefixIcon: Icons.lock_outline,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: t.onSurfaceMuted,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      const SizedBox(height: 16),

      _label('Confirm New Password', t),
      const SizedBox(height: 8),
      CustomTextField(
        controller: _confirmPasswordCtrl,
        hintText: 'Retype new password',
        prefixIcon: Icons.lock_outline,
        obscureText: _obscureConfirmPassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: t.onSurfaceMuted,
          ),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
      const SizedBox(height: 32),

      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleResetPassword,
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
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
      const SizedBox(height: 24),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => setState(() => _step = 1),
            child: Text(
              'Change Email',
              style: TextStyle(color: t.onSurfaceVar, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _handleSendResetCode,
            child: Text(
              'Resend Code',
              style: TextStyle(color: t.primary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ];
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
