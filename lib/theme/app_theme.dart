import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'beacon_colors.dart';
import 'beacon_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// BEACON THEME
// Light → "Daylight"   · Dark → "Nightwatch"
// Typography: Sora (display / headline / title-large) + Inter (everything else)
// This is the only file that talks to google_fonts. The font files are
// bundled under assets/google_fonts/ so nothing is downloaded at runtime.
// ═══════════════════════════════════════════════════════════════════════════════

class AppTheme {
  static ThemeData? _light;
  static ThemeData? _dark;

  /// Built once per process: the text theme resolves ~30 font styles and
  /// `MaterialApp` asks for both themes on every rebuild.
  static ThemeData light() =>
      _light ??= _build(BeaconColors.light, Brightness.light);
  static ThemeData dark() =>
      _dark ??= _build(BeaconColors.dark, Brightness.dark);

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme textTheme(BeaconColors c) {
    TextStyle sora(double size, FontWeight w, {double h = 1.2, double ls = 0}) =>
        GoogleFonts.sora(
          fontSize: size,
          fontWeight: w,
          height: h,
          letterSpacing: ls,
          color: c.onSurface,
        );
    TextStyle inter(double size, FontWeight w,
            {double h = 1.5, double ls = 0, Color? color}) =>
        GoogleFonts.inter(
          fontSize: size,
          fontWeight: w,
          height: h,
          letterSpacing: ls,
          color: color ?? c.onSurface,
        );

    return TextTheme(
      displayLarge: sora(44, FontWeight.w700, h: 1.1, ls: -1),
      displayMedium: sora(36, FontWeight.w700, h: 1.1, ls: -0.8),
      displaySmall: sora(30, FontWeight.w700, h: 1.15, ls: -0.5),
      headlineLarge: sora(28, FontWeight.w700, h: 1.2, ls: -0.4),
      headlineMedium: sora(24, FontWeight.w700, h: 1.2, ls: -0.3),
      headlineSmall: sora(20, FontWeight.w600, h: 1.25, ls: -0.2),
      titleLarge: sora(18, FontWeight.w600, h: 1.3),
      titleMedium: inter(16, FontWeight.w600, h: 1.4),
      titleSmall: inter(14, FontWeight.w600, h: 1.4),
      bodyLarge: inter(16, FontWeight.w400),
      bodyMedium: inter(14, FontWeight.w400, color: c.onSurfaceVariant),
      bodySmall: inter(12, FontWeight.w400, h: 1.4, color: c.onSurfaceVariant),
      labelLarge: inter(14, FontWeight.w600, h: 1.2),
      labelMedium: inter(12, FontWeight.w600, h: 1.2, ls: 0.3),
      labelSmall: inter(11, FontWeight.w600, h: 1.2, ls: 0.6),
    );
  }

  // ── Builder ───────────────────────────────────────────────────────────────
  static ThemeData _build(BeaconColors c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final text = textTheme(c);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onPrimaryContainer,
      secondary: c.accent,
      onSecondary: c.onAccent,
      secondaryContainer: c.accentContainer,
      onSecondaryContainer: c.onAccent,
      tertiary: c.found,
      onTertiary: c.onFound,
      tertiaryContainer: c.foundContainer,
      onTertiaryContainer: c.onSurface,
      error: c.error,
      onError: c.onError,
      errorContainer: c.errorContainer,
      onErrorContainer: c.onSurface,
      surface: c.surface,
      onSurface: c.onSurface,
      onSurfaceVariant: c.onSurfaceVariant,
      surfaceContainerLowest: isDark ? c.bg : c.surface,
      surfaceContainerLow: c.surfaceLow,
      surfaceContainer: c.surfaceLow,
      surfaceContainerHigh: c.surfaceHigh,
      surfaceContainerHighest: c.surfaceHigh,
      outline: c.outline,
      outlineVariant: c.outlineVariant,
      shadow: c.shadow,
      scrim: c.scrim,
      inverseSurface:
          isDark ? BeaconColors.light.surface : BeaconColors.dark.surface,
      onInverseSurface:
          isDark ? BeaconColors.light.onSurface : BeaconColors.dark.onSurface,
      inversePrimary:
          isDark ? BeaconColors.light.primary : BeaconColors.dark.primary,
      surfaceTint: Colors.transparent,
    );

