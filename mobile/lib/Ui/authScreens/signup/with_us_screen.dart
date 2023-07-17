import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/signup/cover_photo_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/CommonButton.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/commanWidget/textform_field.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../auth_view_model.dart';

class WithUsScreen extends StatefulWidget {
  const WithUsScreen({Key? key}) : super(key: key);
  static const String route = "WithUsScreen";

  @override
  State<WithUsScreen> createState() => _WithUsScreenState();
}

class _WithUsScreenState extends State<WithUsScreen> {
  @override
  initState() {
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.onWithUsValidateSuccess = () {
      Navigator.pushNamed(context, CoverPhotoScreen.route);
    };
    withViewModel<AuthViewModel>(context, (viewModel) {
      viewModel.getDataForProfile(false);

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 55, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/onBoarding/illustrations-5.svg',
                        height: 194.63,
                        width: 268.8,
                      ),
                    ],
                  ),

                  /*you With Us*/
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 5.0),
                    child: CommonText(
                      text: 'login.youWithUs'.tr(),
                      textAlign: TextAlign.left,
                      style: Poppins.bold(AppColors.madison).s18,
                      maxLines: 2,
                    ),
                  ),

                  /*complete Your Profile*/
                  CommonText(
                    text: 'login.completeYourProfile'.tr(),
                    textAlign: TextAlign.left,
                    style: Poppins.medium(AppColors.baliHai).s15,
                    maxLines: 2,
                  ),
                  /*first Last Name*/
                  Padding(
                    padding: const EdgeInsets.only(top: 35.0, bottom: 5.0),
                    child: CommonText(
                      text: 'login.firstLastName'.tr(),
                      textAlign: TextAlign.left,
                      style: Poppins.medium(AppColors.baliHai).s12,
                      maxLines: 1,
                    ),
                  ),
                  TextFormField_Common(
                    contentPadding: 16,
                    textStyle: Poppins.semiBold(AppColors.mako).s15,
                    onChanged: (String? value) {
                      context.read<AuthViewModel>().validateName(value);
                      context.read<AuthViewModel>().username = value;
                    },
                    errorText: context.select<AuthViewModel, String?>(
                      (AuthViewModel state) => state.usernameError,
                    ),
                    hintText: 'login.firstLastName'.tr(),
                    textInputType: TextInputType.name,
                    maxLines: 1,
                    obscureText: false,
                    textColor: AppColors.mako,
                    textStyleHint:
                        Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
                  ),

                  /*mobile Phone*/
                  Padding(
                    padding: const EdgeInsets.only(top: 22.0, bottom: 5.0),
                    child: CommonText(
                      text: 'login.mobilePhone'.tr(),
                      textAlign: TextAlign.left,
                      style: Poppins.medium(AppColors.baliHai).s12,
                      maxLines: 1,
                    ),
                  ),
                  TextFormField_Number(
                    maxLines: 1,
                    contentPadding: 16,
                    textStyle: Poppins.semiBold(AppColors.mako).s15,
                    textInputType: const TextInputType.numberWithOptions(
                        signed: false, decimal: false),
                    errorText: context.select<AuthViewModel, String?>(
                      (AuthViewModel state) => state.phoneNumberError,
                    ),
                    onChanged: (String? value) {
                      context.read<AuthViewModel>().validateNumber(value);
                      context.read<AuthViewModel>().phoneNumber = value;
                    },
                    hintText: '000-000-000',
                    obscureText: false,
                    textColor: AppColors.mako,
                    textStyleHint:
                        Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
                  ),

                  /*Date Of Birth*/
                  Padding(
                    padding: const EdgeInsets.only(top: 22.0, bottom: 5.0),
                    child: CommonText(
                      text: 'login.dateOfBirth'.tr(),
                      textAlign: TextAlign.left,
                      style: Poppins.medium(AppColors.baliHai).s12,
                      maxLines: 1,
                    ),
                  ),
                  TextFormField_Common(
                    contentPadding: 16,
                    textEditingController: provider.dobController,
                    textStyle: Poppins.semiBold(AppColors.mako).s15,
                    onChanged: (String? value) {},
                    errorText: context.select<AuthViewModel, String?>(
                      (AuthViewModel state) => state.dobError,
                    ),
                    onTap: () {
                      provider.selectDate();
                    },
                    readOnly: true,
                    hintText: '00-00-0000',
                    textInputType: TextInputType.visiblePassword,
                    maxLines: 1,
                    obscureText: false,
                    textColor: AppColors.mako,
                    textStyleHint:
                        Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down_sharp,
                      color: AppColors.mako,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),

            /*next*/
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CommonButton(
                    buttonText: 'login.next'.tr(),
                    borderColor: provider.username != null &&
                            provider.username!.isNotEmpty &&
                            provider.phoneNumber != null &&
                            provider.phoneNumber!.isNotEmpty &&
                            provider.dobController!.text.isNotEmpty
                        ? AppColors.madison
                        : AppColors.trans,
                    backgroundColor: provider.username != null &&
                            provider.username!.isNotEmpty &&
                            provider.phoneNumber != null &&
                            provider.phoneNumber!.isNotEmpty &&
                            provider.dobController!.text.isNotEmpty
                        ? AppColors.madison
                        : AppColors.madison.withOpacity(0.08),
                    onPressed: () {
                      provider.validateWithUsScreen();
                    },
                    borderRadius: 27.0,
                    style: Poppins.bold(provider.username != null &&
                                provider.username!.isNotEmpty &&
                                provider.phoneNumber != null &&
                                provider.phoneNumber!.isNotEmpty &&
                                provider.dobController!.text.isNotEmpty
                            ? AppColors.white
                            : AppColors.madison)
                        .s14,
                    minimumSize: 145.0,
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
