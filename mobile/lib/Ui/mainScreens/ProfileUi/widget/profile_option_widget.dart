import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileOptionWidget extends StatelessWidget {
  final String text;
  final String icon;
  final double? height;
  final double? width;
  final double? left;
  final double? right;
  final Function() onTap;

  const ProfileOptionWidget(
      {Key? key,
      required this.text,
      required this.icon,
      required this.onTap,
      this.height,
      this.width,
      this.left,
      this.right})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppColors.wildSand),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: 21,
                      bottom: 21,
                      left: left ?? 24,
                      right: right ?? 17.0),
                  child: SvgPicture.asset(
                    icon,
                    height: height ?? 18,
                    width: width ?? 18,
                    fit: BoxFit.fill,
                  ),
                ),
                CommonText(
                    text: text,
                    style: Poppins.semiBold(AppColors.mako).s14,
                    maxLines: 1,
                    textAlign: TextAlign.center)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14, right: 15, top: 14.0),
              child: SvgPicture.asset(
                'assets/icon/arrow.svg',
                height: 15,
                width: 12.48,
                color: AppColors.mako,
              ),
            )
          ],
        ),
      ),
    );
  }
}
