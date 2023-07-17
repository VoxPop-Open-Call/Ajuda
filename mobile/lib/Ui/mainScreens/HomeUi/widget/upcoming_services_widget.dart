import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/data/remote/model/taskModel/task_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/commanWidget/network_image.dart';

class UpcomingServicesWidget extends StatelessWidget {
  final bool type;
  final bool calender;
  final TaskModel upcomingList;
  final void Function() tab;

  const UpcomingServicesWidget(
      {Key? key,
      required this.type,
      required this.upcomingList,
      required this.tab,
      required this.calender})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tab,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: calender,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14.0, left: 5),
              child: CommonText(
                text: DateFormat('MMM dd, yyyy')
                    .format(DateTime.parse(upcomingList.date!))
                    .toString(),
                style: Poppins.semiBold(AppColors.mako).s14,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 27.0, bottom: 27.0),
                  width: 85,
                  height: 85,
                  // color: AppColors.madison,
                  child: Stack(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 85,
                            width: 85,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(80.0),
                              child: MyNetworkImage.circular(
                                  url: upcomingList.volunteer?.image ?? ''),
                            ),
                          )
                          // CircleAvatar(
                          //   backgroundImage: AssetImage('assets/images/Oval-1.png'),
                          //   radius: 85,
                          //   backgroundColor: AppColors.madison,
                          // ),
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
                                color: Colors.white, //color of shadow
                                spreadRadius: 2, //spread radius
                                blurRadius: 2, // blur radius
                                offset:
                                    Offset(0, 2), // changes position of shadow
                                //second parameter is top to down
                              ),
                            ],
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              upcomingList.taskType!.title == 'company'
                                  ? 'assets/icon/keepCompany.svg'
                                  : upcomingList.taskType!.title == 'pharmacy'
                                      ? 'assets/icon/pharmacies.svg'
                                      : upcomingList.taskType!.title ==
                                              'shopping'
                                          ? 'assets/icon/cart.svg'
                                          : upcomingList.taskType!.title ==
                                                  'tours'
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CommonText(
                        text: capitalize(upcomingList.volunteer?.name ?? ''),
                        style: Poppins.bold(AppColors.madison).s16,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                      ),
                      CommonText(
                        text: 'servicesNeeds.${upcomingList.taskType!.title!}'
                            .tr(),

                        // text: capitalize(upcomingList.taskType!.title!),
                        style: Poppins.medium(AppColors.mako).s12,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0, top: 1),
                        child: Row(
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
                              text: DateFormat('MMM dd, yyyy')
                                  .format(DateTime.parse(upcomingList.date!))
                                  .toString(),
                              style: Poppins.semiBold(AppColors.mako).s12,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
                            text: upcomingList.timeFrom != null
                                ? '${parseDatetimeFromUtc(isoFormattedString: '${DateFormat('yyyy-MM-dd').format(DateTime.parse(upcomingList.date!))}T${upcomingList.timeFrom}')}  • ${parseDatetimeFromUtc(isoFormattedString: '${DateFormat('yyyy-MM-dd').format(DateTime.parse(upcomingList.date!))}T${upcomingList.timeTo}')}'
                                : 'any'.tr(),
                            style: Poppins.semiBold(AppColors.mako).s12,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      type
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RatingBarIndicator(
                                rating: upcomingList.assignments!.isNotEmpty
                                    ? double.parse(
                                        ratingCount(upcomingList.assignments!)
                                            .toStringAsFixed(2))
                                    : 0,
                                itemBuilder: (context, index) =>
                                    SvgPicture.asset(
                                  'assets/icon/rate-on.svg',
                                  width: 29.12,
                                  height: 29.18,
                                ),
                                itemCount: 5,
                                itemPadding: const EdgeInsets.only(right: 4),
                                itemSize: 12.27,
                                unratedColor: AppColors.mako.withOpacity(0.10),
                                direction: Axis.horizontal,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.15),
                                  padding: const EdgeInsets.only(
                                      right: 8, left: 8, top: 2, bottom: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: upcomingList.assignments![0].state ==
                                            'accepted'
                                        ? AppColors.corn.withOpacity(0.10)
                                        : upcomingList.assignments![0].state ==
                                                'rejected'
                                            ? Colors.red.withOpacity(0.10)
                                            : AppColors.mantis
                                                .withOpacity(0.10),
                                  ),
                                  child: CommonText(
                                    text: capitalize(
                                        upcomingList.assignments![0].state),
                                    style: Poppins.medium(upcomingList
                                                    .assignments![0].state ==
                                                'accepted'
                                            ? AppColors.corn
                                            : AppColors.fern)
                                        .s12,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 38,
                                  width: 38,
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: 28,
                                          width: 28,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: AppColors.mako
                                                .withOpacity(0.05),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/icon/chat.svg',
                                              width: 15.51,
                                              height: 15.56,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                              color: AppColors.bittersweet,
                                              shape: BoxShape.circle),
                                          child: CommonText(
                                            text: '0',
                                            style: Poppins.bold(AppColors.white)
                                                .s10,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ratingCount(List<dynamic> data) {
    double sumRating = 0;

    for (var item in data) {
      sumRating += item.rating != 'null' ? double.parse(item.rating!) : 0.0;
    }

    return (sumRating / data.length);
  }

  parseDatetimeFromUtc({required String isoFormattedString}) {
    var dateTime = DateTime.parse(isoFormattedString);
    print(isoFormattedString);
    print(dateTime.toLocal());
    var data =
        dateTime.toLocal().toString().split(' ')[1].toString().split(':');

    return '${data[0]}:${data[1]}';
  }

  String capitalize(String value) {
    if (value != '') {
      var result = value[0].toUpperCase();
      bool cap = true;
      for (int i = 1; i < value.length; i++) {
        if (value[i - 1] == " " && cap == true) {
          result = result + value[i].toUpperCase();
        } else {
          result = result + value[i];
          cap = false;
        }
      }
      return result;
    }
    return '';
  }
}
