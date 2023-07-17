import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../Utils/commanWidget/CommonButton.dart';
import '../../../../Utils/commanWidget/commonText.dart';
import '../../../../Utils/font_style.dart';
import '../../../../Utils/theme/appcolor.dart';

class RateUsConformationPopUp extends StatefulWidget {
  final Function() complete;

  const RateUsConformationPopUp({Key? key, required this.complete}) : super(key: key);

  @override
  State<RateUsConformationPopUp> createState() => _RateUsConformationPopUpState();
}

class _RateUsConformationPopUpState extends State<RateUsConformationPopUp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: AppColors.black.withOpacity(0.79),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: AppColors.white),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 27,
                bottom: 32,
                left: 25,
                right: 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /*logo*/
                  Container(
                    height: 60,
                    width: 60,
                    decoration:const BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.madison),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icon/rate-request.svg',
                        height: 28,
                        width: 28,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  /*RequestSent*/
                  Padding(
                    padding: const EdgeInsets.only(top: 17.0, bottom: 17.0),
                    child: CommonText(
                      text: 'rate.feedback'.tr(),
                      textAlign: TextAlign.center,
                      style: Poppins.semiBold(AppColors.mako).s18,
                      maxLines: 4,
                    ),
                  ),
                  CommonText(
                    text: 'rate.importantForTheCommunity'.tr(),
                    textAlign: TextAlign.center,
                    style: Poppins.medium(AppColors.mako.withOpacity(0.80)).s14,
                    maxLines: 6,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 28.0),
                    child: CommonButton(
                      buttonText: 'rate.ok'.tr(),
                      borderColor: AppColors.madison,
                      backgroundColor: AppColors.madison,
                      onPressed: widget.complete,
                      borderRadius: 22.0,
                      style: Poppins.bold(AppColors.white).s14,
                      minimumSize: 120.0,
                      minimumWidget: 44,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
