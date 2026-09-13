import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'app_button.dart';

/// Pill search input with clear button and optional filter action.
class SearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool filterActive;
  final bool autofocus;
  final FocusNode? focusNode;

  const SearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.filterActive = false,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _ctrl =
      widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onText);
  }

  void _onText() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_onText);
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final hasText = _ctrl.text.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: TextField(
              controller: _ctrl,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              style: text.bodyLarge,
              cursorColor: t.primary,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search_rounded, size: BeaconIcon.md),
                suffixIcon: hasText
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _ctrl.clear();
                          widget.onChanged?.call('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: BeaconSpace.lg,
                  vertical: BeaconSpace.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BeaconRadius.rPill,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BeaconRadius.rPill,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BeaconRadius.rPill,
                  borderSide: BorderSide(color: t.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: BeaconSpace.sm),
          AppIconButton(
            icon: Icons.tune_rounded,
            tooltip: 'Filters',
            size: 52,
            variant: widget.filterActive
                ? AppIconButtonVariant.filled
                : AppIconButtonVariant.tonal,
            onPressed: widget.onFilterTap,
            badge: widget.filterActive ? const BadgeDot() : null,
          ),
        ],
      ],
    );
  }
}
