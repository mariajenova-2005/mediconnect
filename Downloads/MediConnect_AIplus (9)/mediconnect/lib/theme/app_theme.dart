import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/fx.dart';

/// MediConnect brand palette — Green (vitality/care) + Blue (trust/medical).
class AppColors {
  static const Color primaryBlue = Color(0xFF0B6E99);
  static const Color deepBlue = Color(0xFF053A5F);
  static const Color accentGreen = Color(0xFF17C3A2);
  static const Color softGreen = Color(0xFFB9F2E4);
  static const Color mild = Color(0xFF2ECC71);
  static const Color moderate = Color(0xFFF5A623);
  static const Color severe = Color(0xFFE94B4B);
  static const Color bgLight = Color(0xFFF4FAF9);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF0D1B2A);
  static const Color textMuted = Color(0xFF6B7C93);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryBlue, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFE94B4B), Color(0xFFF5725B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: PageTransitionsTheme(builders: {for (final p in TargetPlatform.values) p: const MedPageTransitions()}),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentGreen,
        surface: AppColors.card,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 6,
        shadowColor: AppColors.primaryBlue.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Layered "raised card" shadows: soft colored depth + tight contact shadow + top-left highlight.
class AppShadows {
  static List<BoxShadow> get card3d => [
        BoxShadow(color: AppColors.primaryBlue.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 12)),
        BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 3)),
        BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 4, offset: const Offset(-2, -2)),
      ];
}
