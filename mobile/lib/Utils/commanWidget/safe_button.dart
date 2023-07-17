import 'package:flutter/material.dart';

class SafeButton extends StatefulWidget {
  const SafeButton(
      {Key? key,
      required this.child,
      required this.onPressed,
      this.delay = 2000})
      : super(key: key);

  final VoidCallback onPressed;
  final Widget child;
  final double delay;

  @override
  State<SafeButton> createState() => _SafeButtonState();
}

class _SafeButtonState extends State<SafeButton> {
  DateTime lastClickedOn = DateTime(1970, 1, 1);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final currentTime = DateTime.now();
        final duration = lastClickedOn.difference(currentTime);
        if (duration.inMilliseconds.abs() > widget.delay) {
          widget.onPressed();
        }
        lastClickedOn = DateTime.now();
      },
      child: widget.child,
    );
  }
}
