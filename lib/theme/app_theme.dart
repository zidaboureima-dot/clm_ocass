// theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color vertPrimaire = Color(0xFF1D9E75);
  static const Color vertFonce = Color(0xFF085041);
  static const Color vertClair = Color(0xFFE1F5EE);
  static const Color rouge = Color(0xFFA32D2D);
  static const Color rougeClair = Color(0xFFFCEBEB);
  static const Color ambre = Color(0xFFBA7517);
  static const Color ambreClair = Color(0xFFFAEEDA);
  static const Color bleu = Color(0xFF185FA5);
  static const Color bleuClair = Color(0xFFE6F1FB);
  static const Color grisTexte = Color(0xFF5F5E5A);
  static const Color grisLeger = Color(0xFFF1EFE8);
  static const Color bordure = Color(0xFFD3D1C7);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vertPrimaire,
        primary: AppColors.vertPrimaire,
        secondary: AppColors.vertFonce,
        surface: Colors.white,
        background: const Color(0xFFF8F8F6),
        error: AppColors.rouge,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.vertFonce,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.vertFonce,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C2C2A),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF2C2C2A),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.grisTexte,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.04,
          color: AppColors.grisTexte,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.vertFonce,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.vertFonce,
        ),
        iconTheme: const IconThemeData(color: AppColors.vertFonce),
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.bordure,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vertPrimaire,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.vertPrimaire,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.vertPrimaire, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bordure, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bordure, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.vertPrimaire, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.rouge, width: 1),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.grisTexte),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.bordure),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.bordure, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F8F6),
    );
  }
}
