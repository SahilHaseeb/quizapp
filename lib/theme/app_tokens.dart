import 'package:flutter/material.dart';

/// Centralized design tokens for Quiz App (colors, gradients, radii, spacing, shadows).
abstract class AppTokens {
  // --- SPACING SCALE ---
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double spaceXxl = 32.0;

  // --- CORNER RADII ---
  static const double radiusChip = 10.0;
  static const double radiusButton = 14.0;
  static const double radiusInput = 14.0;
  static const double radiusCard = 20.0;
  static const double radiusHeader = 28.0;

  // --- BUTTON SIZES ---
  static const double buttonHeight = 52.0;

  // --- BRAND & PALETTE COLORS ---
  // Primary Indigo
  static const Color primaryIndigoLight = Color(0xFF4F46E5);
  static const Color primaryIndigoDark = Color(0xFF818CF8);

  // Accent Amber
  static const Color accentAmber = Color(0xFFF59E0B);

  // Background
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF0B1020);

  // Surface / Card
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF151A2E);

  // Border
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF2A3350);

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);

  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textSecondaryDark = Color(0xFFA7B0C5);

  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF6B7794);

  // --- SEMANTIC COLORS ---
  // Success
  static const Color successLight = Color(0xFF16A34A);
  static const Color successDark = Color(0xFF22C55E);
  static const Color successBgLight = Color(0xFFF0FDF4);
  static const Color successBgDark = Color(0xFF052E16);

  // Warning
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningBgLight = Color(0xFFFFFBEB);
  static const Color warningBgDark = Color(0xFF451A03);

  // Error
  static const Color errorLight = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFEF4444);
  static const Color errorBgLight = Color(0xFFFEF2F2);
  static const Color errorBgDark = Color(0xFF450A0A);

  // Info
  static const Color infoLight = Color(0xFF0EA5E9);
  static const Color infoDark = Color(0xFF38BDF8);
  static const Color infoBgLight = Color(0xFFF0F9FF);
  static const Color infoBgDark = Color(0xFF082F49);

  // --- DIFFICULTY COLORS ---
  static const Color difficultyEasy = Color(0xFF10B981);
  static const Color difficultyMedium = Color(0xFFF59E0B);
  static const Color difficultyHard = Color(0xFFE11D48);

  // Difficulty Gradients
  static const List<Color> easyGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  static const List<Color> mediumGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];
  static const List<Color> hardGradient = [
    Color(0xFFE11D48),
    Color(0xFFBE123C),
  ];

  // --- SUBJECT GRADIENTS (135 degrees = topLeft to bottomRight, muted, contrast >= 4.5:1) ---
  static const List<Color> osGradient = [
    Color(0xFF2563EB),
    Color(0xFF1D4ED8),
  ];
  static const List<Color> webGradient = [
    Color(0xFF0D9488),
    Color(0xFF0F766E),
  ];
  static const List<Color> mobileGradient = [
    Color(0xFF7C3AED),
    Color(0xFF6D28D9),
  ];
  static const List<Color> daaGradient = [
    Color(0xFFEA580C),
    Color(0xFFC2410C),
  ];
  static const List<Color> statsGradient = [
    Color(0xFFDB2777),
    Color(0xFFBE185D),
  ];
  static const List<Color> coalGradient = [
    Color(0xFF059669),
    Color(0xFF047857),
  ];

  // --- HEADER GRADIENT ---
  static const List<Color> headerGradientLight = [
    Color(0xFF312E81),
    Color(0xFF4F46E5),
    Color(0xFF6D28D9),
  ];

  static const List<Color> headerGradientDark = [
    Color(0xFF1A1B36),
    Color(0xFF312E81),
    Color(0xFF4C1D95),
  ];

  // --- SHADOWS ---
  static List<BoxShadow> cardShadowLight(Color cardTint) {
    return [
      BoxShadow(
        color: cardTint.withValues(alpha: 0.14),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> cardShadowDark(Color cardTint) {
    return [
      BoxShadow(
        color: cardTint.withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
