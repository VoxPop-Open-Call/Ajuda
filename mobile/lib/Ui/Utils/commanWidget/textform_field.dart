import 'package:ajuda/Ui/authScreens/signup/widget/number_text_filed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../theme/appcolor.dart';

class TextFormField_Common extends StatelessWidget {
  final String? initialText;
  final String hintText;
  final String? errorText;
  final Color textColor;
  final Color? fillColor;
  final int? maxLines;
  final int? minLines;
  final TextStyle textStyle;
  final TextStyle textStyleHint;
  final bool obscureText;
  final bool? autofocus;
  final bool? readOnly;
  final int? cLength;
  final double? width;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixText;
  final Widget? prefixIcon;
  final TextInputType textInputType;
  final Function(String?)? onChanged;
  final Function()? onTap;
  final double? contentPadding;
  final double? contentPaddingTop;
  final double? borderRadius;
  final TextEditingController? textEditingController;

  const TextFormField_Common({
    super.key,
    this.initialText,
    required this.textColor,
    required this.hintText,
    required this.textInputType,
    this.maxLines,
    this.minLines,
    required this.obscureText,
    this.suffixIcon,
    this.prefixIcon,
    this.errorText,
    this.onChanged,
    required this.textStyle,
    required this.textStyleHint,
    this.contentPadding,
    this.contentPaddingTop,
    this.fillColor,
    this.readOnly,
    this.borderRadius,
    this.cLength,
    this.maxLength,
    this.textEditingController,
    this.prefixText,
    this.autofocus,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialText,
      inputFormatters: [
        LengthLimitingTextInputFormatter(cLength ?? null),
      ],
      onTap: onTap ?? null,
      maxLines: maxLines ?? null,
      style: textStyle,
      minLines: minLines ?? null,
      controller: textEditingController ?? null,
      keyboardType: textInputType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      autocorrect: false,
      autofocus: autofocus ?? false,
      cursorColor: AppColors.madison,
      obscureText: obscureText,
      maxLength: maxLength ?? null,
      textAlignVertical: TextAlignVertical.center,
      readOnly: readOnly ?? false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(
          left: contentPadding ?? 0,
          top: contentPaddingTop ?? 0,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.gallery, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        filled: true,
        prefix: prefixText ?? null,
        fillColor: fillColor ?? AppColors.alabaster,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.gallery, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.gallery, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.bittersweet, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        errorText: errorText ?? null,
        errorMaxLines: 2,
        errorStyle: textFieldTextStyle(AppColors.bittersweet),
        suffixIcon: suffixIcon != null
            ? SizedBox(
                width: 24,
                height: 24,
                child: Center(child: suffixIcon),
              )
            : null,
        prefixIcon: prefixIcon != null
            ? SizedBox(
                width: width ?? 85.0,
                height: 24,
                child: Center(child: prefixIcon),
              )
            : null,

        hintText: hintText,
        hintStyle: textStyleHint,
      ),
      validator: (String? value) {},
    );
  }
}

NumberTextInputFormatter _phoneNumberFormatter = NumberTextInputFormatter(1);

MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '###-###-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy);

class TextFormField_Number extends StatelessWidget {
  final String? initialText;
  final String hintText;
  final String? errorText;
  final Color textColor;
  final Color? fillColor;
  final int? maxLines;
  final int? minLines;
  final TextStyle textStyle;
  final TextStyle textStyleHint;
  final bool obscureText;
  final bool? autofocus;
  final bool? readOnly;
  final int? cLength;
  final double? width;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixText;
  final Widget? prefixIcon;
  final TextInputType textInputType;
  final Function(String?)? onChanged;
  final double? contentPadding;
  final double? contentPaddingTop;
  final double? borderRadius;
  final TextEditingController? textEditingController;

  const TextFormField_Number({
    super.key,
    this.initialText,
    required this.textColor,
    required this.hintText,
    required this.textInputType,
    this.maxLines,
    this.minLines,
    required this.obscureText,
    this.suffixIcon,
    this.prefixIcon,
    this.errorText,
    this.onChanged,
    required this.textStyle,
    required this.textStyleHint,
    this.contentPadding,
    this.contentPaddingTop,
    this.fillColor,
    this.readOnly,
    this.borderRadius,
    this.cLength,
    this.maxLength,
    this.textEditingController,
    this.prefixText,
    this.autofocus,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialText,
      inputFormatters: [maskFormatter],
      maxLines: maxLines ?? null,
      style: textStyle,
      minLines: minLines ?? null,
      controller: textEditingController ?? null,
      keyboardType: textInputType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      autocorrect: false,
      autofocus: autofocus ?? false,
      cursorColor: AppColors.madison,
      obscureText: obscureText,
      maxLength: maxLength ?? null,
      textAlignVertical: TextAlignVertical.center,
      readOnly: readOnly ?? false,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(
          left: contentPadding ?? 0,
          top: contentPaddingTop ?? 0,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.gallery, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        filled: true,
        prefix: prefixText ?? null,
        fillColor: fillColor ?? AppColors.alabaster,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.gallery, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.gallery, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.bittersweet, width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        errorText: errorText ?? null,
        errorMaxLines: 2,
        errorStyle: textFieldTextStyle(AppColors.bittersweet),
        suffixIcon: suffixIcon != null
            ? SizedBox(
                width: 24,
                height: 24,
                child: Center(child: suffixIcon),
              )
            : null,
        prefixIcon: prefixIcon != null
            ? SizedBox(
                width: width ?? 85.0,
                height: 24,
                child: Center(child: prefixIcon),
              )
            : null,

        hintText: hintText,
        hintStyle: textStyleHint,
      ),
      validator: (String? value) {},
    );
  }
}

TextStyle outFitRegular(
    {Color? fontColor, FontWeight? fontWeight, double? fontSize}) {
  return TextStyle(
    color: fontColor ?? Colors.white,
    fontFamily: 'Gilroy-Medium',
    fontWeight: fontWeight ?? FontWeight.w400,
    fontSize: fontSize ?? 22,
  );
}

TextStyle outFitRegulars(
    {Color? fontColor, FontWeight? fontWeight, double? fontSize}) {
  return TextStyle(
    color: fontColor,
    fontFamily: 'Gilroy-Regular',
    fontWeight: fontWeight ?? FontWeight.w400,
    fontSize: fontSize ?? 14,
  );
}

TextStyle textFieldTextStyle(Color textColors) {
  return TextStyle(
    fontFamily: 'Avetra Semibold Regular',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: textColors.withOpacity(0.76),
  );
}
