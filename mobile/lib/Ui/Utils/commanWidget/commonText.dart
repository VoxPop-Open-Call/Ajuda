import 'package:flutter/material.dart';

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
      // overflow: TextOverflow.clip,
      text,
      textAlign: textAlign,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,

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
      softWrap: true,
      style: style,
      overflow: TextOverflow.ellipsis,
    );
  }
}
