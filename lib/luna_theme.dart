import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The single source of truth for the LunaSleep "Celestial Guardian" design system.
/// Aligned with Stitch project #8841024187591394025.
class LunaTheme {
  // ─── Stitch Named Colors ────────────────────────────────────────────────────
  static const Color background = Color(0xFF0E0E0E);           // surface / base
  static const Color surfaceLow = Color(0xFF131313);           // surface_container_low
  static const Color surfaceContainer = Color(0xFF1A1A1A);     // surface_container
  static const Color surfaceHigh = Color(0xFF20201F);          // surface_container_high
  static const Color surfaceHighest = Color(0xFF262626);       // surface_container_highest
  static const Color surfaceBright = Color(0xFF2C2C2C);        // surface_bright

  /// Lilac — primary accent (matching Stitch #C29BFF)
  static const Color primary = Color(0xFFC29BFF);
  static const Color primaryDim = Color(0xFF8F51EA);           // primary_dim
  static const Color primaryContainer = Color(0xFF3D007F);     // on_primary_container

  /// Cyan — tertiary highlight
  static const Color tertiary = Color(0xFFA1FAFF);
  static const Color tertiaryDim = Color(0xFF00E5EE);          // tertiary_dim

  /// Secondary
  static const Color secondary = Color(0xFFCAD6FD);
  static const Color secondaryContainer = Color(0xFF3A4666);   // secondary_container

  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFADAAAA);     // on_surface_variant
  static const Color outline = Color(0xFF767575);
  static const Color outlineVariant = Color(0xFF484847);       // outline_variant

  static const Color error = Color(0xFFFF6E84);

  // ─── CTA Gradient ───────────────────────────────────────────────────────────
  /// Signature gradient: primary_dim → primary at 45°
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [primaryDim, primary],
  );

  // ─── MaterialApp ThemeData ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFB789FF),
        secondary: secondary,
        onSecondary: Color(0xFF3E4A6A),
        tertiary: tertiary,
        onTertiary: Color(0xFF006165),
        surface: background,
        onSurface: onSurface,
        error: error,
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w800,
          color: onSurface,
          letterSpacing: -1.5,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -1.0,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceContainer,
        contentTextStyle: GoogleFonts.manrope(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Component Helpers ──────────────────────────────────────────────────────

  /// Glass card using backdrop tint — NO border (The "No-Line" rule).
  static BoxDecoration glassDecoration({double opacity = 0.05}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(24),
    );
  }

  /// Surface card — uses tonal background shift, no border.
  static BoxDecoration surfaceCard({double radius = 24}) {
    return BoxDecoration(
      color: surfaceLow,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Active selection card (surface_container_high).
  static BoxDecoration activeCard({double radius = 24}) {
    return BoxDecoration(
      color: surfaceHigh,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Gradient button decoration (full pill).
  static BoxDecoration gradientButton() {
    return BoxDecoration(
      gradient: ctaGradient,
      borderRadius: BorderRadius.circular(100),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.25),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
