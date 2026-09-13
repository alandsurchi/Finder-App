import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          SnackBar(
            content: Text(isResend
              ? 'New verification code sent! Check your inbox or console logs.'
              : 'Verification code sent! Check your inbox or console logs.'
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
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (code.length != 6 || int.tryParse(code) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit numeric verification code')),
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
          const SnackBar(content: Text('Code verified successfully!')),
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
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm = _confirmPasswordCtrl.text.trim();

    if (!Validators.isStrongPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Validators.passwordRule)),
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
    String titleText = 'Forgot password';
    String descText = 'Enter your email address and we will send you a 6-digit verification code.';
    IconData headerIcon = Icons.lock_reset_rounded;

    if (_step == 2) {
      titleText = 'Check your inbox';
      descText = 'Enter the 6-digit verification code sent to ${_emailCtrl.text.trim()}.';
      headerIcon = Icons.pin_outlined;
    } else if (_step == 3) {
      titleText = 'Set a new password';
      descText = 'Create a secure new password for your account.';
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
    return [
      AppTextField(
        controller: _emailCtrl,
        label: 'Email address',
        hint: 'yourname@example.com',
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.email],
        onSubmitted: (_) => _isLoading ? null : _handleSendResetCode(),
      ),
      const SizedBox(height: BeaconSpace.xxxl),
      AppButton(
        label: 'Send verification code',
        isLoading: _isLoading,
        onPressed: _isLoading ? null : _handleSendResetCode,
      ),
      const SizedBox(height: BeaconSpace.lg),
      Center(
        child: AppButton.ghost(
          label: 'Cancel and log in',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    ];
  }

  List<Widget> _buildCodeStep() {
    return [
      AppTextField(
        controller: _codeCtrl,
        label: 'Verification code',
        hint: '6-digit code',
        prefixIcon: Icons.pin_outlined,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.oneTimeCode],
        onSubmitted: (_) => _isLoading ? null : _handleVerifyCode(),
      ),
      const SizedBox(height: BeaconSpace.xxxl),
      AppButton(
        label: 'Verify code',
        isLoading: _isLoading,
        onPressed: _isLoading ? null : _handleVerifyCode,
      ),
      const SizedBox(height: BeaconSpace.lg),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppButton.ghost(
            label: 'Change email',
            onPressed: () => setState(() => _step = 1),
          ),
          AppButton.ghost(
            label: 'Resend code',
            icon: Icons.refresh_rounded,
            onPressed: _isLoading ? null : () => _handleSendResetCode(isResend: true),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildResetStep() {
    return [
      AppTextField(
        controller: _passwordCtrl,
        label: 'New password',
        hint: 'Min. 6 characters',
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: true,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.newPassword],
      ),
      const SizedBox(height: BeaconSpace.lg),
      AppTextField(
        controller: _confirmPasswordCtrl,
        label: 'Confirm new password',
        hint: 'Retype new password',
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: true,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.newPassword],
        onSubmitted: (_) => _isLoading ? null : _handleResetPassword(),
      ),
      const SizedBox(height: BeaconSpace.xxxl),
      AppButton(
        label: 'Reset password',
        isLoading: _isLoading,
        onPressed: _isLoading ? null : _handleResetPassword,
      ),
      const SizedBox(height: BeaconSpace.lg),
      Center(
        child: AppButton.ghost(
          label: 'Start over / change email',
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
