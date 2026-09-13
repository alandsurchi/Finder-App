import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Labeled text field. Label sits above the field, helper/error below, and a
/// password eye toggle is built in when [obscureText] is true.
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool required;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final String? initialValue;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.required = false,
    this.focusNode,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.initialValue,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;

    Widget? suffix = widget.suffix;
    if (widget.obscureText) {
      suffix = IconButton(
        tooltip: _obscure ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: BeaconIcon.md,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(widget.label!, style: text.titleSmall),
              if (widget.required)
                Text(' *', style: text.titleSmall?.copyWith(color: t.error)),
            ],
          ),
          const SizedBox(height: BeaconSpace.sm),
        ],
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          style: text.bodyLarge,
          cursorColor: t.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helper,
            errorText: widget.errorText,
            counterText: '',
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: BeaconIcon.md)
                : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// A read-only field that looks like a text field but opens a picker.
class AppPickerField extends StatelessWidget {
  final String? label;
  final String value;
  final String? hint;
  final IconData? prefixIcon;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  const AppPickerField({
    super.key,
    this.label,
    required this.value,
    this.hint,
    this.prefixIcon,
    this.trailingIcon = Icons.expand_more_rounded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final hasValue = value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: text.titleSmall),
          const SizedBox(height: BeaconSpace.sm),
        ],
        Material(
          color: t.surfaceLow,
          borderRadius: BeaconRadius.rMd,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BeaconSpace.lg,
                vertical: BeaconSpace.lg,
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: BeaconIcon.md, color: t.onSurfaceVar),
                    const SizedBox(width: BeaconSpace.md),
                  ],
                  Expanded(
                    child: Text(
                      hasValue ? value : (hint ?? ''),
                      style: text.bodyLarge?.copyWith(
                        color: hasValue ? t.onSurface : t.onSurfaceMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(trailingIcon, size: BeaconIcon.md, color: t.onSurfaceVar),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
