import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // <-- Add this
import 'package:folderlockerapp/view/themes/controller/theme_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Add this

class AppTextStyles {
  static ThemeController get _controller => Get.find();

  static TextStyle get kLargeTitleTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.bold,
        fontSize: 24.sp,
      );

  static TextStyle get kHeading1TextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.bold,
        fontSize: 20.sp,
      );

  static TextStyle get kHeading2TextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.w600,
        fontSize: 18.sp,
      );

  static TextStyle get kHeading2RegularTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontSize: 18.sp,
      );

  static TextStyle get kHeading3TextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
      );

  static TextStyle get kHeading3RegularTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontSize: 16.sp,
      );

  static TextStyle get kBody20RegularTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontSize: 14.sp,
      );

  static TextStyle get kBody20SemiBoldTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.w600,
        fontSize: 14.spMin, // Needs flutter_screenutil >= 5.9.0
      );

  static TextStyle get kBody17RegularTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontSize: 12.sp,
      );

  static TextStyle get kBody17SemiBoldTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.w600,
        fontSize: 12.sp,
      );

  static TextStyle get kBody15RegularTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontSize: 10.sp,
      );

  static TextStyle get kBody15SemiBoldTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.w600,
        fontSize: 10.sp,
      );

  static TextStyle get kCaption12RegularTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontSize: 8.sp,
      );

  static TextStyle get kCaption12SemiBoldTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.w600,
        fontSize: 8.sp,
      );

  static TextStyle get kSmall10RegularTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontSize: 6.sp,
      );

  static TextStyle get kSmall10SemiBoldTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.w600,
        fontSize: 6.sp,
      );

  static TextStyle get kSmall8RegularTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontSize: 4.sp,
      );

  static TextStyle get kSmall8SemiBoldTextStyle => GoogleFonts.getFont(
        _controller.fontFamily.value,
        fontWeight: FontWeight.w600,
        fontSize: 4.sp,
      );
}
