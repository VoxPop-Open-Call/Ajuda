import 'package:ajuda/Ui/authScreens/signup/service_needs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/CommonButton.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../auth_view_model.dart';

class LanguagesSpoken extends StatefulWidget {
  static const String route = "LanguagesSpoken";

  const LanguagesSpoken({Key? key}) : super(key: key);

  @override
  State<LanguagesSpoken> createState() => _LanguagesSpokenState();
}

class _LanguagesSpokenState extends State<LanguagesSpoken> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*languagesSpoken*/
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 5.0),
              child: CommonText(
                text: 'language.languagesSpoken'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 1,
              ),
            ),

            /*whichLanguages*/
            CommonText(
              text: 'language.whichLanguages'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.medium(AppColors.baliHai).s15,
              maxLines: 4,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 33.0),
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.alabaster,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 17, right: 20, left: 20),
                  itemCount: provider.language.length,
                  // physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        provider.selectService(3, index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 17.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: CommonText(
                                text: ('language.${provider.language[index].id}').tr(),
                                textAlign: TextAlign.left,
                                style: Poppins.medium(AppColors.mako).s15,
                                maxLines: 3,
                              ),
                            ),
                            SvgPicture.asset(provider.language[index].select
                                ? 'assets/icon/checkbox-on.svg'
                                : "assets/icon/checkbox-off.svg"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /*back-next*/
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30.0),
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
                    borderColor: provider.languageIsSelected
                        ? AppColors.madison
                        : AppColors.trans,
                    backgroundColor: provider.languageIsSelected
                        ? AppColors.madison
                        : AppColors.madison.withOpacity(0.08),
                    onPressed: provider.languageIsSelected
                        ? () {
                            Navigator.pushNamed(
                                context, ServiceAndNeedScreen.route);
                          }
                        : () {},
                    borderRadius: 27.0,
                    style: Poppins.bold(provider.languageIsSelected
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
