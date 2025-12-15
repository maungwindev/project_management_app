import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_frame/core/const/app_colors.dart';

@immutable
class AppTheme {
  // System UI Overlay Styles
  static const SystemUiOverlayStyle _lightSystemOverlayStyle =
      SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle _darkSystemOverlayStyle =
      SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xFF0A0A0A),
    systemNavigationBarIconBrightness: Brightness.light,
  );

  // Text Styles
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Inter', // Recommended to use Inter font
    height: 1.5,
  );

  static TextTheme _buildTextTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      displayLarge: _baseTextStyle.copyWith(
          fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
      displayMedium: _baseTextStyle.copyWith(
          fontSize: 36, fontWeight: FontWeight.bold, color: textColor),
      displaySmall: _baseTextStyle.copyWith(
          fontSize: 30, fontWeight: FontWeight.bold, color: textColor),
      headlineLarge: _baseTextStyle.copyWith(
          fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
      headlineMedium: _baseTextStyle.copyWith(
          fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
      headlineSmall: _baseTextStyle.copyWith(
          fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
      titleLarge: _baseTextStyle.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: _baseTextStyle.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: _baseTextStyle.copyWith(
          fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: _baseTextStyle.copyWith(
          fontSize: 16, fontWeight: FontWeight.normal, color: textColor),
      bodyMedium: _baseTextStyle.copyWith(
          fontSize: 14, fontWeight: FontWeight.normal, color: textColor),
      bodySmall: _baseTextStyle.copyWith(
          fontSize: 12, fontWeight: FontWeight.normal, color: textColor),
      labelLarge: _baseTextStyle.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, color: mutedColor),
      labelMedium: _baseTextStyle.copyWith(
          fontSize: 12, fontWeight: FontWeight.w500, color: mutedColor),
      labelSmall: _baseTextStyle.copyWith(
          fontSize: 10, fontWeight: FontWeight.w500, color: mutedColor),
    );
  }

  // Light Theme
  static ThemeData light({String? fontFamily}) {
    final textTheme = _buildTextTheme(Colors.black, AppColors.mutedForeground);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        error: AppColors.error,
        onError: AppColors.destructiveForeground,
        surface: Colors.white,
        onSurface: Colors.black,
        onSurfaceVariant: AppColors.mutedForeground,
        tertiary: AppColors.muted,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: _lightSystemOverlayStyle,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.primaryForeground,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryForeground,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.muted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.secondary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        checkColor: WidgetStateProperty.all(AppColors.primaryForeground),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return const Color(0xFFE2E8F0);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return const Color(0xFFE2E8F0);
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedForeground,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.muted,
        disabledColor: AppColors.muted,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: textTheme.labelMedium?.copyWith(color: Colors.black),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: AppColors.primaryForeground),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        textStyle: textTheme.bodyMedium,
      ),
    );
  }

  // Dark Theme
  static ThemeData dark({String? fontFamily}) {
    final textTheme =
        _buildTextTheme(Colors.white, AppColors.darkMutedForeground);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkPrimaryForeground,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkSecondaryForeground,
        error: AppColors.error,
        onError: AppColors.destructiveForeground,
        surface: Color(0xFF0F172A),
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.darkMutedForeground,
        tertiary: AppColors.darkMuted,
      ),

      scaffoldBackgroundColor: const Color(0xFF020617), // Slate-950
      appBarTheme: AppBarTheme(
        systemOverlayStyle: _darkSystemOverlayStyle,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.darkPrimaryForeground,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkPrimaryForeground,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E293B), // Slate-800
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0F172A),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.darkPrimary,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkPrimaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF334155)), // Slate-700
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium
            ?.copyWith(color: AppColors.darkMutedForeground),
        hintStyle: textTheme.bodyMedium
            ?.copyWith(color: AppColors.darkMutedForeground),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.darkSecondary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        checkColor: WidgetStateProperty.all(AppColors.darkPrimaryForeground),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary;
          }
          return Colors.transparent;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary;
          }
          return const Color(0xFF334155); // Slate-700
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary.withValues(alpha: 0.5);
          }
          return const Color(0xFF334155); // Slate-700
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F172A),
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkMutedForeground,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF1E293B),
            width: 1,
          ), // Slate-800
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkMuted,
        disabledColor: AppColors.darkMuted,
        selectedColor: AppColors.darkPrimary,
        secondarySelectedColor: AppColors.darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: textTheme.labelMedium?.copyWith(color: Colors.white),
        secondaryLabelStyle: textTheme.labelMedium
            ?.copyWith(color: AppColors.darkPrimaryForeground),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0), // Slate-200
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.black),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF0F172A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: Color(0xFF1E293B),
            width: 1,
          ),
        ),
        textStyle: textTheme.bodyMedium,
      ),
    );
  }
}
