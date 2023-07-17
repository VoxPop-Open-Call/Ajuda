import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonBackButton extends StatelessWidget {
  final void Function()? onPressed;
  final icon;

  const CommonBackButton({Key? key, this.onPressed, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ??
          () {
            Navigator.of(context).pop();
          },
      child: SizedBox(
        height: 39,
        width: 39,
        child: Center(
          child: SvgPicture.asset(
            icon ?? 'assets/icon/back.svg',
            width: 15.0,
            height: 12.48,
          ),
        ),
      ),
    );
  }
}
