import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/commanWidget/network_image.dart';

class VolunteersWidget extends StatelessWidget {
  final Function(int) tab;
  final bool scroll;
  final List<dynamic> volunteersList;

  const VolunteersWidget(
      {Key? key,
      required this.tab,
      required this.scroll,
      required this.volunteersList})
      : super(key: key);

  ratingCount(List<dynamic> data) {
    double sumRating = 0;

    for (var item in data) {
      sumRating += item.rating != 'null' ? double.parse(item.rating!) : 0.0;
    }

    return (sumRating / data.length);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics:
          scroll ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
      itemCount: volunteersList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.87),
          child: GestureDetector(
            onTap: () {
              tab(index);
            },
            child: Card(
              color: AppColors.alabaster,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(color: AppColors.alabaster),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, right: 10.0, top: 14.0, bottom: 14.0),
                    child: Container(
                      height: 72.0,
                      width: 72.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: MyNetworkImageOvel(
                        url: volunteersList[index].image ?? '',
                      ),
                    ),

                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(14.0),
                    //   child: volunteersList[index].image != null
                    //       ? Image.network(
                    //           volunteersList[index].image,
                    //           height: 72.0,
                    //           width: 72.0,
                    //           fit: BoxFit.cover,
                    //         )
                    //       : SvgPicture.asset(
                    //           'assets/icon/profile_colored.svg',
                    //           height: 72.0,
                    //           width: 72.0,
                    //         ),
                    // ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CommonText(
                            text: volunteersList[index].name,
                            style: Poppins.semiBold(AppColors.mako).s16,
                            maxLines: 1,
                            textAlign: TextAlign.start),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0, top: 2.0),
                          child: CommonText(
                              text: volunteersList[index].location != null
                                  ? volunteersList[index].location['address'] ==
                                          ''
                                      ? '-'
                                      : volunteersList[index]
                                          .location['address']
                                  : '-',
                              style: Poppins.regular(AppColors.mako).s13,
                              maxLines: 1,
                              textAlign: TextAlign.start),
                        ),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating:
                                  volunteersList[index].historyData != null &&
                                          volunteersList[index]
                                              .historyData!
                                              .isNotEmpty
                                      ? double.parse( ratingCount(
                                          volunteersList[index].historyData).toStringAsFixed(2)): 0,
                              itemBuilder: (context, index) => SvgPicture.asset(
                                'assets/icon/rate-on.svg',
                                width: 11.97,
                                height: 12,
                              ),
                              itemCount: 5,
                              itemPadding: const EdgeInsets.only(right: 4.0),
                              itemSize: 12.27,
                              unratedColor: AppColors.mako.withOpacity(0.10),
                              direction: Axis.horizontal,
                            ),
                            CommonText(
                                text:
                                    '(${volunteersList[index].historyData != null ? volunteersList[index].historyData.length : 0})',
                                style: Poppins.regular(
                                        AppColors.mako.withOpacity(0.50))
                                    .s10,
                                maxLines: 1,
                                textAlign: TextAlign.start),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 18.9),
                    child: SvgPicture.asset(
                      'assets/icon/arrow.svg',
                      width: 14,
                      height: 11.65,
                      // color: AppColors.mako,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
