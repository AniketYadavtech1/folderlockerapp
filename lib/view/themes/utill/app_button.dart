import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final bool showIndicator;
  final String? svgAsset;
  final Color? svgColor;
  final double? iconHeight;
  final double? iconWidth;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final TextStyle? textStyle; // <-- NEW PARAMETER

  const AppButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.height,
    this.width,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.showIndicator = false,
    this.svgAsset,
    this.svgColor,
    this.iconHeight,
    this.iconWidth,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.textStyle, // <-- ADDED IN CONSTRUCTOR
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = borderColor ?? AppColors.primary;
    final Color effectiveTextColor = textColor ?? AppColors.black10;
    final Color effectiveBgColor = backgroundColor ?? AppColors.white;
    final double effectiveHeight = height ?? 45;
    final double effectiveWidth = width ?? double.infinity;
    final double effectiveRadius = borderRadius ?? 8;
    final double effectiveFontSize = fontSize ?? 14;
    final FontWeight effectiveFontWeight = fontWeight ?? FontWeight.w400;
    final EdgeInsetsGeometry effectivePadding = EdgeInsets.symmetric(vertical: 10, horizontal: 10);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: effectiveHeight,
        width: effectiveWidth,
        alignment: Alignment.center,
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          border: Border.all(color: effectiveBorderColor),
          borderRadius: BorderRadius.circular(effectiveRadius),
        ),
        child: Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          mainAxisSize: mainAxisSize ?? MainAxisSize.min,
          children: [
            if (svgAsset != null) ...[
              SvgPicture.asset(
                svgAsset!,
                height: iconHeight ?? 18,
                width: iconWidth ?? 18,
                color: svgColor,
              ),
              if (text.trim().isNotEmpty) const SizedBox(width: 6),
            ],
            if (text.trim().isNotEmpty)
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle ??
                      TextStyle(
                        color: effectiveTextColor,
                        fontSize: effectiveFontSize,
                        fontWeight: effectiveFontWeight,
                        fontFamily: 'Poppins',
                      ),
                ),
              ),
            if (showIndicator) ...[
              const SizedBox(width: 6),
              Container(
                height: 7,
                width: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
