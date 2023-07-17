import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../Utils/commanWidget/network_image.dart';

class LatestNewsWidget extends StatelessWidget {
  const LatestNewsWidget({
    Key? key,
    required this.scroll,
    required this.newsData,
    required this.click,
  }) : super(key: key);
  final bool scroll;
  final List<dynamic> newsData;
  final Function(int? index) click;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: newsData.isNotEmpty
          ? ListView.builder(
              padding: EdgeInsets.zero,
              physics: scroll
                  ? const NeverScrollableScrollPhysics()
                  : const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: newsData.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    click(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            height: 170,
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              color: AppColors.madison,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: MyNetworkImage(
                              url: newsData[index].image,
                              isCircular: false,
                            )
                            // Image.network(
                            //       newsData[index].image,
                            //       fit: BoxFit.fill,
                            //     ),
                            ),
                        CommonText(
                            text: newsData[index].title,
                            // 'Educação rodoviária e inclusão social na Feira da Comunicação e Criatividade',
                            style: Poppins.semiBold(AppColors.mako).s14,
                            maxLines: 3,
                            textAlign: TextAlign.start),
                        CommonText(
                            text:
                                '${newsData[index].time.split('-')[2] + '.' + newsData[index].time.split('-')[1] + '.' + newsData[index].time.split('-')[0]} ${newsData[index].subject}',
                            style: Poppins.regular(AppColors.baliHai).s13,
                            maxLines: 3,
                            textAlign: TextAlign.start),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: CommonText(
                  text: 'errorMessage.not_data'.tr(),
                  style: Poppins.bold(AppColors.bittersweet).s18,
                  maxLines: 2,
                  textAlign: TextAlign.center),
            ),
    );
  }
}
