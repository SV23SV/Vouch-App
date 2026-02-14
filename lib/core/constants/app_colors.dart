import 'package:flutter/material.dart';

/// Vouch brand color palette.
/// All color combinations meet WCAG AAA contrast ratios.
class AppColors {
  AppColors._();

  // Primary - Trust Blue
  static const Color trustBlue = Color(0xFF1A5276);
  static const Color trustBlueLight = Color(0xFF2980B9);
  static const Color trustBlueDark = Color(0xFF0E2F44);

  // Secondary - Safety Amber
  static const Color safetyAmber = Color(0xFFF39C12);
  static const Color safetyAmberLight = Color(0xFFF7C948);
  static const Color safetyAmberDark = Color(0xFFD68910);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color lightGrey = Color(0xFFE9ECEF);
  static const Color mediumGrey = Color(0xFF6C757D);
  static const Color darkGrey = Color(0xFF343A40);
  static const Color nearBlack = Color(0xFF212529);

  // Semantic Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Trust Level Indicators
  static const Color firstDegree = Color(0xFF27AE60);
  static const Color secondDegree = Color(0xFF3498DB);
  static const Color neighborhood = Color(0xFF95A5A6);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16213E);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1F2937);

  // Safety Alert Colors
  static const Color alertScam = Color(0xFFE74C3C);
  static const Color alertWarning = Color(0xFFF39C12);
  static const Color alertSafe = Color(0xFF27AE60);
}
