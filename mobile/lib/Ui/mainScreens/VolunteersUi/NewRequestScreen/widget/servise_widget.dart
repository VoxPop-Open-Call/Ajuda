import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../Utils/commanWidget/commonText.dart';
import '../../../../Utils/font_style.dart';
import '../../../../Utils/theme/appcolor.dart';

class ServiceWidget extends StatelessWidget {
  final Function() tab;
  final bool select;
  final String title;
  final String icon;

  const ServiceWidget(
      {Key? key,
      required this.tab,
      required this.select,
      required this.title,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: select ? AppColors.bittersweet : AppColors.white,
            width: 2,
          ),
        ),
        elevation: 2,
        child: InkWell(
          onTap: tab,
          child: Padding(
            padding: const EdgeInsets.only(
                bottom: 15.0, top: 14.0, left: 15.0, right: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: select
                        ? AppColors.bittersweet.withOpacity(0.10)
                        : AppColors.mako.withOpacity(0.10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      icon,
                      height: 18.22,
                      width: 18.15,
                      color: select ? AppColors.bittersweet : AppColors.mako,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7.0, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonText(
                          text: 'servicesNeeds.${title}'.tr(),
                          textAlign: TextAlign.left,
                          style: Poppins.medium(select
                                  ? AppColors.bittersweet
                                  : AppColors.mako)
                              .s14,
                          maxLines: 1,
                        ),
                        select
                            ? CommonText(
                                text: title == 'other'
                                    ? 'request.tellThe'.tr()
                                    : '${'request.aLittle'.tr()}$title${'request.makesEverything'.tr()}',
                                textAlign: TextAlign.left,
                                style: Poppins.regular(AppColors.mako).s10,
                                maxLines: 3,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                // Row(
                //   mainAxisSize: MainAxisSize.max,
                //   children: <Widget>[
                //     const SizedBox(
                //       width: 16.35,
                //     ),
                //
                //   ],
                // ),
                SvgPicture.asset(
                  select
                      ? 'assets/icon/checkbox-on.svg'
                      : "assets/icon/checkbox-off.svg",
                  height: 26,
                  width: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
