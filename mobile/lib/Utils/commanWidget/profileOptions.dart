import 'package:flutter/material.dart';
import '../theme/appcolor.dart';
import '../font_style.dart';
import 'commonText.dart';

class CommonProfileOption extends StatelessWidget {
  const CommonProfileOption(
      {Key? key,
      required this.text,
      required this.onPressed,
      required this.textColors,
      required this.backgroundColor})
      : super(key: key);

  final String text;
  final Color textColors;
  final Color backgroundColor;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 36.0),
      child: InkWell(
        onTap: onPressed,
        child: ListTile(
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          leading: CommonText(
            maxLines: 1,
            textAlign: TextAlign.start,
            text: text,
            style: Poppins.medium(AppColors.white).s16
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: backgroundColor,
            size: 16,
          ),
        ),
      ),
    );
  }
}
