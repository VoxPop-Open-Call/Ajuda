import 'package:ajuda/Ui/Utils/base_screen.dart';
import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AppSetting_Screen/delete_account_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AppSetting_Screen/language_screen/language.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AppSetting_Screen/widget/app_setting_widget.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/profileViewModel.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/widget/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Utils/app-constent.dart';
import '../../../Utils/font_style.dart';

class AppSettingScreen extends StatefulWidget {
  static const String route = "AppSettingScreen";

  const AppSettingScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingScreen> createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<ProfileViewModel>();
    return BaseScreen<ProfileViewModel>(
      appBar: CommonAppBar(
        title: 'profile.appSettings'.tr(),
        color: AppColors.porcelain,
      ),
      color: AppColors.porcelain,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 44, right: 37, left: 25, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CommonText(
                  text: 'profile.settings'.tr(),
                  style: Poppins.semiBold(AppColors.mako).s16,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 44.0, bottom: 24.0),
              child: AppSettingWidget(
                tap: () {
                  Navigator.pushNamed(context, LanguageScreen.route);
                },
                title: 'profile.language'.tr(),
              ),
            ),
            AppSettingWidget(
              show: 1,
              option: provider.showNotification,
              tap: () {
                provider.showNotification = !provider.showNotification;
              },
              title: 'profile.notifications'.tr(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0, bottom: 34.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CommonText(
                    text: 'profile.account'.tr(),
                    style: Poppins.semiBold(AppColors.mako).s16,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            /*  AppSettingWidget(
              tap: () {},
              title: 'profile.gdpr'.tr(),
            ),*/
            Padding(
              padding: const EdgeInsets.only(/*top: 24.0,*/ bottom: 24.0),
              child: AppSettingWidget(
                tap: () {
                  provider.urlLaunchThroughLink(url: privacy);
                },
                title: 'profile.privacyPolicy'.tr(),
              ),
            ),
            AppSettingWidget(
              tap: () {
                provider.urlLaunchThroughLink(url: termsAndCondition);
              },
              title: 'profile.termsAndConditions'.tr(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
              child: AppSettingWidget(
                tap: () {
                  Navigator.pushNamed(context, AccountDeleteScreen.route);
                },
                title: 'profile.deleteAccount'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
