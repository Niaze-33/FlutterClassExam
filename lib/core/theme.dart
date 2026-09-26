import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

// ─── Light Theme ──────────────────────────────────────────────────────────────
ThemeData appTheme() {
  return _buildTheme(Brightness.light);
}

// ─── Dark Theme ───────────────────────────────────────────────────────────────
ThemeData darkTheme() {
  return _buildTheme(Brightness.dark);
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  // Surfaces — warm charcoal-sage for dark, soft stone for light
  final Color background  = isDark ? kDarkBackground  : kBackgroundColor;
  final Color surface     = isDark ? kDarkSurface     : Colors.white;
  final Color card        = isDark ? kDarkCard        : Colors.white;
  final Color textPrimary = isDark ? kDarkTextPrimary : kTextPrimary;
  final Color textSec     = isDark ? kDarkTextSecondary : kTextSecondary;
  final Color textLight   = isDark ? kDarkTextLight   : kTextLight;
  final Color divider     = isDark ? kDarkDivider     : const Color(0xFFE2DFD8);

  final systemOverlay = isDark
      ? SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: kDarkBackground,
          systemNavigationBarIconBrightness: Brightness.light,
        )
      : SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: kBackgroundColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: background,
    primaryColor: kPrimaryColor,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: kPrimaryColor,
      onPrimary: Colors.white,
      secondary: kAccentOlive,
      onSecondary: Colors.white,
      tertiary: kGradientEnd,
      onTertiary: Colors.white,
      error: const Color(0xFFD32F2F),
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    ),
    cardColor: card,
    dividerColor: divider,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary,
          letterSpacing: -0.5),
      displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.3),
      titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
      titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 15, color: textPrimary),
      bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: textSec),
      labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      labelSmall: GoogleFonts.plusJakartaSans(fontSize: 11, color: textLight),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      systemOverlayStyle: systemOverlay,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kButtonRadius)),
        textStyle:
            GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kPrimaryColor;
        return isDark ? const Color(0xFF4A5650) : Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kPrimaryColor.withValues(alpha: 0.45);
        }
        return isDark ? kDarkDivider : const Color(0xFFDDD8D0);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? kDarkSurface : const Color(0xFFEBE8E1),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: isDark ? kDarkTextLight : kTextLight,
        fontSize: 14,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? kDarkCard : kTextPrimary,
      contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kPrimaryColor,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? kDarkCard : const Color(0xFFEAE6DF),
      selectedColor: kPrimaryColor,
      secondarySelectedColor: kPrimaryColor,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: textSec),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
