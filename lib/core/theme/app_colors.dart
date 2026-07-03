import 'package:flutter/material.dart';

/// MacroFinance v2 Design System — Color Palette
/// Light-mode-first with Material 3 tokens
/// Primary: Deep Navy | Accent: Emerald Green
class AppColors {
  AppColors._();

  // ── Primary Brand ──
  static const Color primary = Color(0xFF1A237E);         // Deep Navy
  static const Color primaryLight = Color(0xFF3949AB);     // Lighter navy
  static const Color primaryDark = Color(0xFF0D1259);      // Darker navy
  static const Color primarySurface = Color(0x1A1A237E);   // 10% navy overlay

  // ── Accent / CTA ──
  static const Color accent = Color(0xFF00C853);           // Emerald Green
  static const Color accentLight = Color(0xFF5EFC82);      // Light emerald
  static const Color accentDark = Color(0xFF009624);        // Dark emerald
  static const Color accentSurface = Color(0x1A00C853);    // 10% emerald overlay

  // ── Warning ──
  static const Color warning = Color(0xFFFFB300);          // Amber
  static const Color warningLight = Color(0xFFFFE54C);
  static const Color warningDark = Color(0xFFC68400);
  static const Color warningSurface = Color(0x1AFFB300);

  // ── Error ──
  static const Color error = Color(0xFFD32F2F);            // Red
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFF9A0007);
  static const Color errorSurface = Color(0x1AD32F2F);

  // ── Info ──
  static const Color info = Color(0xFF1976D2);
  static const Color infoSurface = Color(0x1A1976D2);

  // ── Success (same as accent) ──
  static const Color success = Color(0xFF00C853);
  static const Color successSurface = Color(0x1A00C853);

  // ══════════════════════════════════════
  //  LIGHT MODE
  // ══════════════════════════════════════
  static const Color lightBackground = Color(0xFFF5F7FA);     // Off-white
  static const Color lightSurface = Color(0xFFFFFFFF);         // White cards
  static const Color lightSurfaceVariant = Color(0xFFF0F2F5);  // Slightly darker
  static const Color lightBorder = Color(0xFFE0E4EC);          // Light grey border
  static const Color lightScaffold = Color(0xFFF5F7FA);

  // Light Text
  static const Color lightTextPrimary = Color(0xFF1A1F36);     // Near-black
  static const Color lightTextSecondary = Color(0xFF6B7280);   // Grey
  static const Color lightTextTertiary = Color(0xFF9CA3AF);    // Lighter grey
  static const Color lightTextOnPrimary = Color(0xFFFFFFFF);   // White on navy
  static const Color lightTextOnAccent = Color(0xFFFFFFFF);    // White on emerald

  // ══════════════════════════════════════
  //  DARK MODE
  // ══════════════════════════════════════
  static const Color darkBackground = Color(0xFF0F1729);
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color darkSurfaceVariant = Color(0xFF212D3E);
  static const Color darkBorder = Color(0xFF2A3548);
  static const Color darkScaffold = Color(0xFF0A1020);

  // Dark Text
  static const Color darkTextPrimary = Color(0xFFF0F0F5);
  static const Color darkTextSecondary = Color(0xFFB0B8D0);
  static const Color darkTextTertiary = Color(0xFF6B7499);
  static const Color darkTextOnPrimary = Color(0xFFFFFFFF);

  // ── Loan Status ──
  static const Color statusApproved = Color(0xFF00C853);
  static const Color statusPending = Color(0xFFFFB300);
  static const Color statusRejected = Color(0xFFD32F2F);
  static const Color statusActive = Color(0xFF1976D2);
  static const Color statusClosed = Color(0xFF9CA3AF);
  static const Color statusOverdue = Color(0xFFD32F2F);
  static const Color statusDisbursed = Color(0xFF00C853);

  // ── Tier Colors ──
  static const Color tierStarter = Color(0xFF9CA3AF);       // Grey
  static const Color tierBronze = Color(0xFFCD7F32);        // Bronze
  static const Color tierSilver = Color(0xFFC0C0C0);        // Silver
  static const Color tierGold = Color(0xFFFFD700);           // Gold

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FA)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2332), Color(0xFF0F1729)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
  );

  // ── Card Shadow (Light Mode) ──
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      blurRadius: 12,
      color: Colors.black.withValues(alpha: 0.06),
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowStrong => [
    BoxShadow(
      blurRadius: 20,
      color: Colors.black.withValues(alpha: 0.1),
      offset: const Offset(0, 6),
    ),
  ];

  // ══════════════════════════════════════
  //  v1 → v2 BACKWARD-COMPATIBILITY ALIASES
  //  These allow existing v1 screens to compile
  //  against the new v2 color palette.
  // ══════════════════════════════════════

  // Scaffold / Background
  static const Color scaffoldBackground = lightScaffold;

  // Surface / Cards
  static const Color surface = lightSurface;
  static const Color surfaceLight = lightSurfaceVariant;
  static const Color surfaceBorder = lightBorder;

  // Text
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textTertiary = lightTextTertiary;
  static const Color textOnPrimary = lightTextOnPrimary;

  // Status (aliases)
  static const Color gold = tierGold;
  static const Color bronze = tierBronze;
  static const Color silver = tierSilver;

  // Glass
  static Color get glassBackground => Colors.white.withValues(alpha: 0.1);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.2);
}
