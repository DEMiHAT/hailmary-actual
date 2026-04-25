// dart:ui elements provided via flutter/material.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Core Clinical Palette ──────────────────────────────────
  static Color background = const Color(0xFFF5FAFD);
  static Color surface    = const Color(0xFFFFFFFF);
  static Color surfaceAlt = const Color(0xFFEFF6FA);
  static Color cardGlass    = const Color(0xFFFFFFFF);
  static Color cardGlassBorder = const Color(0xFFE0ECF3);

  // ── Medical Accent Palette ──────────────────────────────────
  static Color primary       = const Color(0xFF0A84B8);
  static Color primaryDark   = const Color(0xFF075D82);
  static Color primaryLight  = const Color(0x1A0A84B8);

  static Color emergency     = const Color(0xFFE5484D);
  static Color emergencyLight = const Color(0x1AE5484D);
  static Color emergencyDark = const Color(0xFFB4232A);

  static Color safe          = const Color(0xFF19A974);
  static Color safeLight     = const Color(0x1A19A974);

  static Color info          = const Color(0xFF0A84B8);
  static Color infoLight     = const Color(0x1A0A84B8);

  static Color warning       = const Color(0xFFF59E0B);
  static Color warningLight  = const Color(0x1AF59E0B);


  static Color heatHigh      = const Color(0xFFE5484D);
  static Color heatMid       = const Color(0xFFF59E0B);
  static Color heatLow       = const Color(0xFF0A84B8);

  // ── Text ────────────────────────────────────────────────────
  static Color textPrimary   = const Color(0xFF102A43);
  static Color textSecondary = const Color(0xFF486581);
  static Color textTertiary  = const Color(0xFF829AB1);

  // ── UI Structure ─────────────────────────────────────────────
  static Color divider     = const Color(0xFFD9E7EF);
  static Color shimmer     = const Color(0xFFEFF6FA);
  static Color scanLine    = const Color(0x080A84B8);

  // ── Gradients ───────────────────────────────────────────────
  static LinearGradient get heroGradient => const LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5FAFD), Color(0xFFEAF7FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [Color(0xFF2DB7D6), Color(0xFF0A84B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get dangerGradient => const LinearGradient(
    colors: [Color(0xFFE5484D), Color(0xFFB4232A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get safeGradient => const LinearGradient(
    colors: [Color(0xFF3DCA8B), Color(0xFF19A974)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradient => const LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FCFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heatmapGradient(double intensity) {
    if (intensity > 0.7) {
      return LinearGradient(colors: [heatHigh.withOpacity(0.8), heatMid.withOpacity(0.5)]);
    } else if (intensity > 0.4) {
      return LinearGradient(colors: [heatMid.withOpacity(0.7), heatLow.withOpacity(0.4)]);
    }
    return LinearGradient(colors: [heatLow.withOpacity(0.5), primary.withOpacity(0.2)]);
  }
}

class AppTheme {
  static void setUpThemeColors(ThemeMode mode) {
    AppColors.background = const Color(0xFFF5FAFD);
    AppColors.surface    = const Color(0xFFFFFFFF);
    AppColors.surfaceAlt = const Color(0xFFEFF6FA);
    AppColors.cardGlass  = const Color(0xFFFFFFFF);
    AppColors.cardGlassBorder = const Color(0xFFE0ECF3);
    AppColors.textPrimary   = const Color(0xFF102A43);
    AppColors.textSecondary = const Color(0xFF486581);
    AppColors.textTertiary  = const Color(0xFF829AB1);
    AppColors.divider  = const Color(0xFFD9E7EF);
    AppColors.shimmer  = const Color(0xFFEFF6FA);
    AppColors.scanLine = const Color(0x080A84B8);
  }

  static ThemeData get lightTheme => _buildTheme();
  static ThemeData get darkTheme  => _buildTheme();

  static ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.safe,
        error: AppColors.emergency,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textTertiary),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Clinical glass-morphism decoration
class GlassDecoration {
  static BoxDecoration get card => BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.divider, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration cardAccent(Color color) => BoxDecoration(
    gradient: LinearGradient(
      colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withOpacity(0.25), width: 1),
    boxShadow: [
      BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
    ],
  );

  static BoxDecoration get subtle => BoxDecoration(
    color: AppColors.surfaceAlt,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.divider),
  );
}
