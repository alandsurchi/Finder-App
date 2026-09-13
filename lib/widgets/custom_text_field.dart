import 'package:flutter/material.dart';
import 'package:finder/widgets/ui/app_text_field.dart';

/// Legacy entry point kept for the auth screens; renders an [AppTextField].
class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? label;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.label,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hintText,
      prefixIcon: prefixIcon,
      // The built-in eye toggle replaces any passed static eye icon.
      suffix: obscureText ? null : suffixIcon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
    );
  }
}
