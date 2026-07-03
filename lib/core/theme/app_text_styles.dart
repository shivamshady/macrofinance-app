import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// MacroFinance v2 Design System — Typography
/// Poppins for headings, Inter for body
class AppTextStyles {
  AppTextStyles._();

  // ── Display ──
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    letterSpacing: -1.2,
    height: 1.15,
  );

  static TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  // ── Heading ──
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    height: 1.35,
  );

  static TextStyle headlineSmall = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    height: 1.4,
  );

  // ── Title ──
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    height: 1.4,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    height: 1.45,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    height: 1.45,
  );

  // ── Body ──
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextPrimary,
    height: 1.55,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextTertiary,
    height: 1.5,
  );

  // ── Label ──
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextPrimary,
    letterSpacing: 0.3,
    height: 1.45,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextSecondary,
    letterSpacing: 0.4,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextTertiary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ── Special Styles ──
  static TextStyle amountLarge = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -1.0,
  );

  static TextStyle amountMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  static TextStyle amountSmall = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextTertiary,
    letterSpacing: 0.3,
  );

  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextTertiary,
    letterSpacing: 1.2,
  );

  // ── Tier-specific ──
  static TextStyle tierName = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static TextStyle tierAmount = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );
}
