import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget? child;
  final Color? backgroundColor;
  final Color? borderColor;

  const SocialButton(
      {Key? key,
      required this.onTap,
      this.backgroundColor,
      this.borderColor,
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all<double>(0.0),
        backgroundColor: MaterialStateProperty.all<Color>(
          backgroundColor!,
        ),
        fixedSize: MaterialStateProperty.all<Size>(Size(size.width, 50)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: borderColor!,
              width: 1,
            ),
          ),
        ),
      ),
      child: child,
    );
  }
}
