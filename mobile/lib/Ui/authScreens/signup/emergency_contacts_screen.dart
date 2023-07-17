import 'package:ajuda/Ui/Utils/alert.dart';
import 'package:ajuda/Ui/authScreens/signup/widget/add_edit_Contact.dart';
import 'package:ajuda/Ui/bottombarScreen/HomeMainScreen.dart';
import 'package:ajuda/route_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../my_app.dart';
import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/CommonButton.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../auth_view_model.dart';

class EmergencyContactsScreen extends StatefulWidget {
  static const String route = "EmergencyContactsScreen";

  const EmergencyContactsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  initState() {
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.profileUpdate = () {
      changeIndex.value = 0;
      changeIndex.notifyListeners();
      Alert.showSnackBarSuccess(
          navigatorKey.currentContext!, provider.snackBarText!);
      Navigator.pushNamedAndRemoveUntil(
          context, HomeMainScreen.route, (route) => false);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*Residence Area*/
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 5.0),
              child: CommonText(
                text: 'login.emergencyContacts'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 1,
              ),
            ),

            /*add at least one contact*/
            CommonText(
              text: 'login.leastOneEmergencyContact'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.medium(AppColors.baliHai).s15,
              maxLines: 4,
            ),
            Expanded(
              child: provider.emergencyContactData.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        top: 17,
                      ),
                      itemCount: provider.emergencyContactData.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 17.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: AppColors.alabaster,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 20.0, top: 15, bottom: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/profile_colored.svg',
                                          height: 50,
                                          width: 50,
                                        ),
                                        const SizedBox(
                                          width: 12.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              CommonText(
                                                text: provider
                                                    .emergencyContactData[index]
                                                    .name!,
                                                textAlign: TextAlign.left,
                                                style: Poppins.semiBold(
                                                        AppColors.madison)
                                                    .s16,
                                                maxLines: 5,
                                              ),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/call.svg',
                                                    height: 14,
                                                    width: 9.74,
                                                  ),
                                                  const SizedBox(
                                                    width: 3,
                                                  ),
                                                  CommonText(
                                                    text: provider
                                                        .emergencyContactData[
                                                            index]
                                                        .mobileNumber!,
                                                    textAlign: TextAlign.left,
                                                    style: Poppins.regular(
                                                            AppColors.mako)
                                                        .s13,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    offset: const Offset(0, 75),
                                    icon: SvgPicture.asset(
                                      'assets/images/Combined Shape.svg',
                                      width: 5.8,
                                      height: 25,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                    ),
                                    itemBuilder: (_) => <PopupMenuEntry>[
                                      PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();

                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AddEditContact(
                                                  name: provider
                                                      .emergencyContactData[
                                                          index]
                                                      .name!,
                                                  number: provider
                                                      .emergencyContactData[
                                                          index]
                                                      .mobileNumber!,
                                                  add: (String name,
                                                      String number) {
                                                    provider.addNewContact(
                                                        name, number,
                                                        index: index);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          splashFactory: NoSplash.splashFactory,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 10.0, bottom: 30.0),
                                            alignment: Alignment.centerLeft,
                                            height: 55.0,
                                            padding: const EdgeInsets.only(
                                                left: 24.0),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: AppColors.fantasy,
                                            ),
                                            child: CommonText(
                                              text: 'login.editContact'.tr(),
                                              style: Poppins.semiBold(
                                                      AppColors.bittersweet)
                                                  .s16,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: InkWell(
                                          splashFactory: NoSplash.splashFactory,
                                          onTap: () {
                                            provider.removeContact(index, true);
                                          },
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 55.0,
                                            padding: const EdgeInsets.only(
                                                left: 24.0),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: AppColors.fantasy,
                                            ),
                                            child: CommonText(
                                              text: 'login.deleteContact'.tr(),
                                              style: Poppins.semiBold(
                                                      AppColors.bittersweet)
                                                  .s16,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          splashFactory: NoSplash.splashFactory,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: AppColors.trans,
                                            ),
                                            child: CommonText(
                                              text: 'login.cancel'.tr(),
                                              style: Poppins.semiBoldUnderLine(
                                                      AppColors.madison)
                                                  .s13,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SvgPicture.asset(
                          'assets/images/onBoarding/illustrations-4.svg',
                          width: 268.8,
                          height: 218.74,
                        ),
                      ),
                    ),
            ),

            /*add contact*/
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  provider.notEnterCheck
                      ? const SizedBox(
                          height: 48,
                        )
                      : CommonButton(
                          borderColor: AppColors.trans,
                          backgroundColor: AppColors.baliHai,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AddEditContact(
                                  add: (String name, String number) {
                                    provider.addNewContact(name, number);
                                  },
                                );
                              },
                            );
                          },
                          borderRadius: 8.0,
                          style: Poppins.bold(AppColors.madison).s14,
                          minimumSize: 172.0,
                          minimumWidget: 48,
                          child: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.add,
                                size: 25,
                                color: AppColors.white,
                              ),
                              const SizedBox(
                                width: 11,
                              ),
                              CommonText(
                                text: 'login.addContact'.tr(),
                                textAlign: TextAlign.left,
                                style: Poppins.semiBold(AppColors.white).s16,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),

            /*not Enter Check*/
            provider.emergencyContactData.isNotEmpty
                ? const SizedBox(
                    height: 28.0,
                  )
                : GestureDetector(
                    onTap: () {
                      provider.notEnterCheck = !provider.notEnterCheck;
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SvgPicture.asset(
                          provider.notEnterCheck
                              ? 'assets/icon/checkbox-on.svg'
                              : "assets/icon/checkbox-off.svg",
                          width: 26,
                          height: 26,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Expanded(
                          child: CommonText(
                            text: 'login.notEnterCheck'.tr(),
                            textAlign: TextAlign.left,
                            style:
                                Poppins.medium(AppColors.mako.withOpacity(0.8))
                                    .s14,
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

            /*back-next*/
            Padding(
              padding: const EdgeInsets.only(top: 46, bottom: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonButton(
                    buttonText: 'login.back'.tr(),
                    borderColor: AppColors.trans,
                    backgroundColor: AppColors.madison.withOpacity(0.08),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: 27.0,
                    style: Poppins.bold(AppColors.madison).s14,
                    minimumSize: 145.0,
                  ),
                  CommonButton(
                    buttonText: 'done'.tr(),
                    borderColor: AppColors.trans,
                    backgroundColor: provider.emergencyContactData.isNotEmpty ||
                            provider.notEnterCheck
                        ? AppColors.madison
                        : AppColors.madison.withOpacity(0.05),
                    onPressed: provider.emergencyContactData.isNotEmpty ||
                            provider.notEnterCheck
                        ? () {
                            provider.updateUserViaId(false);
                          }
                        : () {},
                    borderRadius: 27.0,
                    style: Poppins.bold(
                            provider.emergencyContactData.isNotEmpty ||
                                    provider.notEnterCheck
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
