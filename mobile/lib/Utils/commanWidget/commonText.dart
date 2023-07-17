import 'package:flutter/material.dart';
import 'package:ajuda/Utils/commanWidget/textform_field.dart';

class CommonText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final TextAlign textAlign;

  const CommonText(
      {super.key,
      required this.text,
      required this.style,
      required this.maxLines,
      required this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style,
      maxLines: maxLines,

    );
  }
}

class CommonTextSimple extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const CommonTextSimple(
      {super.key,
      required this.text,
      required this.style,
      required this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,

      style: TextStyle(
           color: Colors.grey[800],
           fontWeight: FontWeight.bold,
           fontSize: 40)
    );
  }
}

