import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/common/action_feedback.dart';
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
      ActionFeedback.showError(context, context.l10n.authVerifyEnterCode);
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref.read(authControllerProvider.notifier).verifyEmail(code: code);
    if (mounted) setState(() => _isLoading = false);

    if (!mounted) return;
    result.fold(
      onSuccess: (_) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = Navigator.of(context, rootNavigator: true).context;
          ActionFeedback.showSuccess(ctx, ctx.l10n.authVerifiedWelcome);
        });
      },
      onFailure: (failure) => ActionFeedback.showError(context, failure.message),
    );
  }

  Future<void> _handleResendCode() async {
    setState(() => _isLoading = true);
    final result = await ref.read(authControllerProvider.notifier).resendVerificationCode();
    if (mounted) setState(() => _isLoading = false);

    if (!mounted) return;
    result.fold(
      onSuccess: (_) => ActionFeedback.showSuccess(
        context,
        context.l10n.authVerifyCodeResent,
      ),
      onFailure: (failure) => ActionFeedback.showError(context, failure.message),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthShell(
      icon: Icons.mark_email_unread_outlined,
      title: l10n.authVerifyTitle,
      subtitle: l10n.authVerifySubtitle,
      children: [
        AppTextField(
          controller: _codeCtrl,
          label: l10n.authVerificationCodeLabel,
          hint: l10n.authVerificationCodeHint,
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
            label: l10n.authVerifyAccount,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleVerifyEmail,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton.ghost(
              label: l10n.commonLogOut,
              icon: Icons.logout_rounded,
              onPressed: _isLoading ? null : _handleLogout,
            ),
            AppButton.ghost(
              label: l10n.authResendCode,
              icon: Icons.refresh_rounded,
              onPressed: _isLoading ? null : _handleResendCode,
            ),
          ],
        ),
      ],
    );
  }
}
