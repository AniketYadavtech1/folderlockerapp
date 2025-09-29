import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class CommonTextField extends StatelessWidget {
  final String? Function(String?)? validator;
  final TextInputType? keyBoardType;
  final TextEditingController? con;
  final bool? readOnly;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;
  final Function()? onEditingComplete;
  final Function(String)? onChanged;
  final String? labelText;
  final Widget? suffix;
  final Color? suffixColor;
  final Color? fillColor;
  final void Function()? suffixOnTap;
  final Widget? prefixIcon;
  final Widget? prefix;
  final double? constraintHeight;
  final TextStyle? labelStyle;
  final String? hintText;
  final String? headerLabel;
  final TextStyle? hintStyle;
  final InputBorder? focusedBorder;
  final TextStyle? style;
  final double? borderRadius;
  final Color? borderColor;
  final InputBorder? border;
  final EdgeInsetsGeometry? contentPadding;
  final double? height;
  final double? cursorHeight;
  final TextCapitalization? textCapitalization;
  final FocusNode? focusNode;
  final bool? enabled;

  const CommonTextField({
    super.key,
    this.keyBoardType,
    this.con,
    this.validator,
    this.readOnly,
    this.onTap,
    this.inputFormatters,
    this.obscureText,
    this.onEditingComplete,
    this.onChanged,
    this.labelText,
    this.suffix,
    this.suffixColor,
    this.fillColor,
    this.suffixOnTap,
    this.prefixIcon,
    this.prefix,
    this.constraintHeight,
    this.labelStyle,
    this.hintText,
    this.headerLabel,
    this.hintStyle,
    this.focusedBorder,
    this.style,
    this.borderRadius,
    this.borderColor,
    this.border,
    this.contentPadding,
    this.height,
    this.cursorHeight,
    this.textCapitalization,
    this.focusNode,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerLabel != null) ...[
          Text(
            headerLabel ?? "",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
        ],
        Container(
          height: height,
          child: TextFormField(
            controller: con,
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            keyboardType: keyBoardType,
            validator: validator,
            readOnly: readOnly ?? false,
            onTap: onTap,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: obscureText ?? false,
            inputFormatters: inputFormatters,
            cursorColor: AppColors.black10,
            cursorErrorColor: Colors.red,
            onEditingComplete: onEditingComplete,
            onChanged: onChanged,
            cursorHeight: cursorHeight,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: style ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
            minLines: height != null ? (height! / 24).floor() : 1, // 24 is approx line height
            maxLines: height != null ? (height! / 24).floor() : 1,
            decoration: InputDecoration(
              fillColor: fillColor,
              contentPadding: contentPadding,
              filled: fillColor != null,
              constraints: BoxConstraints(maxHeight: constraintHeight ?? double.infinity),
              isDense: true,
              hintText: hintText,
              hintStyle: hintStyle ?? const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              labelStyle: labelStyle ?? const TextStyle(fontSize: 14),
              labelText: labelText,
              prefixIcon: prefixIcon,
              prefix: prefix,
              focusedBorder: border ??
                  OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.black10),
                    borderRadius: BorderRadius.circular(borderRadius ?? 7),
                  ),
              enabledBorder: border ??
                  OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor ?? AppColors.black10),
                    borderRadius: BorderRadius.circular(borderRadius ?? 7),
                  ),
              disabledBorder: border ??
                  OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor ?? AppColors.black10),
                    borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  ),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius ?? 10)),
              // errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius ?? 10)),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(onTap: suffixOnTap, child: suffix),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
