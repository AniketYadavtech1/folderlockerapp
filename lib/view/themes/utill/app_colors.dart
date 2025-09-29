import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/themes/controller/theme_controller.dart';
import 'package:get/get.dart';

class AppColors {
  static bool get isDarkMode => Get.find<ThemeController>().isDarkMode.value;

  static var transparent = Colors.transparent;
  static const Color black10 = Color.fromRGBO(56, 57, 58, 1.0);
  static Color get whiteAlways => Colors.white;

  static Color get white => isDarkMode ? CupertinoColors.darkBackgroundGray : CupertinoColors.white;
  static Color get whiteOpacity20 => const Color.fromRGBO(255, 255, 255, 0.3);
  static Color get white10 => isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF6F8FC);
  static Color get white20 => isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFF1F4F9);
  static Color get white30 => isDarkMode ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);
  static Color get white40 => isDarkMode ? const Color(0xFF48484A) : const Color(0xFFCBD4E1);
  static Color get white50 => isDarkMode ? const Color(0xFF636366) : const Color(0xFF94A3B8);
  static Color get white60 => isDarkMode ? const Color(0xFF8E8E93) : const Color(0xFF64748B);
  static Color get white70 => isDarkMode ? const Color(0xFFA1A1A1) : const Color(0xFF475569);
  static Color get white80 => isDarkMode ? const Color(0xFFB5B5B5) : const Color(0xFF27364B);
  static Color get white90 => isDarkMode ? const Color(0xFFD1D1D6) : const Color(0xFF1E2A3B);
  static Color get white100 => isDarkMode ? const Color(0xFFE5E5EA) : const Color(0xFF0F1A2A);

  static Color get primary => Get.find<ThemeController>().primaryColor.value;
  static Color get primary1 => isDarkMode ? const Color(0xFFED416C) : const Color(0xFFD91A5E);
  static Color get primary400 => isDarkMode ? const Color(0xFFB8133E) : const Color(0xFFFACEE1);
  static Color get primary600 => isDarkMode ? const Color(0xFFC41450) : const Color(0xFFF1AAAB);
  static Color get primary700 => isDarkMode ? const Color(0xFFAA1038) : const Color(0xFFE23E57);
  static Color get primary900 => isDarkMode ? const Color(0xFF880A2E) : const Color(0xFFA32D3F);
  static Color get primaryOP => isDarkMode ? const Color(0xFF94495D) : const Color(0xFFF195B4);
  static Color get primaryWithOpacity20 => const Color.fromRGBO(161, 82, 205, 0.5); // Optional

  static Color get success10 => isDarkMode ? const Color(0xFF0F3322) : const Color(0xFFE8FCF1);
  static Color get success20 => isDarkMode ? const Color(0xFF1B4D34) : const Color(0xFFA5E1BF);
  static Color get success40 => isDarkMode ? const Color(0xFF2E7A50) : const Color(0xFF419E6A);
  static Color get success60 => isDarkMode ? const Color(0xFF40B46A) : const Color(0xFF00632B);
  static Color get success80 => isDarkMode ? const Color(0xFF70D494) : const Color(0xFF00401C);
  static Color get success100 => isDarkMode ? const Color(0xFFA4F2C2) : const Color(0xFF002611);

  static Color get successOp =>
      isDarkMode ? const Color.fromRGBO(44, 62, 45, 1.0) : const Color.fromRGBO(216, 253, 210, 1.0);
  static Color get success32 =>
      isDarkMode ? const Color.fromRGBO(3, 150, 113, 1.0) : const Color.fromRGBO(6, 207, 156, 1.0);

  static Color get success30 =>
      isDarkMode ? const Color.fromRGBO(20, 160, 80, 1.0) : const Color.fromRGBO(37, 211, 102, 1.0);
  static Color get info10 => isDarkMode ? const Color(0xFF0D1B39) : const Color(0xFFD3E1FE);
  static Color get info20 => isDarkMode ? const Color(0xFF12367A) : const Color(0xFF7EA5F8);
  static Color get info40 => isDarkMode ? const Color(0xFF2D5FC2) : const Color(0xFF4D82F3);
  static Color get info60 => isDarkMode ? const Color(0xFF438CFF) : const Color(0xFF2563EB);
  static Color get info80 => isDarkMode ? const Color(0xFF6EABFF) : const Color(0xFF0037B3);

  static Color get error10 => isDarkMode ? const Color(0xFF2E0C0C) : const Color(0xFFFFEBEB);
  static Color get error20 => isDarkMode ? const Color(0xFF6D1414) : const Color(0xFFFC9595);

  static Color get error40 =>
      isDarkMode ? Colors.redAccent ?? const Color(0xFFB82121) : Colors.redAccent ?? const Color(0xE6D83232);
  static Color get error60 => isDarkMode ? const Color(0xFFE24B4B) : const Color(0xFFB01212);
  static Color get error80 => isDarkMode ? const Color(0xFFFF8080) : const Color(0xFF8C0000);
  static Color get error100 => isDarkMode ? const Color(0xFFFFA3A3) : const Color(0xFF660000);

  static Color get warning10 => isDarkMode ? const Color(0xFF2C2100) : const Color(0xFFFFF5D5);
  static Color get warning20 => isDarkMode ? const Color(0xFF443100) : const Color(0xFFFFDE81);
  static Color get warning40 => isDarkMode ? const Color(0xFF9C7300) : const Color(0xFFEFB008);
  static Color get warning60 => isDarkMode ? const Color(0xFFE1A51A) : const Color(0xFF976400);
  static Color get warning80 => isDarkMode ? const Color(0xFFFFBE57) : const Color(0xFF724B00);
  static Color get warning100 => isDarkMode ? const Color(0xFFFFD181) : const Color(0xFF4D2900);

  static Color get baseColor => isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
  static Color get highlightColor => isDarkMode ? Colors.grey[500]! : Colors.grey[400]!;
}
