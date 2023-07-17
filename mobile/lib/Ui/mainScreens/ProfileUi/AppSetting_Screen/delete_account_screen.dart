import 'package:ajuda/Ui/Utils/commanWidget/CommonButton.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/profileViewModel.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/widget/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';

class AccountDeleteScreen extends StatefulWidget {
  static const String route = "AccountDeleteScreen";

  const AccountDeleteScreen({Key? key}) : super(key: key);

  @override
  State<AccountDeleteScreen> createState() => _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends State<AccountDeleteScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<ProfileViewModel>();
    return BaseScreen<ProfileViewModel>(
      color: AppColors.porcelain,
      appBar: const CommonAppBar(
        title: '',
        color: AppColors.porcelain,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 44, right: 25, left: 25, bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: const <Widget>[
            //     BackButton(),
            //   ],
            // ),
            const SizedBox(
              height: 19.5,
            ),
            SvgPicture.asset(
              width: 268.8,
              height: 174.97,
              'assets/images/onBoarding/illustrations-8.svg',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: CommonText(
                text: "profile.deleteAccount".tr(),
                textAlign: TextAlign.center,
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 2,
              ),
            ),
            CommonText(
              text: "profile.deleteAccountContent".tr(),
              textAlign: TextAlign.center,
              style: Poppins.medium(AppColors.baliHai).s15,
              maxLines: 5,
            ),
            const SizedBox(
              height: 118.0,
            ),
            CommonButton(
              borderColor: AppColors.bittersweet,
              backgroundColor: AppColors.bittersweet,
              onPressed: () {
                provider.deleteUserAccount();
              },
              borderRadius: 16.0,
              style: Poppins.semiBold(AppColors.white).s15,
              minimumSize: 200,
              minimumWidget: 47,
              buttonText: 'profile.delete'.tr(),
            ),
            const SizedBox(
              height: 21,
            ),
            CommonButton(
              borderColor: AppColors.madison,
              backgroundColor: AppColors.trans,
              onPressed: () {
                Navigator.of(context).pop();
              },
              borderRadius: 16.0,
              style: Poppins.bold(AppColors.madison).s16,
              minimumSize: 200,
              minimumWidget: 47,
              buttonText: 'profile.changeMind'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
