import 'package:flutter/material.dart';
import 'luxury_theme.dart';

/// Compatibility proxy bridging legacy Md3Theme tokens to Luxury / Editorial Design Tokens.
class Md3Theme {
  // Sophisticated Monochrome with Metallic Gold
  static const Color primary = LuxuryTheme.charcoal;
  static const Color onPrimary = LuxuryTheme.pureWhite;
  static const Color primaryContainer = LuxuryTheme.paleTaupe;
  static const Color onPrimaryContainer = LuxuryTheme.charcoal;

  static const Color secondary = LuxuryTheme.warmGrey;
  static const Color onSecondary = LuxuryTheme.pureWhite;
  static const Color secondaryContainer = LuxuryTheme.paleTaupe;
  static const Color onSecondaryContainer = LuxuryTheme.charcoal;

  static const Color tertiary = LuxuryTheme.metallicGold;
  static const Color onTertiary = LuxuryTheme.charcoal;
  static const Color tertiaryContainer = Color(0xFFF4ECD8);
  static const Color onTertiaryContainer = Color(0xFF3B2E05);

  static const Color surface = LuxuryTheme.alabaster;
  static const Color onSurface = LuxuryTheme.charcoal;
  static const Color surfaceContainer = LuxuryTheme.paleTaupe;
  static const Color surfaceContainerLow = Color(0xFFF0EBE4);
  static const Color surfaceContainerHigh = Color(0xFFE5DFD7);
  static const Color onSurfaceVariant = LuxuryTheme.warmGrey;

  static const Color outline = Color(0x3D1A1A1A);
  static const Color outlineVariant = Color(0x1F1A1A1A);

  static const Color error = LuxuryTheme.crimson;
  static const Color onError = LuxuryTheme.pureWhite;
  static const Color errorContainer = Color(0xFFF7DADA);
  static const Color onErrorContainer = Color(0xFF5A0C0C);

  static const Color success = LuxuryTheme.forestGreen;
  static const Color successContainer = Color(0xFFE2EFE0);
  static const Color onSuccessContainer = Color(0xFF143310);

  // Shape Radii - Strictly 0px in Luxury / Editorial
  static const double radiusExtraSmall = 0.0;
  static const double radiusSmall = 0.0;
  static const double radiusMedium = 0.0;
  static const double radiusLarge = 0.0;
  static const double radiusExtraLarge = 0.0;
  static const double radiusPill = 0.0;

  // Global Theme Delegation
  static ThemeData get lightTheme => LuxuryTheme.lightTheme;
}
