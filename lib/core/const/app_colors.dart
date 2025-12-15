import 'package:flutter/material.dart';

@immutable
class AppColors {
  // Light Theme Colors
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryForeground = Colors.white;
  static const Color secondary = Color(0xFF64748B);
  static const Color secondaryForeground = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color destructiveForeground = Colors.white;
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color backgroundColorLight = Colors.white;
  static const Color borderColorLight = Color(0xFFE2E8F0);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF60A5FA);
  static const Color darkPrimaryForeground = Color(0xFF020617);
  static const Color darkSecondary = Color(0xFF94A3B8);
  static const Color darkSecondaryForeground = Color(0xFF020617);
  static const Color darkMuted = Color(0xFF1E293B);
  static const Color darkMutedForeground = Color(0xFF94A3B8);
  static const Color backgroundColorDark = Color(0xFF020617);
  static const Color borderColorDark = Color(0xFF334155);

  // Common Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // System UI Colors
  static const Color lightSystemNavigationBar = white;
  static const Color darkSystemNavigationBar = Color(0xFF0A0A0A);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate950 = Color(0xFF020617);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color blue50 = Color(0xFFE0F2FE);
  static const Color blue900 = Color(0xFF0C4A6E);
}
