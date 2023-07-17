import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/auth_view_model.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/homeViewModel.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/widget/homeOption.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/widget/latest_news_widget.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/widget/upcoming_services_volunteer_widget.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/widget/upcoming_services_widget.dart';
import 'package:ajuda/Ui/mainScreens/NewsUi/newsViewModel.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/NewRequestScreen/newRequestStepScreen.dart';
import 'package:ajuda/route_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../data/local/shared_pref_helper.dart';
import '../../Utils/base_screen.dart';
import '../NewsUi/newsDetailsScreen.dart';
import '../RequestUi/PendingRequestUi/pading_request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    withViewModel<HomeViewModel>(context, (viewModel) {
      viewModel.newsViewModel =
          Provider.of<NewsViewModel>(context, listen: false);
      viewModel.authViewModel =
          Provider.of<AuthViewModel>(context, listen: false);
      viewModel.getListData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeViewModel>();
    return BaseScreen<HomeViewModel>(
      color: AppColors.porcelain,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 65, right: 25, left: 25, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonText(
                text:
                    '${'home.hi'.tr()} ${provider.authViewModel != null ? provider.authViewModel!.userModel != null ? provider.authViewModel!.userModel!.name : 'login.pleaseWait'.tr() : 'login.pleaseWait'.tr()}!',
                style: Poppins.medium(AppColors.madison).s20,
                maxLines: 1,
                textAlign: TextAlign.left),
            CommonText(
                text: SharedPrefHelper.userType == '2'
                    ? 'home.readyToHelp'.tr()
                    : 'home.doYouNeedHelp'.tr(),
                style: Poppins.bold(AppColors.madison).s32,
                maxLines: 2,
                textAlign: TextAlign.left),
            if (SharedPrefHelper.userType == '1')
              GridView.builder(
                shrinkWrap: true,
                itemCount: provider.desiredServices.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0),
                itemBuilder: (BuildContext context, int index) {
                  return HomeOption(
                    image: provider.desiredServices[index].icon,
                    optionImage:'servicesNeeds.${provider.desiredServices[index].title}'.tr(),
                    // provider
                    //     .capitalize(provider.desiredServices[index].title),
                    onTap: () {
                      provider.addRequest =
                          provider.desiredServices[index].title;
                      Navigator.pushNamed(context, NewRequestStepScreen.route);
                    },
                  );
                },
              ),
            if (SharedPrefHelper.userType == '1')
              Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 30, bottom: 30),
                child: InkWell(
                  onTap: () {
                    provider.addRequest = 'other';
                    Navigator.pushNamed(context, NewRequestStepScreen.route);
                  },
                  splashFactory: NoSplash.splashFactory,
                  child: Stack(
                    children: <Widget>[
                      Image.asset('assets/images/make_request.png'),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 17.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CommonText(
                                  text: 'home.didFoundWhatYouNeed'.tr(),
                                  style: Poppins.semiBold(AppColors.white).s12,
                                  maxLines: 1,
                                  textAlign: TextAlign.left),
                              CommonText(
                                  text: 'home.makeYourRequestHere'.tr(),
                                  style: Poppins.bold(AppColors.white).s18,
                                  maxLines: 1,
                                  textAlign: TextAlign.left),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            if (SharedPrefHelper.userType == '2')
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, PendingRequestScreen.route);
                },
                splashFactory: NoSplash.splashFactory,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.pippin,
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  height: 64,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 30, bottom: 30),
                  padding: const EdgeInsets.only(left: 16, right: 21),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                height: 22,
                                width: 22,
                                decoration: const BoxDecoration(
                                    color: AppColors.bittersweet,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: CommonText(
                                    text: provider.pendingListData.length
                                        .toString(),
                                    style: Poppins.bold(AppColors.white).s12,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              CommonText(
                                  text: 'home.requests'.tr(),
                                  style: Poppins.bold(AppColors.mako).s15,
                                  maxLines: 1,
                                  textAlign: TextAlign.start),
                            ],
                          ),
                          CommonText(
                              text: 'home.youHave'.tr() +
                                  provider.pendingListData.length.toString() +
                                  'home.pendingRequests'.tr(),
                              style: Poppins.regular(
                                      AppColors.mako.withOpacity(0.70))
                                  .s12,
                              maxLines: 1,
                              textAlign: TextAlign.start),
                        ],
                      ),
                      SvgPicture.asset(
                        'assets/icon/arrow.svg',
                        width: 13.02,
                        height: 10.83,
                        color: AppColors.bittersweet,
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CommonText(
                    text: 'home.upcomingServices'.tr(),
                    style: Poppins.semiBold(AppColors.baliHai).s15,
                    maxLines: 1,
                    textAlign: TextAlign.start),
                InkWell(
                  onTap: () {
                    changeIndex.value = 1;
                    changeIndex.notifyListeners();
                  },
                  child: Row(
                    children: <Widget>[
                      CommonText(
                          text: 'home.seeAll'.tr(),
                          style: Poppins.regular(AppColors.bittersweet).s12,
                          maxLines: 1,
                          textAlign: TextAlign.start),
                      const SizedBox(
                        width: 6.76,
                      ),
                      SvgPicture.asset(
                        'assets/icon/arrow.svg',
                        height: 8,
                        width: 9.62,
                        color: AppColors.bittersweet,
                      )
                    ],
                  ),
                )
              ],
            ),
            provider.upcomingListData.isEmpty
                ? SizedBox(
                    height: 100,
                    child: Center(
                      child: CommonText(
                          text: 'errorMessage.not_data'.tr(),
                          style: Poppins.semiBold(AppColors.bittersweet).s15,
                          maxLines: 2,
                          textAlign: TextAlign.center),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.upcomingListData.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: SharedPrefHelper.userType == '1'
                              ? UpcomingServicesWidget(
                                  calender: false,
                                  type: false,
                                  upcomingList:
                                      provider.upcomingListData[index],
                                  tab: () {},
                                )
                              : UpcomingServicesVolunteerWidget(
                                  calender: false,
                                  type: false,
                                  upcomingList: provider
                                      .upcomingListData[index],
                                  tab: () {},
                                ),
                        );
                      },
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CommonText(
                    text: 'home.latestNews'.tr(),
                    style: Poppins.semiBold(AppColors.baliHai).s15,
                    maxLines: 1,
                    textAlign: TextAlign.start),
                InkWell(
                  onTap: () {
                    changeIndex.value =
                        SharedPrefHelper.userType == '1' ? 3 : 2;
                    changeIndex.notifyListeners();
                  },
                  child: Row(
                    children: <Widget>[
                      CommonText(
                          text: 'home.seeAll'.tr(),
                          style: Poppins.regular(AppColors.bittersweet).s12,
                          maxLines: 1,
                          textAlign: TextAlign.start),
                      const SizedBox(
                        width: 6.76,
                      ),
                      SvgPicture.asset(
                        'assets/icon/arrow.svg',
                        height: 8,
                        width: 9.62,
                        color: AppColors.bittersweet,
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: LatestNewsWidget(
                scroll: true,
                newsData: provider.newsViewModel != null
                    ? provider.newsViewModel!.newsData
                    : [],
                click: (int? index) {
                  provider.newsViewModel!.selectIndex = index!;
                  print(provider
                      .newsViewModel!
                      .newsData[provider.newsViewModel!.selectIndex]
                      .articleUrl);

                  Navigator.pushNamed(context, NewsDetailsScreen.route);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
