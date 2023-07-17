import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model.dart';

class CommonButtons extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final double borderRadius;
  final double minimumSize;
  final Color backgroundColor;
  final Color borderColor;
  final bool enabled;
  final TextStyle style;

  const CommonButtons(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.borderRadius,
      required this.minimumSize,
      required this.backgroundColor,
      required this.borderColor,
      required this.enabled,
      required this.style});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        shadowColor: MaterialStateProperty.all(backgroundColor),
        minimumSize: MaterialStateProperty.all(Size(minimumSize, 52)),
        backgroundColor: MaterialStateProperty.all(backgroundColor),
      ),
      onPressed: enabled ? onPressed : null,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class SimpleButtonLoading<VM extends ViewModel> extends StatelessWidget {
  final void Function() onPressed;
  final Widget text;
  final String? textOnLoading;
  final Color? color;
  final Color? borderColor;
  final double? bottom;
  final double? radius;
  final double? top;
  final TextStyle textStyle;
  final type;

  const SimpleButtonLoading({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textOnLoading,
    this.color,
    required this.textStyle,
    this.bottom,
    this.top,
    this.radius,
    required this.type,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<VM, bool>(
      selector: (_, VM state) =>
          type == 1 ? state.isLoadingFacebook : state.isLoading,
      builder: (_, bool isLoading, __) => InkWell(
        onTap: !isLoading ? onPressed : null,
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        child: Container(
          height: 50,
          width: 303,
          padding: EdgeInsets.only(top: top ?? 0.0, bottom: bottom ?? 0.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius ?? 0.0),
            border: Border.all(
              color: borderColor!,
              width: 1,
            ),
          ),
          child: isLoading
              ? Text(
                  'login.pleaseWait'.tr(),
                  style: textStyle,
                )
              : text,
        ),
      ),
    );
  }
}

class CommonButtonLoading<VM extends ViewModel> extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final String? textOnLoading;
  final double borderRadius;
  final double minimumSize;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle style;

  const CommonButtonLoading({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textOnLoading,
    required this.borderRadius,
    required this.minimumSize,
    required this.backgroundColor,
    required this.borderColor,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<VM, bool>(
      selector: (_, VM state) => state.isLoading,
      builder: (_, bool isLoading, __) => CommonButtons(
        enabled: !isLoading,
        onPressed: onPressed,
        text: isLoading ? textOnLoading ?? 'login.pleaseWait'.tr() : text,
        borderRadius: borderRadius,
        minimumSize: minimumSize,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        style: style,
      ),
    );
  }
}

