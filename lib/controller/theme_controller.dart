// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_frame/core/const/theme_const.dart';
import 'package:project_frame/core/local_data/shared_prefs.dart';

class ThemeController extends GetxController {
  final SharedPref sharedPref;

  ThemeController({required this.sharedPref});

  final Rx<ThemeData> theme = AppTheme.light(fontFamily: "Outfit").obs;
  final Rx<String> fontFamily = "Outfit".obs;
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  ThemeData? _cachedLightTheme;
  ThemeData? _cachedDarkTheme;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedThemeMode = await sharedPref.getTheme();
    fontFamily.value = "Outfit";

    if (savedThemeMode == 'system') {
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      _updateThemeFromBrightness(brightness);
      themeMode.value = ThemeMode.system;
      theme.value = brightness == Brightness.light
          ? (_cachedLightTheme ??= AppTheme.light(fontFamily: fontFamily.value))
          : (_cachedDarkTheme ??= AppTheme.dark(fontFamily: fontFamily.value));
    } else {
      if (savedThemeMode == 'light') {
        themeMode.value = ThemeMode.light;
        theme.value = _cachedLightTheme ??= AppTheme.light(fontFamily: fontFamily.value);
      } else {
        themeMode.value = ThemeMode.dark;
        theme.value = _cachedDarkTheme ??= AppTheme.dark(fontFamily: fontFamily.value);
      }
    }
  }

  void _updateThemeFromBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      _cachedLightTheme ??= AppTheme.light(fontFamily: fontFamily.value);
    } else {
      _cachedDarkTheme ??= AppTheme.dark(fontFamily: fontFamily.value);
    }
  }

  Future<void> setThemeMode(ThemeMode newMode) async {
    String themeModeString;
    switch (newMode) {
      case ThemeMode.system:
        themeModeString = 'system';
        final brightness = WidgetsBinding.instance.window.platformBrightness;
        _updateThemeFromBrightness(brightness);
        break;
      case ThemeMode.light:
        themeModeString = 'light';
        _cachedLightTheme ??= AppTheme.light(fontFamily: fontFamily.value);
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        _cachedDarkTheme ??= AppTheme.dark(fontFamily: fontFamily.value);
        break;
    }

    themeMode.value = newMode;

    theme.value = newMode == ThemeMode.system
        ? (WidgetsBinding.instance.window.platformBrightness == Brightness.light
            ? _cachedLightTheme!
            : _cachedDarkTheme!)
        : (newMode == ThemeMode.light ? _cachedLightTheme! : _cachedDarkTheme!);

    await sharedPref.setTheme(themeModeString);
  }

  Future<void> toggleTheme() async {
    final currentMode = themeMode.value;

    if (currentMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      await setThemeMode(
          brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light);
    } else {
      await setThemeMode(
          currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
    }
  }

  void updateFontFamily(String newFontFamily) {
    fontFamily.value = newFontFamily;

    _cachedLightTheme = AppTheme.light(fontFamily: newFontFamily);
    _cachedDarkTheme = AppTheme.dark(fontFamily: newFontFamily);

    theme.value = themeMode.value == ThemeMode.system
        ? (WidgetsBinding.instance.window.platformBrightness == Brightness.light
            ? _cachedLightTheme!
            : _cachedDarkTheme!)
        : (themeMode.value == ThemeMode.light ? _cachedLightTheme! : _cachedDarkTheme!);
  }
}
