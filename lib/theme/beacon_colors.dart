import 'package:flutter/material.dart';

/// Beacon design system — semantic color roles.
///
/// Registered on [ThemeData.extensions] by `AppTheme`. Read it with
/// `AppColorTokens.of(context)` (the app-wide facade) or directly via
/// `Theme.of(context).extension<BeaconColors>()`.
///
/// Light = "Daylight"  · Dark = "Nightwatch"
@immutable
class BeaconColors extends ThemeExtension<BeaconColors> {
  // ── Surfaces ──────────────────────────────────────────────────────────────
  final Color bg;
  final Color surfaceLow;
  final Color surface;
  final Color surfaceHigh;

  // ── Brand ─────────────────────────────────────────────────────────────────
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  // ── Beacon accent (amber) ─────────────────────────────────────────────────
  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color accentGlow;

  // ── Signal colors ─────────────────────────────────────────────────────────
  final Color lost;
  final Color onLost;
  final Color lostContainer;
  final Color found;
  final Color onFound;
  final Color foundContainer;

  // ── Text ──────────────────────────────────────────────────────────────────
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color onSurfaceMuted;

  // ── Lines & glass ─────────────────────────────────────────────────────────
  final Color outline;
  final Color outlineVariant;
  final Color glassSurface;
  final Color glassBorder;

  // ── Semantic ──────────────────────────────────────────────────────────────
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color scrim;
  final Color shadow;

  const BeaconColors({
    required this.bg,
    required this.surfaceLow,
    required this.surface,
    required this.surfaceHigh,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
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
    required this.onSurfaceVariant,
    required this.onSurfaceMuted,
    required this.outline,
    required this.outlineVariant,
    required this.glassSurface,
    required this.glassBorder,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.scrim,
    required this.shadow,
  });

  /// "Daylight" — warm paper, deep teal, amber beacon.
  static const light = BeaconColors(
    bg: Color(0xFFF6F5F1),
    surfaceLow: Color(0xFFEFEDE7),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFE6E3DB),
    primary: Color(0xFF0B6E6A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD7F0EC),
    onPrimaryContainer: Color(0xFF05302E),
    accent: Color(0xFFF2A33A),
    onAccent: Color(0xFF3B2300),
    accentContainer: Color(0xFFFCEBD2),
    accentGlow: Color(0x38F2A33A),
    lost: Color(0xFFD9483B),
    onLost: Color(0xFFFFFFFF),
    lostContainer: Color(0xFFFBE4E1),
    found: Color(0xFF1E8E5A),
    onFound: Color(0xFFFFFFFF),
    foundContainer: Color(0xFFDDF3E7),
    onSurface: Color(0xFF17201F),
    onSurfaceVariant: Color(0xFF5A6664),
    onSurfaceMuted: Color(0xFF7F8A87),
    outline: Color(0xFFC9CFCB),
    outlineVariant: Color(0xFFE1E5E2),
    glassSurface: Color(0xE6FFFFFF),
    glassBorder: Color(0x1417201F),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFBE3E1),
    scrim: Color(0x6617201F),
    shadow: Color(0xFF17201F),
  );

  /// "Nightwatch" — deep ink, mint-teal, softened amber.
  static const dark = BeaconColors(
    bg: Color(0xFF0B1213),
    surfaceLow: Color(0xFF0F1819),
    surface: Color(0xFF121B1D),
    surfaceHigh: Color(0xFF1A2528),
    primary: Color(0xFF5FD4CB),
    onPrimary: Color(0xFF062A28),
    primaryContainer: Color(0xFF163B39),
    onPrimaryContainer: Color(0xFFB8ECE6),
    accent: Color(0xFFF5B45C),
    onAccent: Color(0xFF2B1A00),
    accentContainer: Color(0xFF3D2A0E),
    accentGlow: Color(0x2EF5B45C),
    lost: Color(0xFFFF7A6B),
    onLost: Color(0xFF2B0B07),
    lostContainer: Color(0xFF3A1A16),
    found: Color(0xFF4ADE80),
    onFound: Color(0xFF03240F),
    foundContainer: Color(0xFF143A24),
    onSurface: Color(0xFFE6EBE9),
    onSurfaceVariant: Color(0xFF93A29F),
    onSurfaceMuted: Color(0xFF6F7D7A),
    outline: Color(0x1AFFFFFF),
    outlineVariant: Color(0x0FFFFFFF),
    glassSurface: Color(0xE6121B1D),
    glassBorder: Color(0x14FFFFFF),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF2B0B07),
    errorContainer: Color(0xFF3A1616),
    scrim: Color(0x99000000),
    shadow: Color(0xFF000000),
  );

  @override
  BeaconColors copyWith({
    Color? bg,
    Color? surfaceLow,
    Color? surface,
    Color? surfaceHigh,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? accent,
    Color? onAccent,
    Color? accentContainer,
    Color? accentGlow,
    Color? lost,
    Color? onLost,
    Color? lostContainer,
    Color? found,
    Color? onFound,
    Color? foundContainer,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? onSurfaceMuted,
    Color? outline,
    Color? outlineVariant,
    Color? glassSurface,
    Color? glassBorder,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? scrim,
    Color? shadow,
  }) {
    return BeaconColors(
      bg: bg ?? this.bg,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentContainer: accentContainer ?? this.accentContainer,
      accentGlow: accentGlow ?? this.accentGlow,
      lost: lost ?? this.lost,
      onLost: onLost ?? this.onLost,
      lostContainer: lostContainer ?? this.lostContainer,
      found: found ?? this.found,
      onFound: onFound ?? this.onFound,
      foundContainer: foundContainer ?? this.foundContainer,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  BeaconColors lerp(ThemeExtension<BeaconColors>? other, double t) {
    if (other is! BeaconColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return BeaconColors(
      bg: l(bg, other.bg),
      surfaceLow: l(surfaceLow, other.surfaceLow),
      surface: l(surface, other.surface),
      surfaceHigh: l(surfaceHigh, other.surfaceHigh),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primaryContainer: l(primaryContainer, other.primaryContainer),
      onPrimaryContainer: l(onPrimaryContainer, other.onPrimaryContainer),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentContainer: l(accentContainer, other.accentContainer),
      accentGlow: l(accentGlow, other.accentGlow),
      lost: l(lost, other.lost),
      onLost: l(onLost, other.onLost),
      lostContainer: l(lostContainer, other.lostContainer),
      found: l(found, other.found),
      onFound: l(onFound, other.onFound),
      foundContainer: l(foundContainer, other.foundContainer),
      onSurface: l(onSurface, other.onSurface),
      onSurfaceVariant: l(onSurfaceVariant, other.onSurfaceVariant),
      onSurfaceMuted: l(onSurfaceMuted, other.onSurfaceMuted),
      outline: l(outline, other.outline),
      outlineVariant: l(outlineVariant, other.outlineVariant),
      glassSurface: l(glassSurface, other.glassSurface),
      glassBorder: l(glassBorder, other.glassBorder),
      error: l(error, other.error),
      onError: l(onError, other.onError),
      errorContainer: l(errorContainer, other.errorContainer),
      scrim: l(scrim, other.scrim),
      shadow: l(shadow, other.shadow),
    );
  }
}
