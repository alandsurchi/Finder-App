import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';

class SectionCard extends StatelessWidget {
  final Widget header;
  final List<Widget> children;
  
  const SectionCard({
    super.key,
    required this.header,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, const SizedBox(height: 14), ...children],
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String label;
  final bool tiny;
  
  const FieldLabel({
    super.key,
    required this.label,
    this.tiny = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          color: tiny ? t.onSurfaceMuted : t.onSurfaceVar,
          fontSize: tiny ? 10 : 11,
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GlassField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType? keyboardType;
  
  const GlassField({
    super.key,
    this.controller,
    required this.hint,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.divider),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: t.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: t.onSurfaceMuted, fontSize: 13),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: t.onSurfaceMuted, size: 18)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class ContactMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool value;
  final ValueChanged<bool> onChanged;
  
  const ContactMethodTile({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: value ? t.primary.withOpacity(0.12) : t.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: value ? t.primary.withOpacity(0.4) : t.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? t.primary : t.onSurfaceVar, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(label,
                    style: TextStyle(
                        color: value ? t.onSurface : t.onSurfaceVar, fontSize: 13)),
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: t.warning,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class TypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  
  const TypeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 88,
        decoration: BoxDecoration(
          color: selected ? selectedColor.withOpacity(0.15) : t.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? selectedColor : t.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? selectedColor.withOpacity(0.25) : t.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: selected ? selectedColor : t.onSurfaceVar, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? t.onSurface : t.onSurfaceVar,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
