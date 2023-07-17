import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';

class Font {
  var _textStyle = const TextStyle();

  TextStyle get s40 => _textStyle.copyWith(fontSize: 40);

  TextStyle get s36 => _textStyle.copyWith(fontSize: 36);
  TextStyle get s35 => _textStyle.copyWith(fontSize: 35);

  TextStyle get s32 => _textStyle.copyWith(fontSize: 32);

  TextStyle get s30 => _textStyle.copyWith(fontSize: 30);

  TextStyle get s27 => _textStyle.copyWith(fontSize: 27);

  TextStyle get s25 => _textStyle.copyWith(fontSize: 25);

  TextStyle get s24 => _textStyle.copyWith(fontSize: 24);

  TextStyle get s22 => _textStyle.copyWith(fontSize: 22);

  TextStyle get s20 => _textStyle.copyWith(fontSize: 20);

  TextStyle get s18 => _textStyle.copyWith(fontSize: 18);

  TextStyle get s16 => _textStyle.copyWith(fontSize: 16);

  TextStyle get s14 => _textStyle.copyWith(fontSize: 14);

  TextStyle get s15 => _textStyle.copyWith(fontSize: 15);

  TextStyle get s13 => _textStyle.copyWith(fontSize: 13);

  TextStyle get s12 => _textStyle.copyWith(fontSize: 12);

  TextStyle get s11 => _textStyle.copyWith(fontSize: 11);

  TextStyle get s10 => _textStyle.copyWith(fontSize: 10);

  TextStyle get s9 => _textStyle.copyWith(fontSize: 9);

  TextStyle get s7 => _textStyle.copyWith(fontSize: 7);

  TextStyle get s5 => _textStyle.copyWith(fontSize: 5);
}

class Poppins extends Font {
  Poppins.light([final Color? color]) {
    _textStyle = _textStyle.copyWith(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w300,
      color: color ?? AppColors.madison,
    );
  }

  Poppins.regular([final Color? color]) {
    _textStyle = _textStyle.copyWith(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.madison,
    );
  }

  Poppins.medium([final Color? color]) {
    _textStyle = _textStyle.copyWith(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.madison,
    );
  }

  Poppins.semiBold([final Color? color]) {
    _textStyle = _textStyle.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.madison);
  }

  Poppins.semiBoldUnderLine([final Color? color]) {
    _textStyle = _textStyle.copyWith(
      fontFamily: 'Poppins',

      fontWeight: FontWeight.w600,
      // color: color ?? AppColors.madison,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.madison,
      decorationStyle: TextDecorationStyle.solid,
      color: Colors.transparent,
      // Step 2 SEE HERE
      shadows: [
        Shadow(offset: Offset(0, -1), color: color ?? AppColors.madison)
      ],
    );
  }

  Poppins.boldUnderLine([final Color? color]) {
    _textStyle = _textStyle.copyWith(
      fontFamily: 'Poppins',

      fontWeight: FontWeight.w700,
      // color: color ?? AppColors.madison,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.bittersweet,
      decorationStyle: TextDecorationStyle.solid,
      color: Colors.transparent,
      decorationThickness: 3,
      // Step 2 SEE HERE
      shadows: [
        Shadow(offset: Offset(0, -5), color: color ?? AppColors.bittersweet)
      ],
    );
  }

  Poppins.bold([final Color? color]) {
    _textStyle = _textStyle.copyWith(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.madison,
    );
  }
}
