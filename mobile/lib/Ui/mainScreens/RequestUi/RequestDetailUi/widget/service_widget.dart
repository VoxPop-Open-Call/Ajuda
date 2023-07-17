import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServiceWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool arrowShow;
  final int? count;
  final Function() goAhead;

  const ServiceWidget(
      {Key? key,
      required this.icon,
      required this.title,
      required this.arrowShow,
      this.count,
      required this.goAhead})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      onTap: goAhead,
      child: Container(
        padding:
            const EdgeInsets.only(left: 24, top: 21, bottom: 21, right: 23.89),
        decoration: BoxDecoration(
          color: AppColors.wildSand,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: <Widget>[
                SvgPicture.asset(
                  icon,
                  height: 18,
                  width: 17.95,
                ),
                const SizedBox(
                  width: 17.05,
                ),
                CommonText(
                    text: title,
                    style: Poppins.semiBold(AppColors.mako).s14,
                    maxLines: 1,
                    textAlign: TextAlign.center),
                if (count != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    height: 22,
                    width: 22,
                    decoration: const BoxDecoration(
                        color: AppColors.bittersweet, shape: BoxShape.circle),
                    child: Center(
                      child: CommonText(
                        text: count.toString(),
                        style: Poppins.bold(AppColors.white).s12,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            if(arrowShow)
            SvgPicture.asset(
              'assets/icon/arrow.svg',
              width: 15,
              height: 12.48,
            )
          ],
        ),
      ),
    );
  }
}
