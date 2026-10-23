import 'package:flutter/material.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.mode = ThemeMode.system]);

  void toggleTheme(bool isDark) {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    value = mode;
  }
}

final themeController = ThemeController();
