import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

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
    return AuthShell(
      icon: Icons.mark_email_unread_outlined,
      title: 'Verify your email',
      subtitle:
          'We sent a 6-digit verification code to your registered email address. Enter it below to activate your account.',
      children: [
        AppTextField(
          controller: _codeCtrl,
          label: 'Verification code',
          hint: '6-digit code',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          onSubmitted: (_) => _isLoading ? null : _handleVerifyEmail(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: BeaconSpace.xxxl, bottom: BeaconSpace.lg),
          child: AppButton(
            label: 'Verify account',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleVerifyEmail,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton.ghost(
              label: 'Log out',
              icon: Icons.logout_rounded,
              onPressed: _isLoading ? null : _handleLogout,
            ),
            AppButton.ghost(
              label: 'Resend code',
              icon: Icons.refresh_rounded,
              onPressed: _isLoading ? null : _handleResendCode,
            ),
          ],
        ),
      ],
    );
  }
}
