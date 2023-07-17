import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/widget/latest_news_widget.dart';
import 'package:ajuda/Ui/mainScreens/NewsUi/newsViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/theme/appcolor.dart';
import 'newsDetailsScreen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    withViewModel<NewsViewModel>(context, (viewModel) {
      viewModel.tabIndex = 0;
      viewModel.newsData.clear();
      viewModel.getNewsTabData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<NewsViewModel>();
    return BaseScreen<NewsViewModel>(
      color: AppColors.porcelain,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 65, right: 22, left: 22, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 25,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.tabData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 28.0),
                    child: InkWell(
                      onTap: () {
                        provider.tabIndex = index;
                        provider.getListData(provider.tabData[index]);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CommonText(
                              text:
                                  provider.capitalize(provider.tabData[index]),
                              style: provider.tabIndex == index
                                  ? Poppins.boldUnderLine(AppColors.bittersweet)
                                      .s15
                                  : Poppins.regular(
                                          AppColors.mako.withOpacity(0.40))
                                      .s13,
                              maxLines: 1,
                              textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            Expanded(
              child: LatestNewsWidget(
                click: (int? index) {
                  provider.selectIndex = index!;
                  print(provider.newsData[provider.selectIndex].articleUrl);
                  Navigator.pushNamed(context, NewsDetailsScreen.route);
                },
                scroll: false,
                newsData: provider.newsData,
              ),
            )
          ],
        ),
      ),
    );
  }
}
