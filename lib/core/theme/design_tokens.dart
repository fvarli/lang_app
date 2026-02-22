import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
}

abstract final class AppColors {
  // Primary
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFDBEAFE);
  static const primaryDark = Color(0xFF1E3A5F);

  // Secondary
  static const secondary = Color(0xFF0D9488);
  static const secondaryLight = Color(0xFFCCFBF1);
  static const secondaryDark = Color(0xFF134E48);

  // Light surfaces
  static const lightBg = Color(0xFFF1F5F9);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOutline = Color(0xFFE2E8F0);

  // Dark surfaces
  static const darkBg = Color(0xFF0C1220);
  static const darkSurface = Color(0xFF151D2E);
  static const darkSurfaceHigh = Color(0xFF1C2640);
  static const darkOutline = Color(0xFF293548);

  // Semantic
  static const success = Color(0xFF059669);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);

  // Answer feedback — light
  static const correctBg = Color(0xFFDCFCE7);
  static const incorrectBg = Color(0xFFFEE2E2);

  // Answer feedback — dark
  static const correctBgDark = Color(0xFF052E16);
  static const incorrectBgDark = Color(0xFF2D0A0A);

  // Answer feedback — borders
  static const correctBorder = Color(0xFF16A34A);
  static const incorrectBorder = Color(0xFFDC2626);
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 600);
  static const scoreRing = Duration(milliseconds: 1200);
}
