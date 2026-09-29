import 'package:flutter/material.dart';

/// Centralized Luxury / Editorial Design Tokens & Theme Configuration
/// Inspired by high-end editorial magazines (Vogue, Kinfolk) and luxury ateliers.
///
/// Principles:
/// - Strictly 0px border radius (rectangular architectural precision).
/// - 1px thin deliberate borders.
/// - Sophisticated Monochrome palette (#F9F8F6 Alabaster, #1A1A1A Charcoal, #EBE5DE Pale Taupe).
/// - Metallic Gold (#D4AF37) accents used with restraint.
/// - High-contrast Serif headlines and clean humanistic Sans-Serif body.
/// - Layered subtle shadows (never harsh drop shadows).
class LuxuryTheme {
  // Primary Palette
  static const Color alabaster = Color(0xFFF9F8F6); // Warm Alabaster (Background)
  static const Color charcoal = Color(0xFF1A1A1A); // Rich Charcoal (Foreground)
  static const Color paleTaupe = Color(0xFFEBE5DE); // Pale Taupe (Muted Background)
  static const Color warmGrey = Color(0xFF6C6863); // Warm Grey (Muted Foreground)
  static const Color metallicGold = Color(0xFFD4AF37); // Metallic Gold (Accent)
  static const Color pureWhite = Color(0xFFFFFFFF); // Pure White (High contrast foreground)

  // Status Colors
  static const Color crimson = Color(0xFF9A1B1B); // Deep Crimson Red
  static const Color forestGreen = Color(0xFF2D5A27); // Forest Green
  static const Color goldenAmber = Color(0xFFB48316); // Amber status

  // Border & Divider Colors
  static Color get borderSubtle => charcoal.withValues(alpha: 0.12);
  static Color get borderMedium => charcoal.withValues(alpha: 0.25);
  static Color get borderStrong => charcoal;

  // Radii - Strictly 0px (Architectural Precision)
  static const double radiusZero = 0.0;
  static const BorderRadius borderRadiusZero = BorderRadius.zero;

  // Typographic Styles
  static const TextStyle serifDisplay = TextStyle(
    fontFamily: 'serif',
    fontWeight: FontWeight.w400,
    color: charcoal,
    letterSpacing: -0.5,
  );

  static const TextStyle serifHeadline = TextStyle(
    fontFamily: 'serif',
    fontWeight: FontWeight.w500,
    color: charcoal,
    letterSpacing: -0.3,
  );

  static const TextStyle labelOverline = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    color: warmGrey,
    letterSpacing: 2.2,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.8,
  );

  // Common Luxury Card Decoration with 1px top border
  static BoxDecoration cardDecoration({
    Color backgroundColor = alabaster,
    bool topBorderOnly = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: topBorderOnly
          ? Border(top: BorderSide(color: borderSubtle, width: 1.0))
          : Border.all(color: borderSubtle, width: 1.0),
      boxShadow: [
        BoxShadow(
          color: charcoal.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // Global Luxury ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: alabaster,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: charcoal,
        onPrimary: pureWhite,
        primaryContainer: paleTaupe,
        onPrimaryContainer: charcoal,
        secondary: warmGrey,
        onSecondary: pureWhite,
        secondaryContainer: paleTaupe,
        onSecondaryContainer: charcoal,
        tertiary: metallicGold,
        onTertiary: charcoal,
        tertiaryContainer: Color(0xFFF4ECD8),
        onTertiaryContainer: Color(0xFF3B2E05),
        surface: alabaster,
        onSurface: charcoal,
        error: crimson,
        onError: pureWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: alabaster,
        foregroundColor: charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: charcoal, size: 22),
      ),
      cardTheme: const CardThemeData(
        color: alabaster,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusZero,
          side: BorderSide(color: Color(0x1F1A1A1A), width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: charcoal.withValues(alpha: 0.3), width: 1.0),
          borderRadius: borderRadiusZero,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: charcoal.withValues(alpha: 0.2), width: 1.0),
          borderRadius: borderRadiusZero,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: metallicGold, width: 1.5),
          borderRadius: borderRadiusZero,
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: crimson, width: 1.0),
          borderRadius: borderRadiusZero,
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: crimson, width: 1.5),
          borderRadius: borderRadiusZero,
        ),
        labelStyle: const TextStyle(
          color: warmGrey,
          fontSize: 13.5,
          letterSpacing: 0.2,
        ),
        floatingLabelStyle: const TextStyle(
          color: charcoal,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'serif',
          fontStyle: FontStyle.italic,
          color: warmGrey,
          fontSize: 13.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: charcoal,
          foregroundColor: pureWhite,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: borderRadiusZero),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoal,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: charcoal.withValues(alpha: 0.4), width: 1.0),
          shape: const RoundedRectangleBorder(borderRadius: borderRadiusZero),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: charcoal,
          shape: const RoundedRectangleBorder(borderRadius: borderRadiusZero),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: alabaster,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusZero,
          side: BorderSide(color: Color(0x2E1A1A1A), width: 1.0),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: charcoal,
          letterSpacing: -0.2,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: charcoal.withValues(alpha: 0.12),
        thickness: 1.0,
        space: 1.0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: charcoal,
        foregroundColor: pureWhite,
        elevation: 3,
        shape: CircleBorder(),
      ),
    );
  }
}
