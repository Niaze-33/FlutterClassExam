import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kQuizPrimary = Color(0xFF00695C);
const Color kQuizPrimaryDark = Color(0xFF004D40);
const Color kQuizBg = Color(0xFFF2F2F2);
const Color kQuizText = Color(0xFF37474F);
const Color kQuizCorrectBg = Color(0xFFB2DFDB);
const Color kQuizIncorrectBg = Color(0xFFFFA1A1);
const Color kQuizScoreGood = Color(0xFFC8E6C9);
const Color kQuizScoreBad = Color(0xFFFF7043);

const List<Color> kCategoryPastels = [
  Color(0xFFB3E5FC), // light blue
  Color(0xFFC8E6C9), // pale green
  Color(0xFFFFF9C4), // pale yellow
  Color(0xFFE1BEE7), // pale purple
  Color(0xFFF8BBD0), // pale pink
  Color(0xFFFFE0B2), // pale peach
  Color(0xFFB2EBF2), // cyan
  Color(0xFFDCEDC8), // light lime
  Color(0xFFFFCCBC), // deep orange tint
  Color(0xFFD1C4E9), // lavender
  Color(0xFFFFECB3), // amber
  Color(0xFFCFD8DC), // blue grey
];

ThemeData quizTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kQuizPrimary,
      primary: kQuizPrimary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      foregroundColor: kQuizText,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kQuizPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kQuizPrimary,
        side: const BorderSide(color: kQuizPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: kQuizText,
      displayColor: kQuizText,
    ),
  );
}
