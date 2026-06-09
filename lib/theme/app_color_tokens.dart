import 'package:flutter/material.dart';

/// Semantic color tokens read from the active [ThemeData] at runtime.
/// Use [AppColorTokens.of(context)] at the top of every build() method.
///
/// Light  = "The Empathetic Curator"  (DESIGN White Mode.md)
/// Dark   = "Glacier / Frozen Light"  (DESIGN Dark Mode.md)
class AppColorTokens {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  final Color bg;           // page / scaffold background
  final Color surface;      // card / sheet surface
  final Color surfaceHigh;  // elevated surface, input fill

  // ── Brand ─────────────────────────────────────────────────────────────────
  final Color primary;          // ice-blue (dark) / deep-blue (light)
  final Color primaryContainer; // very-light primary background
  final Color iconBg;           // small icon-button background

  // ── Text ──────────────────────────────────────────────────────────────────
  final Color onSurface;       // primary / heading text
  final Color onSurfaceVar;    // secondary / body text
  final Color onSurfaceMuted;  // hint / placeholder / captions

  // ── Borders ───────────────────────────────────────────────────────────────
  final Color divider;         // separator lines, card outlines

  // ── Semantic ──────────────────────────────────────────────────────────────
  final Color error;           // red / danger
  final Color errorSurface;    // error background container
  final Color success;         // green
  final Color warning;         // orange – always same (LOST badges, rewards)

  // ── Mode flag ─────────────────────────────────────────────────────────────
  final bool isDark;

  const AppColorTokens({
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.primary,
    required this.primaryContainer,
    required this.iconBg,
    required this.onSurface,
    required this.onSurfaceVar,
    required this.onSurfaceMuted,
    required this.divider,
    required this.error,
    required this.errorSurface,
    required this.success,
    required this.warning,
    required this.isDark,
  });

  /// Builds tokens from the nearest [ThemeData] in the widget tree.
  static AppColorTokens of(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final dark  = cs.brightness == Brightness.dark;

    return AppColorTokens(
      // ── Backgrounds ──
      bg:           theme.scaffoldBackgroundColor,
      surface:      cs.surface,
      surfaceHigh:  dark
          ? const Color(0xFF111827)   // Glacier layer-2
          : Colors.white,

      // ── Brand ──
      primary:          cs.primary,
      primaryContainer: cs.primaryContainer,
      iconBg: dark
          ? const Color(0xFF172030)   // dark primary tint
          : const Color(0xFFDBEAFE),  // light blue

      // ── Text ──
      onSurface:      cs.onSurface,
      onSurfaceVar:   cs.onSurfaceVariant,
      onSurfaceMuted: cs.onSurfaceVariant.withOpacity(0.6),

      // ── Borders ──
      divider: dark
          ? const Color(0x1A7DD3FC)   // ice-blue @ 10 %
          : const Color(0xFFE5E7EB),

      // ── Semantic ──
      error:        cs.error,
      errorSurface: dark
          ? const Color(0xFF2D0E0E)
          : const Color(0xFFFEF2F2),
      success: dark
          ? const Color(0xFF4ADE80)
          : const Color(0xFF22C55E),
      warning: const Color(0xFFF59E0B), // stays orange in both modes

      isDark: dark,
    );
  }
}
