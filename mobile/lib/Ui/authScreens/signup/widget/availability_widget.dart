import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/commanWidget/CommonButton.dart';

class AvailabilityWidget extends StatelessWidget {
  final Function() tab;
  final Function() startDateTab;
  final Function() endDateTab;
  final String title;
  final String startTime;
  final String endTime;
  final bool selected;

  const AvailabilityWidget(
      {Key? key,
      required this.tab,
      required this.title,
      required this.startTime,
      required this.endTime,
      required this.selected,
      required this.startDateTab,
      required this.endDateTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.only(
          bottom: 18.0, top: 18.0, right: 20.0, left: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: AppColors.alabaster,
        border: Border.all(color: selected?AppColors.bittersweet:AppColors.alabaster,width: 2)
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CommonText(
                  text: title,
                  style: Poppins.medium(AppColors.mako).s15,
                  maxLines: 1,
                  textAlign: TextAlign.left),
              InkWell(
                onTap: tab,
                child: SvgPicture.asset(
                  selected
                      ? 'assets/icon/toggle_on.svg'
                      : 'assets/icon/toggle_off.svg',
                  width: 43.0,
                  height: 28.0,
                ),
              ),
            ],
          ),
          Visibility(
            visible: selected,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CommonButton(
                    borderColor: AppColors.mako.withOpacity(0.20),
                    backgroundColor: AppColors.trans,
                    onPressed: startDateTab,
                    borderRadius: 11,
                    style: Poppins.bold(AppColors.mako).s16,
                    minimumSize: 110,
                    minimumWidget: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        CommonText(
                            text: startTime,
                            style: Poppins.semiBold(AppColors.mako).s13,
                            maxLines: 1,
                            textAlign: TextAlign.center),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.mako,
                        ),
                      ],
                    ),
                  ),
                  CommonText(
                      text: 'Availability.to'.tr(),
                      style: Poppins.medium(AppColors.mako).s14,
                      maxLines: 1,
                      textAlign: TextAlign.center),
                  CommonButton(
                    borderColor: AppColors.mako.withOpacity(0.20),
                    backgroundColor: AppColors.trans,
                    onPressed: endDateTab,
                    borderRadius: 11,
                    style: Poppins.bold(AppColors.mako).s16,
                    minimumSize: 110,
                    minimumWidget: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        CommonText(
                            text: endTime,
                            style: Poppins.semiBold(AppColors.mako).s13,
                            maxLines: 1,
                            textAlign: TextAlign.center),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.mako,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
