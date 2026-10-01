import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/core/validation/validators.dart';
import 'package:finder/features/auth/presentation/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  int _step = 1; // 1: Email Request, 2: Code verification, 3: Password Reset
  bool _isLoading = false;

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

  Future<void> _handleSendResetCode({bool isResend = false}) async {
    final l10n = context.l10n;
    final email = _emailCtrl.text.trim();
    if (!Validators.isEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authForgotInvalidEmail)),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref.read(authControllerProvider.notifier).forgotPassword(email: email);
    setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isResend
              ? l10n.authForgotCodeResent
              : l10n.authForgotCodeSent
            ),
          ),
        );
        if (!isResend) {
          setState(() => _step = 2);
        }
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _handleVerifyCode() async {
    final l10n = context.l10n;
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (code.length != 6 || int.tryParse(code) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authForgotEnterNumericCode)),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ref.read(authControllerProvider.notifier).verifyResetCode(
          email: email,
          code: code,
        );
    setState(() => _isLoading = false);

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authForgotCodeVerified)),
        );
        setState(() => _step = 3);
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _handleResetPassword() async {
    final l10n = context.l10n;
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm = _confirmPasswordCtrl.text.trim();

    if (!Validators.isStrongPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPasswordRule)),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authForgotPasswordsMismatch)),
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
          SnackBar(content: Text(l10n.authForgotPasswordUpdated)),
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

  void _goBack() {
    if (_isLoading) return;
    if (_step == 3) {
      setState(() => _step = 2);
    } else if (_step == 2) {
      setState(() => _step = 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic title, description and icon based on the active step
    final l10n = context.l10n;
    String titleText = l10n.authForgotTitle;
    String descText = l10n.authForgotSubtitle;
    IconData headerIcon = Icons.lock_reset_rounded;

    if (_step == 2) {
      titleText = l10n.authForgotCheckInboxTitle;
      descText = l10n.authForgotCheckInboxSubtitle(_emailCtrl.text.trim());
      headerIcon = Icons.pin_outlined;
    } else if (_step == 3) {
      titleText = l10n.authForgotNewPasswordTitle;
      descText = l10n.authForgotNewPasswordSubtitle;
      headerIcon = Icons.password_rounded;
    }

    return AuthShell(
      key: ValueKey('forgot-step-$_step'),
      icon: headerIcon,
      title: titleText,
      subtitle: descText,
      showBack: true,
      onBack: _goBack,
      aboveTitle: StepDots(count: 3, current: _step - 1),
      children: [
        AnimatedSwitcher(
          duration: BeaconMotion.scaled(context, BeaconMotion.state),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Column(
            key: ValueKey(_step),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _step == 1
                ? _buildEmailStep()
                : _step == 2
                    ? _buildCodeStep()
                    : _buildResetStep(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEmailStep() {
    final l10n = context.l10n;
    return [
      AppTextField(
        controller: _emailCtrl,
        label: l10n.authEmailAddressLabel,
        hint: l10n.authEmailAddressHint,
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.email],
        onSubmitted: (_) => _isLoading ? null : _handleSendResetCode(),
      ),
      const SizedBox(height: BeaconSpace.xxxl),
      AppButton(
        label: l10n.authForgotSendCode,
        isLoading: _isLoading,
        onPressed: _isLoading ? null : _handleSendResetCode,
      ),
      const SizedBox(height: BeaconSpace.lg),
      Center(
        child: AppButton.ghost(
          label: l10n.authForgotCancelAndLogIn,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    ];
  }

  List<Widget> _buildCodeStep() {
    final l10n = context.l10n;
    return [
      AppTextField(
        controller: _codeCtrl,
        label: l10n.authVerificationCodeLabel,
        hint: l10n.authVerificationCodeHint,
        prefixIcon: Icons.pin_outlined,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.oneTimeCode],
        onSubmitted: (_) => _isLoading ? null : _handleVerifyCode(),
      ),
      const SizedBox(height: BeaconSpace.xxxl),
      AppButton(
        label: l10n.authVerifyCode,
        isLoading: _isLoading,
        onPressed: _isLoading ? null : _handleVerifyCode,
      ),
      const SizedBox(height: BeaconSpace.lg),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppButton.ghost(
            label: l10n.authChangeEmail,
            onPressed: () => setState(() => _step = 1),
          ),
          AppButton.ghost(
            label: l10n.authResendCode,
            icon: Icons.refresh_rounded,
            onPressed: _isLoading ? null : () => _handleSendResetCode(isResend: true),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildResetStep() {
    final l10n = context.l10n;
    return [
      AppTextField(
        controller: _passwordCtrl,
        label: l10n.authNewPasswordLabel,
        hint: l10n.authNewPasswordHint,
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: true,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.newPassword],
      ),
      const SizedBox(height: BeaconSpace.lg),
      AppTextField(
        controller: _confirmPasswordCtrl,
        label: l10n.authConfirmPasswordLabel,
        hint: l10n.authConfirmPasswordHint,
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: true,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.newPassword],
        onSubmitted: (_) => _isLoading ? null : _handleResetPassword(),
      ),
      const SizedBox(height: BeaconSpace.xxxl),
      AppButton(
        label: l10n.authResetPassword,
        isLoading: _isLoading,
        onPressed: _isLoading ? null : _handleResetPassword,
      ),
      const SizedBox(height: BeaconSpace.lg),
      Center(
        child: AppButton.ghost(
          label: l10n.authStartOver,
          onPressed: () => setState(() {
            _codeCtrl.clear();
            _passwordCtrl.clear();
            _confirmPasswordCtrl.clear();
            _step = 1;
          }),
        ),
      ),
    ];
  }
}
