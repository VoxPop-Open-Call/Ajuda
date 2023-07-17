import 'package:ajuda/Utils/commanWidget/textform_field.dart';
import 'package:flutter/material.dart';


formText({required String text, String? iconReq, double? fontSize}) {
  return RichText(
    text: TextSpan(
      text: text,
      style: outFitRegular(
        fontColor:Color(0xff231F20),
        fontWeight: FontWeight.w400,
        fontSize: fontSize ?? 14,
      ),
      children: [
        //SvgPicture.asset("assets/icons/_.svg"),
        TextSpan(
          text:  "*",
          style: outFitRegular(
            fontColor: Color(0xffEC2228),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        )
      ],
    ),
  );
}