    final pill = RoundedRectangleBorder(borderRadius: BeaconRadius.rPill);
    final lg = RoundedRectangleBorder(borderRadius: BeaconRadius.rLg);

    OutlineInputBorder inputBorder(Color color, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: BeaconRadius.rMd,
          borderSide: BorderSide(color: color, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c],
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      textTheme: text,
      primaryTextTheme: text,
      fontFamily: text.bodyMedium?.fontFamily,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      iconTheme: IconThemeData(color: c.onSurfaceVariant, size: BeaconIcon.md),
      dividerColor: c.outlineVariant,
      dividerTheme: DividerThemeData(
        color: c.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: c.onSurface, size: BeaconIcon.md),
        actionsIconTheme: IconThemeData(color: c.onSurface, size: BeaconIcon.md),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: c.bg,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: c.bg,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size(kBeaconTouchTarget, 52),
          padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.xxl),
          shape: pill,
          textStyle: text.labelLarge,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.surfaceHigh,
          disabledForegroundColor: c.onSurfaceMuted,
          minimumSize: const Size(kBeaconTouchTarget, 52),
          padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.xxl),
          shape: pill,
          textStyle: text.labelLarge,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(kBeaconTouchTarget, 52),
          padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.xxl),
          shape: pill,
          side: BorderSide(color: c.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(kBeaconTouchTarget, kBeaconTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.md),
          shape: pill,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.onSurface,
          minimumSize: const Size(kBeaconTouchTarget, kBeaconTouchTarget),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 0,
        shape: lg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BeaconSpace.lg,
          vertical: BeaconSpace.lg,
        ),
        border: inputBorder(Colors.transparent),
        enabledBorder: inputBorder(Colors.transparent),
        disabledBorder: inputBorder(Colors.transparent),
        focusedBorder: inputBorder(c.primary, 1.5),
        errorBorder: inputBorder(c.error),
        focusedErrorBorder: inputBorder(c.error, 1.5),
        hintStyle: text.bodyLarge?.copyWith(color: c.onSurfaceMuted),
        labelStyle: text.bodyMedium,
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall?.copyWith(color: c.error),
        prefixIconColor: c.onSurfaceVariant,
        suffixIconColor: c.onSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BeaconRadius.rXl),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceLow,
        selectedColor: c.primaryContainer,
        disabledColor: c.surfaceLow,
        labelStyle: text.labelLarge?.copyWith(color: c.onSurface),
        secondaryLabelStyle:
            text.labelLarge?.copyWith(color: c.onPrimaryContainer),
        side: BorderSide.none,
        shape: pill,
        padding: const EdgeInsets.symmetric(
          horizontal: BeaconSpace.md,
          vertical: BeaconSpace.sm,
        ),
        showCheckmark: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        modalBarrierColor: c.scrim,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(BeaconRadius.xxl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BeaconRadius.rXxl),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? c.surfaceHigh : c.onSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: isDark ? c.onSurface : BeaconColors.dark.onSurface,
        ),
        actionTextColor: isDark ? c.primary : BeaconColors.dark.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BeaconRadius.rMd),
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onPrimary : c.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.surfaceHigh,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.outline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? c.primary : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        side: BorderSide(color: c.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.outline,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.surfaceHigh,
        circularTrackColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.onSurfaceVariant,
        textColor: c.onSurface,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BeaconRadius.rLg),
        contentPadding: const EdgeInsets.symmetric(horizontal: BeaconSpace.lg),
        minVerticalPadding: BeaconSpace.md,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.onSurface,
        unselectedLabelColor: c.onSurfaceVariant,
        indicatorColor: c.primary,
        dividerColor: Colors.transparent,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: c.primary,
        headerForegroundColor: c.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BeaconRadius.rXxl),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BeaconRadius.rXxl),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.onSurface,
          borderRadius: BeaconRadius.rSm,
        ),
        textStyle: text.bodySmall?.copyWith(color: c.bg),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
