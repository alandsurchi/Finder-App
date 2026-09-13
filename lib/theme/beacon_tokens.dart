import 'package:flutter/material.dart';

/// Spacing scale (4pt rhythm).
abstract final class BeaconSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Horizontal page gutter.
  static const double page = 20;

  /// Extra bottom inset that scrolling tab pages reserve for the notch nav.
  static const double navClearance = 112;
}

/// Corner radius scale.
abstract final class BeaconRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 999;

  static BorderRadius get rSm => BorderRadius.circular(sm);
  static BorderRadius get rMd => BorderRadius.circular(md);
  static BorderRadius get rLg => BorderRadius.circular(lg);
  static BorderRadius get rXl => BorderRadius.circular(xl);
  static BorderRadius get rXxl => BorderRadius.circular(xxl);
  static BorderRadius get rPill => BorderRadius.circular(pill);
}

/// Motion tokens. Every animated widget should route its duration through
/// [scaled] so reduced-motion settings collapse motion to zero.
abstract final class BeaconMotion {
  static const Duration press = Duration(milliseconds: 120);
  static const Duration state = Duration(milliseconds: 220);
  static const Duration enter = Duration(milliseconds: 360);
  static const Duration exit = Duration(milliseconds: 160);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOut;
  static const Curve exitCurve = Curves.easeIn;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration scaled(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}

/// Icon sizes.
abstract final class BeaconIcon {
  static const double sm = 18;
  static const double md = 22;
  static const double lg = 26;
}

/// Minimum interactive target size (Material: 48dp).
const double kBeaconTouchTarget = 48;
