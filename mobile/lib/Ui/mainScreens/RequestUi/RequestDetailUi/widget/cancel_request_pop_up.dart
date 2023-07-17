import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../Utils/commanWidget/CommonButton.dart';
import '../../../../Utils/commanWidget/commonText.dart';
import '../../../../Utils/font_style.dart';
import '../../../../Utils/theme/appcolor.dart';

class CancelRequestPopUp extends StatefulWidget {
  final Function() complete;
  final date;

  const CancelRequestPopUp({Key? key, required this.complete, this.date})
      : super(key: key);

  @override
  State<CancelRequestPopUp> createState() => _CancelRequestPopUpState();
}

class _CancelRequestPopUpState extends State<CancelRequestPopUp> {
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
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.madison),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icon/file.svg',
                        height: 36,
                        width: 36,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  /*RequestSent*/
                  Padding(
                    padding: const EdgeInsets.only(top: 17.0, bottom: 17.0),
                    child: CommonText(
                      text: 'request.cancelTheService'.tr(),
                      textAlign: TextAlign.center,
                      style: Poppins.semiBold(AppColors.mako).s18,
                      maxLines: 3,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'request.notifyTheVolunteer'.tr(),
                          style:
                              Poppins.medium(AppColors.mako.withOpacity(0.80))
                                  .s14,
                        ),
                        TextSpan(
                          text: widget.date,
                          style:
                              Poppins.medium(AppColors.mako.withOpacity(0.80))
                                  .s14,
                        ),
                        TextSpan(
                          text: 'request.willBeCanceled'.tr(),
                          style:
                              Poppins.medium(AppColors.mako.withOpacity(0.80))
                                  .s14,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 28.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonButton(
                          buttonText: 'request.no'.tr(),
                          borderColor: AppColors.madison.withOpacity(0.40),
                          backgroundColor: AppColors.trans,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          borderRadius: 27.0,
                          style: Poppins.bold(AppColors.madison).s14,
                          minimumSize: 110.0,
                          minimumWidget: 52,
                        ),
                        const SizedBox(width: 15),
                        CommonButton(
                          buttonText: 'request.sure'.tr(),
                          borderColor: AppColors.madison,
                          backgroundColor: AppColors.madison,
                          onPressed: widget.complete,
                          borderRadius: 27.0,
                          style: Poppins.bold(AppColors.white).s14,
                          minimumSize: 110.0,
                          minimumWidget: 52,
                        ),
                      ],
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
