import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/authScreens/login/widgets/social_button.dart';
import 'package:ajuda/Ui/authScreens/on_boarding/on_boarding_screen.dart';
import 'package:ajuda/Ui/bottombarScreen/HomeMainScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../data/local/shared_pref_helper.dart';
import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/commonButtons.dart';
import '../../Utils/commanWidget/textform_field.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../../Utils/view_model.dart';
import '../auth_view_model.dart';
import '../forgot_password/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String route = "LoginScreen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  initState() {
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.onLoginSuccess = () {
      if (provider.userModel!.volunteer != null) {
        SharedPrefHelper.userType = '2';
      } else {
        SharedPrefHelper.userType = '1';
      }
      // viewModel.updateFcm();
      Navigator.pushNamedAndRemoveUntil(
          context, HomeMainScreen.route, (route) => false);
    };
    withViewModel<AuthViewModel>(context, (viewModel) {
      viewModel.setNullValue = null;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 88, right: 25, left: 25, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*welcomeBack*/
            CommonText(
              text: 'login.welcomeBack'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.bold(AppColors.madison).s27,
              maxLines: 1,
            ),

            /*email*/
            Padding(
              padding: const EdgeInsets.only(top: 35.0, bottom: 5.0),
              child: CommonText(
                text: 'login.email'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
              ),
            ),
            TextFormField_Common(
              contentPadding: 16,
              textStyle: Poppins.semiBold(AppColors.mako).s15,
              onChanged: (String? value) {
                context.read<AuthViewModel>().validateEmail(value);

                context.read<AuthViewModel>().emailField = value;
              },
              errorText: context.select<AuthViewModel, String?>(
                (AuthViewModel state) => state.emailError,
              ),
              hintText: 'login.email'.tr(),
              textInputType: TextInputType.emailAddress,
              maxLines: 1,
              obscureText: false,
              textEditingController: provider.emailController,
              textColor: AppColors.mako,
              textStyleHint:
                  Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
            ),

            /*password*/
            Padding(
              padding: const EdgeInsets.only(top: 22.0, bottom: 5.0),
              child: CommonText(
                text: 'login.password'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
              ),
            ),
            TextFormField_Common(
              suffixIcon: InkWell(
                child: provider.passwordVisible
                    ? const Icon(
                        Icons.visibility_off,
                        color: AppColors.mako,
                      )
                    : const Icon(
                        Icons.visibility,
                        color: AppColors.mako,
                      ),
                onTap: () {
                  provider.updateVisible(true, !provider.passwordVisible);
                },
              ),
              textEditingController: provider.passController,
              contentPadding: 16,
              textStyle: Poppins.semiBold(AppColors.mako).s15,
              onChanged: (String? value) {
                context.read<AuthViewModel>().validatePassword(value);

                context.read<AuthViewModel>().password = value;
              },
              errorText: context.select<AuthViewModel, String?>(
                (AuthViewModel state) => state.passwordError,
              ),
              hintText: '••••••••',
              textInputType: TextInputType.visiblePassword,
              maxLines: 1,
              obscureText: provider.passwordVisible,
              textColor: AppColors.mako,
              textStyleHint:
                  Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 35.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, ForgotPassword.route),
                  child: Text(
                    'login.forgotPassword'.tr(),
                    textAlign: TextAlign.start,
                    style: Poppins.semiBoldUnderLine(AppColors.madison).s13,
                  ),
                ),
              ),
            ),

            /*social media*/
           /* SocialButton(
              onTap: () {},
              backgroundColor: AppColors.trans,
              borderColor: AppColors.mako.withOpacity(0.3),
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/apple.svg',
                  ),
                  SizedBox(
                    width: size.width * 0.10,
                  ),
                  CommonText(
                      text: 'login.apple'.tr(),
                      style: Poppins.semiBold(AppColors.mako).s13,
                      maxLines: 1,
                      textAlign: TextAlign.center)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
              child: SocialButton(
                onTap: () {},
                backgroundColor: AppColors.trans,
                borderColor: AppColors.mako.withOpacity(0.3),
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/images/google.svg',
                    ),
                    SizedBox(
                      width: size.width * 0.10,
                    ),
                    CommonText(
                        text: 'login.google'.tr(),
                        style: Poppins.semiBold(AppColors.mako).s13,
                        maxLines: 1,
                        textAlign: TextAlign.center)
                  ],
                ),
              ),
            ),
            SocialButton(
              onTap: () => {},
              backgroundColor: AppColors.trans,
              borderColor: AppColors.mako.withOpacity(0.3),
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/facebook.svg',
                  ),
                  SizedBox(
                    width: size.width * 0.10,
                  ),
                  CommonText(
                      text: 'login.facebook'.tr(),
                      style: Poppins.semiBold(AppColors.mako).s13,
                      maxLines: 1,
                      textAlign: TextAlign.center)
                ],
              ),
            ),*/
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 41.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonButtonLoading<AuthViewModel>(
                    backgroundColor: AppColors.madison,
                    borderColor: AppColors.mako.withOpacity(0.3),
                    text: 'login.login'.tr(),
                    style: Poppins.bold(AppColors.white).s14,
                    onPressed: () {
                      provider.loginUser();
                    },
                    borderRadius: 27.0,
                    minimumSize: 154.0,
                  ),
                ],
              ),
            ),

            /*don't have account*/
            Align(
              alignment: Alignment.topCenter,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, OnBoardingScreen.route),
                child: Text(
                  'login.dontHaveAnAccountSignUp'.tr(),
                  textAlign: TextAlign.start,
                  style: Poppins.semiBoldUnderLine(AppColors.madison).s13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
