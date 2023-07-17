import 'package:ajuda/Ui/Utils/app-constent.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/Ui/authScreens/auth_view_model.dart';
import 'package:ajuda/Ui/authScreens/login/login_screen.dart';
import 'package:ajuda/Ui/authScreens/signup/with_us_screen.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../my_app.dart';
import '../../Utils/alert.dart';
import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/commonButtons.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/commanWidget/textform_field.dart';
import '../../Utils/font_style.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  static const String route = "SignUpScreen";

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  initState() {
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.setNullValue = null;
    provider.onRegisteredSuccess = () {
      Alert.showSnackBarSuccess(
          navigatorKey.currentContext!, provider.snackBarText!);
      Navigator.pushNamed(context, WithUsScreen.route);
      // Navigator.pushNamed(context, WelcomeScreen.route);
      // successToast(provider.snackBarText!);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // FiledDecorationData filedDecorationData = const FiledDecorationData(
    //     backgroundColor: AppColors.white, textColor: AppColors.grey);
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(left: 25, right: 25, top: 88, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*become A Member*/
            CommonText(
              text: SharedPrefHelper.userType == '1'
                  ? 'login.becomeAMember'.tr()
                  : 'login.becomeAVolunteer'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.bold(AppColors.madison).s27,
              maxLines: 3,
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
              textEditingController: provider.emailController,
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
              textEditingController: provider.passController,
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
              contentPadding: 16,
              textStyle: Poppins.semiBold(AppColors.mako).s15,
              onChanged: (String? value) {
                context.read<AuthViewModel>().password = value;

                context.read<AuthViewModel>().validatePassword(value);
                context
                    .read<AuthViewModel>()
                    .validateConformPassword(provider.confirmPassword);
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

            /*confirm password*/
            Padding(
              padding: const EdgeInsets.only(top: 22.0, bottom: 5.0),
              child: CommonText(
                text: 'login.confirmPassword'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
              ),
            ),
            TextFormField_Common(
              suffixIcon: InkWell(
                child: provider.confirmVisible
                    ? const Icon(
                        Icons.visibility_off,
                        color: AppColors.mako,
                      )
                    : const Icon(
                        Icons.visibility,
                        color: AppColors.mako,
                      ),
                onTap: () {
                  provider.updateVisible(false, !provider.confirmVisible);
                },
              ),
              contentPadding: 16,
              textStyle: Poppins.semiBold(AppColors.mako).s15,
              onChanged: (String? value) {
                context.read<AuthViewModel>().validateConformPassword(value);

                context.read<AuthViewModel>().confirmPassword = value;
              },
              errorText: context.select<AuthViewModel, String?>(
                (AuthViewModel state) => state.confirmPasswordError,
              ),
              hintText: '••••••••',
              textInputType: TextInputType.visiblePassword,
              maxLines: 1,
              obscureText: provider.confirmVisible,
              textEditingController: provider.conformController,
              textColor: AppColors.mako,
              textStyleHint:
                  Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
            ),
            const SizedBox(
              height: 36,
            ),

            /*readAndAgree*/
            GestureDetector(
              onTap: () {
                provider.RGPD = !provider.RGPD;
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(provider.RGPD
                      ? 'assets/icon/checkbox-on.svg'
                      : "assets/icon/checkbox-off.svg"),
                  const SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'login.readAndAgree'.tr(),
                        style: Poppins.medium(AppColors.mako).s14,
                        children: [
                          TextSpan(
                              text: ' ',
                              style: Poppins.semiBold(AppColors.bittersweet).s14),
                          TextSpan(
                            
                              text: 'profile.privacyPolicy'.tr(),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => provider.urlLaunchThroughLink(privacy),
                              style: Poppins.semiBold(AppColors.bittersweet).s14)
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.15,
            ),

            /*signUp*/
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonButtonLoading<AuthViewModel>(
                    backgroundColor: AppColors.madison,
                    borderColor: AppColors.mako.withOpacity(0.3),
                    text: 'login.signUp'.tr(),
                    style: Poppins.bold(AppColors.white).s14,
                    onPressed: () {
                      provider.registerUser();
                    },
                    borderRadius: 27.0,
                    minimumSize: 154.0,
                  ),
                ],
              ),
            ),

            /*already Account*/
            Align(
              alignment: Alignment.topCenter,
              child: TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.route, (route) => false),
                child: Text(
                  'login.alreadyAccount'.tr(),
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
