import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/signup/availability_screen.dart';
import 'package:ajuda/Ui/authScreens/signup/emergency_contacts_screen.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/CommonButton.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../auth_view_model.dart';

class ServiceAndNeedScreen extends StatefulWidget {
  static const String route = "ServiceAndNeedScreen";

  const ServiceAndNeedScreen({Key? key}) : super(key: key);

  @override
  State<ServiceAndNeedScreen> createState() => _ServiceAndNeedScreenState();
}

class _ServiceAndNeedScreenState extends State<ServiceAndNeedScreen> {
  @override
  void initState() {
    withViewModel<AuthViewModel>(context, (viewModel) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                text: SharedPrefHelper.userType == '2'
                    ? 'login.howHelp'.tr()
                    : 'login.anyConditions'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 1,
              ),
            ),

            /*volunteers You Request*/
            CommonText(
              text: SharedPrefHelper.userType == '1'
                  ? 'login.optionsThatApply'.tr()
                  : 'login.whichServices'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.medium(AppColors.baliHai).s15,
              maxLines: 4,
            ),
            Expanded(
              child:
                  /*desiredServices*/
                  SharedPrefHelper.userType == '1'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*conditions*/
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 32.0, bottom: 5.0),
                              child: CommonText(
                                text: 'login.conditions'.tr(),
                                textAlign: TextAlign.left,
                                style: Poppins.bold(AppColors.mako).s16,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 9.0),
                              decoration: BoxDecoration(
                                color: AppColors.alabaster,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                    top: 17, right: 20, left: 20),
                                itemCount: provider.conditions.length,
                                // physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      provider.selectService(2, index);
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 17.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          CommonText(
                                            text:
                                                'servicesNeeds.${provider.conditions[index].title}'
                                                    .tr()
                                            // provider.conditions[index].title!,
                                            ,
                                            textAlign: TextAlign.left,
                                            style:
                                                Poppins.medium(AppColors.mako)
                                                    .s15,
                                            maxLines: 1,
                                          ),
                                          SvgPicture.asset(provider
                                                  .conditions[index].select
                                              ? 'assets/icon/checkbox-on.svg'
                                              : "assets/icon/checkbox-off.svg"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 32.0, bottom: 5.0),
                              child: CommonText(
                                text: 'volunteer.service'.tr(),
                                textAlign: TextAlign.left,
                                style: Poppins.bold(AppColors.mako).s16,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 0.0, bottom: 0),
                              decoration: BoxDecoration(
                                color: AppColors.alabaster,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                    top: 17, right: 20, left: 20),
                                itemCount: provider.desiredServices.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      provider.selectService(6, index);
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 17.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          CommonText(
                                            text:
                                                'servicesNeeds.${provider.desiredServices[index].title}'
                                                    .tr(),
                                            textAlign: TextAlign.left,
                                            style:
                                                Poppins.medium(AppColors.mako)
                                                    .s15,
                                            maxLines: 1,
                                          ),
                                          SvgPicture.asset(provider
                                                  .desiredServices[index].select
                                              ? 'assets/icon/checkbox-on.svg'
                                              : "assets/icon/checkbox-off.svg"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 32.0, bottom: 9.01),
                              child: CommonText(
                                text: 'login.conditions'.tr(),
                                textAlign: TextAlign.left,
                                style: Poppins.bold(AppColors.mako).s16,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 30.0),
                              decoration: BoxDecoration(
                                color: AppColors.alabaster,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                    top: 17, right: 20, left: 20),
                                itemCount: provider.conditions.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      provider.selectService(5, index);
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 17.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          CommonText(
                                            text:
                                                'servicesNeeds.${provider.conditions[index].title}'
                                                    .tr(),
                                            textAlign: TextAlign.left,
                                            style:
                                                Poppins.medium(AppColors.mako)
                                                    .s15,
                                            maxLines: 1,
                                          ),
                                          SvgPicture.asset(provider
                                                  .conditions[index].select
                                              ? 'assets/icon/checkbox-on.svg'
                                              : "assets/icon/checkbox-off.svg"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),
            /*back-next*/
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
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
                    buttonText: 'login.next'.tr(),
                    borderColor: provider.serviceAndNeedIsSelected
                        ? AppColors.madison
                        : AppColors.trans,
                    backgroundColor: provider.serviceAndNeedIsSelected
                        ? AppColors.madison
                        : AppColors.madison.withOpacity(0.08),
                    onPressed: provider.serviceAndNeedIsSelected
                        ? () {
                            Navigator.pushNamed(
                                context,
                                SharedPrefHelper.userType == '2'
                                    ? AvailabilityScreen.route
                                    : EmergencyContactsScreen.route);
                          }
                        : () {},
                    borderRadius: 27.0,
                    style: Poppins.bold(provider.serviceAndNeedIsSelected
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
