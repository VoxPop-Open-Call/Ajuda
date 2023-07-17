import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../Utils/commanWidget/network_image.dart';
import '../../../../Utils/theme/appcolor.dart';

class HistoryScreenWidget extends StatelessWidget {
  final String activityName;
  final String name;
  final String dateTime;
  final String image;
  final String? comment;
  final double rating;

  const HistoryScreenWidget(
      {Key? key,
      required this.dateTime,
      required this.image,
      required this.activityName,
      required this.name,
      this.comment,
      required this.rating})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: AppColors.madison.withOpacity(0.10),
                  // shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white, //color of shadow
                      spreadRadius: 2, //spread radius
                      blurRadius: 2, // blur radius
                      offset: Offset(0, 2), // changes position of shadow
                      //second parameter is top to down
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    activityName == 'company'
                        ? 'assets/icon/keepCompany.svg'
                        : activityName == 'pharmacy'
                            ? 'assets/icon/pharmacies.svg'
                            : activityName == 'shopping'
                                ? 'assets/icon/cart.svg'
                                : activityName == 'tours'
                                    ? 'assets/icon/map.svg'
                                    : 'assets/icon/file.svg',
                    width: 15,
                    height: 15,
                    color: AppColors.madison,
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Container(
                width: 1,
                height: comment != null ? 141.23 : 85.5,
                color: AppColors.madison.withOpacity(0.10),
              ),
            ],
          ),
          const SizedBox(
            width: 7.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CommonText(
                    text:  'servicesNeeds.$activityName'.tr(),
                    style: Poppins.bold(AppColors.madison).s15,
                    maxLines: 1,
                    textAlign: TextAlign.left),
                CommonText(
                    text: dateTime,
                    style: Poppins.regular(AppColors.baliHai).s12,
                    maxLines: 1,
                    textAlign: TextAlign.left),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: comment != null ? 9.0 : 29.5),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        height: 45,
                        width: 45,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80.0),
                          child: MyNetworkImage.circular(
                              url: image),
                        ),
                      ),
                      const SizedBox(
                        width: 6.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CommonText(
                              text: name,
                              style: Poppins.medium(AppColors.mako).s14,
                              maxLines: 2,
                              textAlign: TextAlign.start),
                          RatingBarIndicator(
                            rating: rating,
                            itemBuilder: (context, index) => SvgPicture.asset(
                              'assets/icon/rate-on.svg',
                              width: 10.89,
                              height: 10.91,
                            ),
                            itemCount: 5,
                            itemPadding: const EdgeInsets.only(right: 4),
                            itemSize: 10.91,
                            unratedColor: AppColors.mako.withOpacity(0.10),
                            direction: Axis.horizontal,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                if (comment != null)
                  CommonText(
                      text: comment!,
                      style: Poppins.regular(AppColors.mako).s14,
                      maxLines: 2,
                      textAlign: TextAlign.left),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
