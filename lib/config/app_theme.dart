import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Core Palette ───
  static const Color scaffoldBg = Color(0xFF0B0F1A);
  static const Color cardBg = Color(0xFF141929);
  static const Color cardBgElevated = Color(0xFF1A2035);
  static const Color surfaceColor = Color(0xFF1E2540);
  static const Color primaryBlue = Color(0xFF2979FF);
  static const Color accentCyan = Color(0xFF00B0FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B95A8);
  static const Color textTertiary = Color(0xFF4A5568);
  static const Color dividerColor = Color(0xFF1E2540);
  static const Color navBarBg = Color(0xFF0B0F1A);
  static const Color chipBg = Color(0xFF1A2035);
  static const Color progressBg = Color(0xFF1E2540);
  static const Color streakBlue = Color(0xFF1565C0);
  static const Color badgeGreen = Color(0xFF00C853);
  static const Color errorRed = Color(0xFFFF5252);

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2979FF), Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF141929), Color(0xFF1A2035)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient videoOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Shadows ───
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ─── Border Radius ───
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 100.0;

  // ─── Theme Data ───
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentCyan,
        surface: cardBg,
        error: errorRed,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: textSecondary,
          fontSize: 14,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: textSecondary,
          fontSize: 13,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: textTertiary,
          fontSize: 12,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: primaryBlue,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          color: textSecondary,
          fontSize: 10,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: baseTextTheme.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navBarBg,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBg,
        labelStyle: baseTextTheme.bodyMedium?.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        hintStyle: baseTextTheme.bodyMedium?.copyWith(color: textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusRound),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textTertiary,
        indicatorColor: primaryBlue,
        labelStyle: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: baseTextTheme.titleMedium,
      ),
    );
  }
}
