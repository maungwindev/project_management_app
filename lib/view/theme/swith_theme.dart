import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/theme_controller.dart'; // adjust import path

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark ||
          (themeController.themeMode.value == ThemeMode.system &&
              MediaQuery.of(context).platformBrightness == Brightness.dark);

      final icon = isDark
          ? const Icon(Icons.wb_sunny, key: ValueKey('sun_icon'))
          : const Icon(Icons.nightlight_round, key: ValueKey('moon_icon'));

      return IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: Tween(begin: 0.5, end: 1.0).animate(animation),
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: icon,
        ),
        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        onPressed: () => themeController.toggleTheme(),
      );
    });
  }
}

class SunMoonThemeSelector extends StatelessWidget {
  const SunMoonThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      IconData iconData;
      Color? iconColor;

      switch (themeController.themeMode.value) {
        case ThemeMode.system:
          iconData = Icons.settings_suggest_outlined;
          iconColor = null;
          break;
        case ThemeMode.light:
          iconData = Icons.wb_sunny;
          iconColor = Colors.amber;
          break;
        case ThemeMode.dark:
          iconData = Icons.nightlight_round;
          iconColor = Colors.indigo;
          break;
      }

      return PopupMenuButton<ThemeMode>(
        icon: Icon(iconData, color: iconColor),
        tooltip: 'Select Theme Mode',
        onSelected: (mode) => themeController.setThemeMode(mode),
        itemBuilder: (context) => [
          _buildMenuItem(
            context,
            value: ThemeMode.system,
            icon: Icons.settings_suggest_outlined,
            text: 'System Theme',
            selected: themeController.themeMode.value == ThemeMode.system,
          ),
          _buildMenuItem(
            context,
            value: ThemeMode.light,
            icon: Icons.wb_sunny,
            iconColor: Colors.amber,
            text: 'Light Mode',
            selected: themeController.themeMode.value == ThemeMode.light,
          ),
          _buildMenuItem(
            context,
            value: ThemeMode.dark,
            icon: Icons.nightlight_round,
            iconColor: Colors.indigo,
            text: 'Dark Mode',
            selected: themeController.themeMode.value == ThemeMode.dark,
          ),
        ],
      );
    });
  }

  PopupMenuItem<ThemeMode> _buildMenuItem(
    BuildContext context, {
    required ThemeMode value,
    required IconData icon,
    Color? iconColor,
    required String text,
    required bool selected,
  }) {
    return PopupMenuItem<ThemeMode>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          if (selected)
            const Icon(
              Icons.check,
              size: 18,
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}
