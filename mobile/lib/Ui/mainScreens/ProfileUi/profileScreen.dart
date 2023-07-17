import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/login/login_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AboutUs_Sreen/about_us_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AppSetting_Screen/app_setting_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/EditProfile_Screen/edit_profile_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/HelpContact_Screen/help_contacts_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/History_Screen/history_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/widget/profile_option_widget.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/network_image.dart';
import '../../Utils/theme/appcolor.dart';
import '../../authScreens/auth_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    withViewModel<AuthViewModel>(context, (viewModel) {
      viewModel.getUserData();
      viewModel.getDataForProfile(true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthViewModel>();

    return BaseScreen<AuthViewModel>(
      color: AppColors.porcelain,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 45, right: 25, left: 25, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
           /* Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.bittersweet.withOpacity(0.20), width: 9),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bittersweet, width: 3),
                ),
                child: provider.userModel != null
                    ? provider.userModel!.image != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              provider.userModel!.image!,
                            ),
                            radius: 50,
                          )
                        : const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/icon/profile_colored.svg'),
                            radius: 50,
                          )
                    : const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/icon/profile_colored.svg'),
                        radius: 50,
                      ),
              ),
            ),*/
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.bittersweet.withOpacity(0.20), width: 9),
              ),
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bittersweet, width: 3),
                  ),
                  child: SizedBox(
                    height: 110,
                    width: 110,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80.0),
                      child: MyNetworkImage.circular(
                          url: provider.userModel!.image ?? ''),
                    ),
                  ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 3.0),
              child: CommonText(
                text: provider.userModel != null
                    ? provider.userModel!.name ?? 'login.pleaseWait'.tr()
                    : 'login.pleaseWait'.tr(),
                style: Poppins.bold(AppColors.mako).s18,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            CommonText(
              text: provider.userModel != null &&
                      provider.userModel!.email != null
                  ? provider.userModel!.email!
                  : 'login.pleaseWait'.tr(),
              style: Poppins.medium(AppColors.mako.withOpacity(0.50)).s14,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 41.25,
            ),
            ProfileOptionWidget(
              text: 'profile.editProfile'.tr(),
              icon: 'assets/icon/profile.svg',
              onTap: () {
                Navigator.pushNamed(context, EditProfileScreen.route);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: ProfileOptionWidget(
                text: 'profile.appSettings'.tr(),
                icon: 'assets/icon/settings.svg',
                onTap: () {
                  Navigator.pushNamed(context, AppSettingScreen.route);
                },
              ),
            ),
            ProfileOptionWidget(
              text: 'profile.myHistory'.tr(),
              icon: 'assets/icon/history.svg',
              onTap: () {
                Navigator.pushNamed(context, HistoryScreen.route);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: ProfileOptionWidget(
                text: 'profile.helpContacts'.tr(),
                icon: 'assets/icon/contacts.svg',
                onTap: () {
                  Navigator.pushNamed(context, HelpContactsScreen.route);
                },
              ),
            ),
            ProfileOptionWidget(
              text: 'profile.aboutUs'.tr(),
              icon: 'assets/icon/about.svg',
              height: 30,
              left: 20,
              width: 30,
              right: 12,
              onTap: () {
                Navigator.pushNamed(context, AboutUsScreen.route);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: ProfileOptionWidget(
                text: 'profile.logout'.tr(),
                icon: 'assets/icon/logout.svg',
                left: 28,
                onTap: () {
                  SharedPrefHelper.userId = null;
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.route, (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
