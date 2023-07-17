import 'package:ajuda/Ui/authScreens/login/login_screen.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/commonButtons.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../auth_view_model.dart';

class ConformEmail extends StatefulWidget {
  const ConformEmail({Key? key}) : super(key: key);
  static const String route = "ConformEmail";

  @override
  State<ConformEmail> createState() => _ConformEmailState();
}

class _ConformEmailState extends State<ConformEmail> {
  @override
  initState() {
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.setNullValue = null;
    provider.onForgotSuccess = () {
      // Navigator.pushNamed(context, ForgotSuccess.route);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(left: 25, right: 25, top: 50.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*close*/
            InkWell(
              child: SvgPicture.asset(
                'assets/icon/close.svg',
                height: 14.01,
                width: 14.0,
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),

            /*text*/
            Padding(
              padding: const EdgeInsets.only(top: 32.99, bottom: 49.0),
              child: CommonText(
                text: 'forgot.checkYourEmail'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.madison).s27,
                maxLines: 3,
              ),
            ),

            /*image*/
            SvgPicture.asset(
              width: 311.0,
              height: 221.91,
              'assets/images/password.svg',
            ),

            /*text*/
            Padding(
              padding: const EdgeInsets.only(top: 48.82, bottom: 78.0),
              child: RichText(
                text: TextSpan(
                  text: 'forgot.weHaveSent'.tr(),
                  style: Poppins.medium(AppColors.baliHai).s15,
                  children: [
                    TextSpan(
                      text: SharedPrefHelper.email,
                      recognizer: TapGestureRecognizer()..onTap = () {},
                      style: Poppins.semiBold(AppColors.madison).s15,
                    ),
                    TextSpan(
                      text: 'forgot.recoverYourPassword'.tr(),
                      style: Poppins.medium(AppColors.baliHai).s15,
                    ),
                  ],
                ),
                maxLines: 5,
                overflow: TextOverflow.visible,
              ),
            ),

            /*ok*/
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonButtonLoading<AuthViewModel>(
                  backgroundColor: AppColors.bittersweet,
                  borderColor: AppColors.bittersweet,
                  text: 'forgot.ok'.tr(),
                  style: Poppins.semiBold(AppColors.white).s15,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.route, (route) => false);
                  },
                  borderRadius: 16.0,
                  minimumSize: 200.0,
                ),
              ],
            ),
            const SizedBox(
              height: 32.0,
            ),
            /*send it again*/
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonButtonLoading<AuthViewModel>(
                  backgroundColor: AppColors.trans,
                  borderColor: AppColors.bittersweet,
                  text: 'forgot.again'.tr(),
                  style: Poppins.semiBold(AppColors.bittersweet).s15,
                  onPressed: () {
                    provider.forgotCall(SharedPrefHelper.email);
                  },
                  borderRadius: 16.0,
                  minimumSize: 200.0,
                ),
              ],
            ),
            const SizedBox(
              height: 71.0,
            ),
          ],
        ),
      ),
    );
  }
}
