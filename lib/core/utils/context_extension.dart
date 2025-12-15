import 'package:flutter/material.dart';

extension ThemeContextExtension on BuildContext {
  // Text Styles
  TextStyle? get displayLarge => Theme.of(this).textTheme.displayLarge;
  TextStyle? get displayMedium => Theme.of(this).textTheme.displayMedium;
  TextStyle? get displaySmall => Theme.of(this).textTheme.displaySmall;
  TextStyle? get headlineLarge => Theme.of(this).textTheme.headlineLarge;
  TextStyle? get headlineMedium => Theme.of(this).textTheme.headlineMedium;
  TextStyle? get headlineSmall => Theme.of(this).textTheme.headlineSmall;
  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge;
  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium;
  TextStyle? get titleSmall => Theme.of(this).textTheme.titleSmall;
  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get bodySmall => Theme.of(this).textTheme.bodySmall;
  TextStyle? get labelLarge => Theme.of(this).textTheme.labelLarge;
  TextStyle? get labelMedium => Theme.of(this).textTheme.labelMedium;
  TextStyle? get labelSmall => Theme.of(this).textTheme.labelSmall;

  // Colors
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get secondary => Theme.of(this).colorScheme.secondary;
  Color get onSecondary => Theme.of(this).colorScheme.onSecondary;
  Color get error => Theme.of(this).colorScheme.error;
  Color get onError => Theme.of(this).colorScheme.onError;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get tertiary => Theme.of(this).colorScheme.tertiary;
  // Border color based on theme mode
  Color get borderColor => isDarkMode
      ? const Color(0xFF334155) // dark border (slate700)
      : const Color(0xFFE2E8F0);

  // Theme data shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Brightness get brightness => Theme.of(this).brightness;

  // ========== AppTextStyles Access ==========

  // Small font style with theme color fallback
  TextStyle verySmall({Color? color, FontWeight? fontWeight}) => TextStyle(
        fontSize: 12,
        fontWeight: fontWeight,
        color: color,
      );
  // Small font style with theme color fallback
  TextStyle smallFont({Color? color, FontWeight? fontWeight}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Normal font style with theme color fallback
  TextStyle normalFont({Color? color, FontWeight? fontWeight}) => TextStyle(
        fontSize: 16,
        fontWeight: fontWeight,
        color: color,
      );

  // Subtitle font style with theme color fallback
  TextStyle subTitle({Color? color, FontWeight? fontWeight}) => TextStyle(
        fontSize: 20,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color,
      );

  // Heading font style with theme color fallback
  TextStyle heading({Color? color, FontWeight? fontWeight}) => TextStyle(
        fontSize: 24,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color,
      );

  // Large text style with theme color fallback
  TextStyle largeText({Color? color}) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Button text style with theme color fallback
  TextStyle buttonText({Color? color}) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // ========== Combined Utilities ==========

  // Responsive text size multiplier
  // ignore: deprecated_member_use
  double get textScaleFactor => MediaQuery.of(this).textScaleFactor;

  // Adaptive text style that scales with system settings
  TextStyle adaptiveTextStyle(TextStyle style) =>
      style.copyWith(fontSize: style.fontSize! * textScaleFactor);
}
