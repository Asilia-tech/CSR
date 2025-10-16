import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = false.obs;
  static const THEME_KEY = 'is_dark_mode';

  @override
  void onInit() {
    super.onInit();
    loadThemeFromPrefs();
  }

  // Load saved theme preference
  Future<void> loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final darkModeOn = prefs.getBool(THEME_KEY) ?? false;
    isDarkMode.value = darkModeOn;
    _applyTheme();
  }

  void toggleTheme() {
    isDarkMode.toggle();
    _saveThemeToPrefs();
    _applyTheme();
    update();
  }

  Future<void> _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(THEME_KEY, isDarkMode.value);
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    update();
  }
}
