import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpContactsWidget extends StatelessWidget {
  final Function() tap;
  final String text;

  const HelpContactsWidget({Key? key, required this.tap, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.wildSand,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.only(left: 24,top: 19,bottom: 19),
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              'assets/icon/request-call.svg',
              width: 18,
              height: 18,
            ),
            const SizedBox(
              width: 10,
            ),
            CommonText(
                text: text,
                style: Poppins.semiBold(AppColors.mako).s14,
                maxLines: 1,
                textAlign: TextAlign.start)
          ],
        ),
      ),
    );
  }
}
