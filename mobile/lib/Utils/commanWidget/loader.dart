import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ), // Dialog background
        child: const CupertinoActivityIndicator(
          color: Colors.black,
        ),
      ),
    );
  }
}