import 'package:flutter/material.dart';
import 'beacon_colors.dart';

/// Semantic color tokens read from the active [ThemeData] at runtime.
///
/// This is a thin facade over [BeaconColors] that keeps the historic field
/// names (`onSurfaceVar`, `divider`, `warning`, …) so every call site keeps
/// compiling, while exposing the full Beacon palette as well.
///
/// Use `AppColorTokens.of(context)` at the top of `build()`.
class AppColorTokens {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  final Color bg;
  final Color surfaceLow;
  final Color surface;
  final Color surfaceHigh;

  // ── Brand ─────────────────────────────────────────────────────────────────
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color iconBg; // legacy alias of primaryContainer

  // ── Beacon accent ─────────────────────────────────────────────────────────
  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color accentGlow;

  // ── Signals ───────────────────────────────────────────────────────────────
  final Color lost;
  final Color onLost;
  final Color lostContainer;
  final Color found;
  final Color onFound;
  final Color foundContainer;

  // ── Text ──────────────────────────────────────────────────────────────────
  final Color onSurface;
  final Color onSurfaceVar;
  final Color onSurfaceMuted;

  // ── Lines & glass ─────────────────────────────────────────────────────────
  final Color outline;
  final Color outlineVariant;
  final Color divider; // legacy alias of outline
  final Color glassSurface;
  final Color glassBorder;

  // ── Semantic ──────────────────────────────────────────────────────────────
  final Color error;
  final Color onError;
  final Color errorSurface; // legacy alias of errorContainer
  final Color success; // legacy alias of found
  final Color warning; // legacy alias of accent
  final Color scrim;
  final Color shadow;

  // ── Mode flag ─────────────────────────────────────────────────────────────
  final bool isDark;

  /// Underlying extension, for widgets that want the raw palette.
  final BeaconColors beacon;

  const AppColorTokens._({
    required this.beacon,
    required this.isDark,
    required this.bg,
    required this.surfaceLow,
    required this.surface,
    required this.surfaceHigh,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.iconBg,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.accentGlow,
    required this.lost,
    required this.onLost,
    required this.lostContainer,
    required this.found,
    required this.onFound,
    required this.foundContainer,
    required this.onSurface,
    required this.onSurfaceVar,
    required this.onSurfaceMuted,
    required this.outline,
    required this.outlineVariant,
    required this.divider,
    required this.glassSurface,
    required this.glassBorder,
    required this.error,
    required this.onError,
    required this.errorSurface,
    required this.success,
    required this.warning,
    required this.scrim,
    required this.shadow,
  });

  factory AppColorTokens.fromBeacon(BeaconColors b, {required bool isDark}) {
    return AppColorTokens._(
      beacon: b,
      isDark: isDark,
      bg: b.bg,
      surfaceLow: b.surfaceLow,
      surface: b.surface,
      surfaceHigh: b.surfaceHigh,
      primary: b.primary,
      onPrimary: b.onPrimary,
      primaryContainer: b.primaryContainer,
      onPrimaryContainer: b.onPrimaryContainer,
      iconBg: b.primaryContainer,
      accent: b.accent,
      onAccent: b.onAccent,
      accentContainer: b.accentContainer,
      accentGlow: b.accentGlow,
      lost: b.lost,
      onLost: b.onLost,
      lostContainer: b.lostContainer,
      found: b.found,
      onFound: b.onFound,
      foundContainer: b.foundContainer,
      onSurface: b.onSurface,
      onSurfaceVar: b.onSurfaceVariant,
      onSurfaceMuted: b.onSurfaceMuted,
      outline: b.outline,
      outlineVariant: b.outlineVariant,
      divider: b.outline,
      glassSurface: b.glassSurface,
      glassBorder: b.glassBorder,
      error: b.error,
      onError: b.onError,
      errorSurface: b.errorContainer,
      success: b.found,
      warning: b.accent,
      scrim: b.scrim,
      shadow: b.shadow,
    );
  }

  /// Builds tokens from the nearest [ThemeData]. Falls back to the static
  /// Beacon palettes when the theme carries no [BeaconColors] extension
  /// (e.g. widget tests that pump a bare `MaterialApp`).
  static AppColorTokens of(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final beacon = theme.extension<BeaconColors>() ??
        (dark ? BeaconColors.dark : BeaconColors.light);
    return AppColorTokens.fromBeacon(beacon, isDark: dark);
  }
}
