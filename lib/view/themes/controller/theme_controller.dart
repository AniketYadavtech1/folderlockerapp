import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/themes/newutill/ui/theme_literals.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Observable variables
  final isDarkMode = false.obs;
  final primaryColor = const Color(0xFF6366F1).obs; // Default color
  final selectedFont = 'Roboto'.obs; // Default font
  final isSelectedColor = 0.obs; // 0 = Colors tab selected, 1 = Fonts tab selected (for ThemeSettingsScreen)
  final visibleColorCount = 20.obs; // For "Show More / Show Less" toggle

  /// Expose fontFamily to match what's used in AppTextStyles
  RxString get fontFamily => selectedFont;

  /// Toggle dark/light mode
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  /// Set a specific theme mode
  void setTheme(bool isDark) {
    isDarkMode.value = isDark;
  }

  /// Update the primary color
  void setPrimaryColor(Color color) {
    primaryColor.value = color;
  }

  /// Update font family safely
  void setFontFamily(String font) {
    if (kAvailableFonts.contains(font)) {
      selectedFont.value = font;
    }
  }

  /// Toggle color grid item count (Show More / Show Less)
  void toggleShowAllColors() {
    if (visibleColorCount.value == 20) {
      visibleColorCount.value = kAvailableColors.length;
    } else {
      visibleColorCount.value = 20;
    }
  }

  /// Get current theme data (light/dark)
  ThemeData get themeData => ThemeData(
        brightness: isDarkMode.value ? Brightness.dark : Brightness.light,
        primaryColor: primaryColor.value,
        textTheme: TextTheme(
          bodyMedium: safeFont(
            fontName: selectedFont.value,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: isDarkMode.value ? Colors.white : Colors.black,
          ),
          bodyLarge: safeFont(
            fontName: selectedFont.value,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode.value ? Colors.white : Colors.black,
          ),
        ),
      );
}
