import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/profileViewModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/theme/appcolor.dart';
import '../widget/app_bar_widget.dart';

class AboutUsScreen extends StatefulWidget {
  static const String route = "AboutUsScreen";

  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<ProfileViewModel>();
    return BaseScreen<ProfileViewModel>(
      appBar: const CommonAppBar(
        title: '',
        color: AppColors.porcelain,
      ),
      color: AppColors.porcelain,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0, right: 25, left: 25, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icon/logo.svg',
                    width: 140, height: 79.99),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'about.about_text_1'.tr(),
                    style: Poppins.medium(AppColors.mako.withOpacity(0.80)).s15,
                  ),
                  TextSpan(
                    text: 'about.about_text_2'.tr(),
                    style: Poppins.bold(AppColors.bittersweet).s15,
                  ),
                  TextSpan(
                    text: 'about.about_text_3'.tr(),
                    style: Poppins.medium(AppColors.mako.withOpacity(0.80)).s15,
                  ),
                  TextSpan(
                    text: 'about.about_text_4'.tr(),
                    style: Poppins.bold(AppColors.bittersweet).s15,
                  ),
                  TextSpan(
                    text: 'about.about_text_5'.tr(),
                    style: Poppins.medium(AppColors.mako.withOpacity(0.80)).s15,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            CommonText(
                text: 'about.project'.tr(),
                style: Poppins.semiBold(AppColors.baliHai).s12,
                maxLines: 1,
                textAlign: TextAlign.center),
            Padding(
              padding: const EdgeInsets.only(top: 15.42, bottom: 40),
              child: SvgPicture.asset('assets/icon/logo-voxpop.svg'),
            ),
            CommonText(
                text: 'about.co_sponsored_by'.tr(),
                style: Poppins.semiBold(AppColors.baliHai).s12,
                maxLines: 1,
                textAlign: TextAlign.center),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.42, bottom: 40),
                  child: SvgPicture.asset('assets/icon/logo-cml.svg'),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 60, top: 15.42, bottom: 40),
                  child:
                      Image.asset('assets/icon/logo-uia-euasset.png',width: 148,height: 47.13,),
                ),
              ],
            ),
            CommonText(
                text: 'about.developed_by'.tr(),
                style: Poppins.semiBold(AppColors.baliHai).s12,
                maxLines: 1,
                textAlign: TextAlign.center),
            Padding(
              padding: const EdgeInsets.only(top: 15.42, bottom: 40),
              child: SvgPicture.asset('assets/icon/logo-mobinteg.svg'),
            ),
          ],
        ),
      ),
    );
  }
}
