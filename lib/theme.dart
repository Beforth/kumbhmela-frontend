import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryOrange = Color(0xFFF97316);
  static const Color backgroundGray = Color(0xFFF1F5F9);
  static const Color white = Colors.white;
  
  // Status Colors
  static const Color emerald = Color(0xFF10B981);
  static const Color yellow = Color(0xFFEAB308);
  static const Color rose = Color(0xFFF43F5E);
  
  // Text Colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Get the main theme
  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: backgroundGray,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        background: backgroundGray,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: textMedium,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: textMedium,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          color: textLight,
        ),
      ),
    );
  }

  // Card decoration
  static BoxDecoration cardDecoration({double radius = 16}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: primaryOrange.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Soft shadow
  static List<BoxShadow> softShadow({Color? color}) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
