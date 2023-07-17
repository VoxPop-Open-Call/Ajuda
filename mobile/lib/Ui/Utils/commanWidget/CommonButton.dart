import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';
import '../font_style.dart';

class CommonButton extends StatelessWidget {
  final String? buttonText;
  final Color? backgroundColor;
  final void Function()? onPressed;
  final double? borderRadius;
  final double? minimumSize;
  final double? minimumWidget;
  final Color? borderColor;
  final TextStyle? style;
  final Widget? child;

  const CommonButton(
      {super.key,
      this.buttonText,
      required this.borderColor,
      required this.backgroundColor,
      required this.onPressed,
      required this.borderRadius,
      required this.style,
      required this.minimumSize,
      this.child,
      this.minimumWidget});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
            side: BorderSide(color: borderColor!, width: 1),
          ),
        ),
        minimumSize:
            MaterialStateProperty.all(Size(minimumSize!, minimumWidget ?? 45)),
        shadowColor: MaterialStateProperty.all(backgroundColor),
        backgroundColor: MaterialStateProperty.all(backgroundColor),
      ),
      onPressed: onPressed,
      child: child ??
          Text(

            buttonText!,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: style!,
          ),
    );
  }
}
