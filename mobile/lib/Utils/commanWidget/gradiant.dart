
import 'package:flutter/material.dart';

class gradiantButton extends StatelessWidget {
  final String buttonText;
  final double radious;
  final void Function() onPressed;
  final double? height;
  final BorderRadius? borderRadius;
  final bool _enabled;

  const gradiantButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.borderRadius,
    required this.radious,
    this.height,
    bool? enabled,
  })  : _enabled = enabled ?? true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var mysize = MediaQuery.of(context).size;
    return Container(
      height: height ?? 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radious),
        gradient: const LinearGradient(
          begin: Alignment(-0.95, 0.0),
          end: Alignment(1.0, 0.0),
          colors: [
            Color(0xff337EF6),
            Color(0xff65DEFB),
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radious),
          ),
        ),
        onPressed: _enabled ? onPressed : null,
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: "textColors",
              color: Color(0xffffffff),
              letterSpacing: -0.3858822937011719,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
