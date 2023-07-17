import 'package:ajuda/Ui/Utils/commanWidget/CommonButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/commanWidget/network_image.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';

class PendingRequestWidget extends StatelessWidget {
  final String name, year, image, task, description, date, time;
  final void Function() onPressedAccept;
  final void Function() onPressedReject;

  const PendingRequestWidget(
      {Key? key,
      required this.name,
      required this.year,
      required this.image,
      required this.task,
      required this.description,
      required this.date,
      required this.time,
      required this.onPressedAccept,
      required this.onPressedReject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 21.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(27.0),
          side: const BorderSide(color: AppColors.white),
        ),
        color: AppColors.white,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 25, bottom: 23, right: 23, left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                        left: 0.0, right: 14.0, top: 0.0, bottom: 0.0),
                    width: 85,
                    height: 85,
                    // color: AppColors.madison,
                    child: Stack(
                      children: <Widget>[
                         Align(
                          alignment: Alignment.center,
                          child:SizedBox(
                            height: 85,
                            width: 85,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(80.0),
                              child: MyNetworkImage.circular(
                                  url: image??''),
                            ),
                          ),

                          /*CircleAvatar(
                            backgroundImage: NetworkImage(''),
                            radius: 85,
                            backgroundColor: AppColors.madison,
                          ),*/
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: AppColors.madison,
                              // shape: BoxShape.circle,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.white,
                                  //color of shadow
                                  spreadRadius: 2,
                                  //spread radius
                                  blurRadius: 2,
                                  // blur radius
                                  offset: Offset(
                                      0, 2), // changes position of shadow
                                  //second parameter is top to down
                                ),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                task == 'Company'
                                    ? 'assets/icon/keepCompany.svg'
                                    : task == 'Pharmacy'
                                        ? 'assets/icon/pharmacies.svg'
                                        : task == 'Shopping'
                                            ? 'assets/icon/cart.svg'
                                            : task == 'Tours'
                                                ? 'assets/icon/map.svg'
                                                : 'assets/icon/file.svg',
                                width: 20,
                                height: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 85,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CommonText(
                          text: name,
                          style: Poppins.bold(AppColors.mako).s18,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        CommonText(
                          text: '$year ${'volunteer.years_old'.tr()}',
                          style:
                              Poppins.medium(AppColors.mako.withOpacity(0.80))
                                  .s12,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 17.0, bottom: 2.0),
                child: CommonText(
                  text: task,
                  style: Poppins.bold(AppColors.madison).s14,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
              Text(
                description,
                style: Poppins.semiBold(AppColors.mako).s12,
                textAlign: TextAlign.start,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 14, bottom: 17),
                child: Divider(
                  thickness: 2,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icon/date.svg',
                        width: 11,
                        height: 11.42,
                        color: AppColors.mako,
                      ),
                      const SizedBox(
                        width: 7.0,
                      ),
                      CommonText(
                        text: date /*'May 21, 2023'*/,
                        style: Poppins.semiBold(AppColors.mako).s12,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icon/time.svg',
                        width: 11,
                        height: 11.42,
                        color: AppColors.mako,
                      ),
                      const SizedBox(
                        width: 7.0,
                      ),
                      CommonText(
                        text: time,
                        style: Poppins.semiBold(AppColors.mako).s12,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 33, bottom: 23),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CommonButton(
                      borderColor: AppColors.madison.withOpacity(0.08),
                      backgroundColor: AppColors.madison.withOpacity(0.08),
                      onPressed: onPressedReject,
                      borderRadius: 27,
                      style: Poppins.bold(AppColors.madison).s14,
                      minimumSize: 120,
                      buttonText: 'volunteer.decline'.tr(),
                      minimumWidget: 52,
                    ),
                    CommonButton(
                      borderColor: AppColors.bittersweet,
                      backgroundColor: AppColors.bittersweet,
                      onPressed:  onPressedAccept,
                      borderRadius: 27,
                      style: Poppins.bold(AppColors.white).s14,
                      minimumSize: 120,
                      buttonText: 'volunteer.accept'.tr(),
                      minimumWidget: 52,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
