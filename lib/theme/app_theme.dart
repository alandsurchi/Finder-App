import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// APP THEME TOKENS
// Light  → "The Empathetic Curator"  (DESIGN White Mode.md)
// Dark   → "Glacier / Frozen Light"  (DESIGN Dark Mode.md)
// ═══════════════════════════════════════════════════════════════════════════════

class AppColors {
  // ── Light (Empathetic Curator) ────────────────────────────────────────────
  static const lightBg              = Color(0xFFF8F9FF);   // surface
  static const lightSurface         = Color(0xFFFFFFFF);   // surface-container-lowest
  static const lightContainer       = Color(0xFFE6EEFF);   // surface-container
  static const lightContainerHigh   = Color(0xFFD5E3FC);   // surface-container-highest
  static const lightPrimary         = Color(0xFF2563EB);   // primary (CTA gradient end)
  static const lightPrimaryDark     = Color(0xFF004AC6);   // primary (CTA gradient start)
  static const lightPrimaryContainer= Color(0xFFEFF6FF);   // primary-container
  static const lightSecondary       = Color(0xFFFEA619);   // reward secondary
  static const lightTertiary        = Color(0xFFA65900);   // lost / alert orange
  static const lightOnSurface       = Color(0xFF0D1C2E);   // body text
  static const lightOnSurfaceVar    = Color(0xFF434655);   // secondary text
  static const lightOutline         = Color(0xFFC3C6D7);   // ghost borders
  static const lightError           = Color(0xFFBA1A1A);
  static const lightSuccess         = Color(0xFF22C55E);

  // ── Dark (Glacier) ───────────────────────────────────────────────────────
  static const darkBg               = Color(0xFF0A0E1A);   // deep navy-black
  static const darkSurface          = Color(0xFF0F1524);   // glass layer 1
  static const darkSurfaceHigh      = Color(0xFF111827);   // glass layer 2
  static const darkGlass            = Color(0x990F1524);   // glass @ 60%
  static const darkPrimary          = Color(0xFF7DD3FC);   // ice-blue
  static const darkPrimaryContainer = Color(0xFF172030);   // dark primary bg
  static const darkTertiary         = Color(0xFFC8A0F0);   // soft lavender
  static const darkOnSurface        = Color(0xFFE2E8F0);   // light text
  static const darkOnSurfaceVar     = Color(0xFF8EA3B8);   // muted text
  static const darkBorder           = Color(0x1A7DD3FC);   // primary @ 10%
  static const darkError            = Color(0xFFFF6B6B);
  static const darkSuccess          = Color(0xFF4ADE80);
}

// ── ThemeData factories ────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary:          AppColors.lightPrimary,
        onPrimary:        Colors.white,
        primaryContainer: AppColors.lightPrimaryContainer,
        secondary:        AppColors.lightSecondary,
        tertiary:         AppColors.lightTertiary,
        surface:          AppColors.lightSurface,
        surfaceContainerHighest: AppColors.lightContainerHigh,
        onSurface:        AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVar,
        outline:          AppColors.lightOutline,
        error:            AppColors.lightError,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(
          fontSize: 56, fontWeight: FontWeight.bold,
          color: AppColors.lightOnSurface,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 28, fontWeight: FontWeight.bold,
          color: AppColors.lightOnSurface,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.bold,
          color: AppColors.lightOnSurface,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, color: AppColors.lightOnSurface,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: AppColors.lightOnSurfaceVar,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: AppColors.lightPrimary.withOpacity(0.4),
              width: 1.5),
        ),
        hintStyle: TextStyle(
            color: AppColors.lightOnSurfaceVar.withOpacity(0.6),
            fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shadowColor: AppColors.lightOnSurface.withOpacity(0.06),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightOnSurfaceVar),
      dividerColor: AppColors.lightOutline.withOpacity(0.15),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.lightPrimary
                : AppColors.lightOutline),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.lightPrimary.withOpacity(0.3)
                : AppColors.lightOutline.withOpacity(0.3)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary:          AppColors.darkPrimary,
        onPrimary:        AppColors.darkBg,
        primaryContainer: AppColors.darkPrimaryContainer,
        secondary:        AppColors.darkTertiary,
        tertiary:         AppColors.darkTertiary,
        surface:          AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceHigh,
        onSurface:        AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVar,
        outline:          AppColors.darkBorder,
        error:            AppColors.darkError,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 56, fontWeight: FontWeight.bold,
          color: AppColors.darkOnSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
          letterSpacing: 0.3,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: AppColors.darkOnSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: AppColors.darkOnSurfaceVar,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: AppColors.darkPrimary, width: 1.5),
        ),
        hintStyle: const TextStyle(
            color: AppColors.darkOnSurfaceVar, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkOnSurfaceVar),
      dividerColor: AppColors.darkBorder,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.darkPrimary
                : AppColors.darkOnSurfaceVar),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.darkPrimary.withOpacity(0.25)
                : AppColors.darkSurfaceHigh),
      ),
    );
  }
}
