import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Palette ──
  static const Color accent = Color(0xFF00B4D8);
  static const Color accentDark = Color(0xFF008DA6);
  static const Color accentLight = Color(0xFFE0F7FA);
  static const Color navy = Color(0xFF0A1628);
  static const Color dark = Color(0xFF0C1A2A);
  static const Color bg = Color(0xFFEEF2F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color headerBg = Color(0xFFECFEFF);
  static const Color text1 = Color(0xFF111827);
  static const Color text2 = Color(0xFF6B7280);
  static const Color text3 = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE2E5EA);
  static const Color green = Color(0xFF16A34A);
  static const Color amber = Color(0xFFD97706);
  static const Color red = Color(0xFFDC2626);

  // Service icon colors
  static const Color parkingFg = Color(0xFF00838F);
  static const Color parkingBg = Color(0xFFE0F7FA);
  static const Color bookFg = Color(0xFF2E7D32);
  static const Color bookBg = Color(0xFFE8F5E9);
  static const Color challanFg = Color(0xFFE65100);
  static const Color challanBg = Color(0xFFFFF3E0);
  static const Color historyFg = Color(0xFF5E35B1);
  static const Color historyBg = Color(0xFFEDE7F6);
  static const Color evFg = Color(0xFF1565C0);
  static const Color evBg = Color(0xFFE3F2FD);
  static const Color valetFg = Color(0xFFC62828);
  static const Color valetBg = Color(0xFFFCE4EC);
  static const Color offersFg = Color(0xFFF9A825);
  static const Color offersBg = Color(0xFFFFF8E1);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        background: bg,
        surface: card,
        primary: accent,
        onPrimary: Colors.white,
        secondary: navy,
        onSecondary: Colors.white,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        // Display
        displayLarge: GoogleFonts.dmSans(
          fontSize: 32, fontWeight: FontWeight.w800, color: text1, letterSpacing: -0.8,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 28, fontWeight: FontWeight.w800, color: text1, letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.dmSans(
          fontSize: 24, fontWeight: FontWeight.w700, color: text1, letterSpacing: -0.4,
        ),
        // Headline
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 22, fontWeight: FontWeight.w800, color: text1, letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20, fontWeight: FontWeight.w700, color: text1, letterSpacing: -0.2,
        ),
        headlineSmall: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w700, color: text1,
        ),
        // Title
        titleLarge: GoogleFonts.dmSans(
          fontSize: 17, fontWeight: FontWeight.w700, color: text1,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w600, color: text1,
        ),
        titleSmall: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: text1,
        ),
        // Body
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w400, color: text1, height: 1.5,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w400, color: text2, height: 1.5,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 11.5, fontWeight: FontWeight.w400, color: text3, height: 1.4,
        ),
        // Label
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w700, color: text1,
        ),
        labelMedium: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w600, color: text2,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 10.5, fontWeight: FontWeight.w700, color: text3, letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: headerBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w800, color: text1,
        ),
        iconTheme: const IconThemeData(color: text1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        hintStyle: GoogleFonts.dmSans(color: text3, fontSize: 14),
        labelStyle: GoogleFonts.dmSans(color: text2, fontSize: 13, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: accent,
        unselectedItemColor: text3,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.w600),
        elevation: 12,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFF1F5F9), thickness: 1, space: 0),
    );
  }

  // ── Custom text styles ──
  static TextStyle brand(double size, {Color color = text1}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5);

  static TextStyle mono(double size, {Color color = text1}) =>
      GoogleFonts.spaceMono(fontSize: size, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.5);

  // ── Decoration helpers ──
  static BoxDecoration cardDecoration({double radius = 18, Color? color}) => BoxDecoration(
    color: color ?? card,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
    ],
  );

  static BoxDecoration accentGlowDecoration({double radius = 18}) => BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF0A1628), Color(0xFF142236)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: accent.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4)),
    ],
  );
}
