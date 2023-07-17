import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSettingWidget extends StatelessWidget {
  final Function() tap;
  final String title;
  final int? show;
  final bool? option;

  const AppSettingWidget(
      {Key? key, required this.tap, required this.title, this.option = false, this.show})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      splashFactory: NoSplash.splashFactory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CommonText(
                  text: title,
                  style: Poppins.medium(AppColors.mako).s14,
                  maxLines: 1,
                  textAlign: TextAlign.left),
              show!=null
                  ? InkWell(
                      child: option!
                          ? SvgPicture.asset(
                              'assets/icon/toggle_on.svg',
                              width: 43,
                              height: 28,
                            )
                          : SvgPicture.asset(
                              'assets/icon/toggle_off.svg',
                              width: 43,
                              height: 28,
                            ),
                    )
                  : SvgPicture.asset(
                      'assets/icon/arrow.svg',
                      width: 15,
                      height: 12.48,
                    ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 22.5, left: 0, right: 0),
            child: Divider(
              color: AppColors.seashell,
              thickness: 1,
            ),
          )
        ],
      ),
    );
  }
}
