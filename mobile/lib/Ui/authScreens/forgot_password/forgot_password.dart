import 'package:ajuda/Ui/Utils/commanWidget/CommonBackButton.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/Ui/authScreens/forgot_password/conform_email.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/commonButtons.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/commanWidget/textform_field.dart';
import '../../Utils/font_style.dart';
import '../auth_view_model.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);
  static const String route = "ForgotPassword";

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  initState() {
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.setNullValue = null;
    provider.onForgotSuccess = () {
      Navigator.pushNamed(context, ConformEmail.route);
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
        padding: const EdgeInsets.only(left: 25, right: 25, top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 18.0, bottom: 26),
              child: CommonBackButton(),
            ),
            CommonText(
              text: 'login.enterTheEmailAddress'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.bold(AppColors.madison).s24,
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
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonButtonLoading<AuthViewModel>(
                  backgroundColor: AppColors.madison,
                  borderColor: AppColors.mako.withOpacity(0.3),
                  text: 'login.sendEmail'.tr(),
                  style: Poppins.bold(AppColors.white).s14,
                  onPressed: () {
                    provider.forgotCall(null);
                  },
                  borderRadius: 27.0,
                  minimumSize: 190.0,
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
