import 'package:ajuda/Ui/authScreens/on_boarding/on_boarding_view_model.dart';
import 'package:ajuda/Ui/authScreens/on_boarding/widgets/dot_view.dart';
import 'package:ajuda/Ui/authScreens/signup/sign_up_screen.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../Utils/commanWidget/CommonButton.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String route = 'onBoardingScreen';

  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentIndex = 0;
  PageController? _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<OnBoardingViewModel>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: provider.infoList.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 55.0, bottom: 25.0),
                      child: CommonText(
                        text: provider.infoList[i].title.tr(),
                        textAlign: TextAlign.left,
                        style: Poppins.bold(AppColors.madison).s27,
                        maxLines: 2,
                      ),
                    ),
                    SvgPicture.asset(
                      width: 314.0,
                      height: 233.11,
                      provider.infoList[i].imagePath,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 16.0),
                      child: CommonText(
                        text: provider.infoList[i].subtitle.tr(),
                        textAlign: TextAlign.left,
                        style: Poppins.semiBold(AppColors.madison).s18,
                        maxLines: 2,
                      ),
                    ),
                    CommonText(
                      text: provider.infoList[i].description.tr(),
                      textAlign: TextAlign.left,
                      style: Poppins.medium(AppColors.baliHai).s15,
                      maxLines: 10,
                    ),
                  ],
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DotView(
                    currentIndex: currentIndex,
                    allInfo: provider.infoList,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: CommonButton(
                            buttonText: 'onBoarding.wantToHelp'.tr(),
                            borderColor:
                                currentIndex + 1 == provider.infoList.length
                                    ? AppColors.madison
                                    : AppColors.trans,
                            backgroundColor:
                                currentIndex + 1 == provider.infoList.length
                                    ? AppColors.madison
                                    : AppColors.madison.withOpacity(0.08),
                            onPressed:
                                currentIndex + 1 == provider.infoList.length
                                    ? () {
                                        SharedPrefHelper.userType = '2';

                                        Navigator.pushNamed(
                                            context, SignUpScreen.route);
                                      }
                                    : null,
                            borderRadius: 27,
                            style: Poppins.bold(
                                    currentIndex + 1 == provider.infoList.length
                                        ? AppColors.white
                                        : AppColors.madison)
                                .s14,
                            minimumSize: 145.0,
                          ),
                        ),
                        const SizedBox(width: 18,),
                        Flexible(
                          flex: 1,
                          child: CommonButton(
                            buttonText: 'onBoarding.lookingForHelp'.tr(),
                            borderColor:
                                currentIndex + 1 == provider.infoList.length
                                    ? AppColors.madison
                                    : AppColors.trans,
                            backgroundColor:
                                currentIndex + 1 == provider.infoList.length
                                    ? AppColors.madison
                                    : AppColors.madison.withOpacity(0.08),
                            onPressed:
                                currentIndex + 1 == provider.infoList.length
                                    ? () {
                                        SharedPrefHelper.userType = '1';
                                        Navigator.pushNamed(
                                          context,
                                          SignUpScreen.route,
                                        );
                                      }
                                    : null,
                            borderRadius: 27.0,
                            style: Poppins.bold(
                                    currentIndex + 1 == provider.infoList.length
                                        ? AppColors.white
                                        : AppColors.madison)
                                .s14,
                            minimumSize: 145.0,

                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 15.0),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'onBoarding.backToLogin'.tr(),
                        textAlign: TextAlign.start,
                        style: Poppins.semiBoldUnderLine(AppColors.madison).s13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
