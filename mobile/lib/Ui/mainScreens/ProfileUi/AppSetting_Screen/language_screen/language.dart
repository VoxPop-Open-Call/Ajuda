import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Utils/base_screen.dart';
import '../../../../Utils/commanWidget/commonText.dart';
import '../../../../Utils/font_style.dart';
import '../../../../Utils/theme/appcolor.dart';
import '../../profileViewModel.dart';
import '../../widget/app_bar_widget.dart';

class LanguageScreen extends StatefulWidget {
  static const String route = "LanguageScreen";

  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<ProfileViewModel>();
    return BaseScreen<ProfileViewModel>(
      appBar: CommonAppBar(
        title: 'profile.language'.tr(),
        color: AppColors.porcelain,
      ),
      color: AppColors.porcelain,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 44, right: 42, left: 25, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CommonText(
                  text: 'profile.appLanguage'.tr(),
                  style: Poppins.semiBold(AppColors.mako).s16,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 34.0, bottom: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        text: 'language.english'.tr(),
                        style: Poppins.medium(AppColors.mako).s14,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                      ),
                      Radio<SingingCharacter>(
                        value: SingingCharacter.english,
                        fillColor: MaterialStateProperty.all(
                            SingingCharacter.english == provider.character
                                ? AppColors.bittersweet
                                : AppColors.Iron),
                        groupValue: provider.character,
                        onChanged: (SingingCharacter? value) {
                          context.setLocale( const Locale('en', 'US'));

                          provider.updateLanguage(value);
                        },
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 0.0, bottom: 10.0),
                    child: Divider(
                      thickness: 2,
                      color: AppColors.seashell,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CommonText(
                        text: 'language.portuguese'.tr(),
                        style: Poppins.medium(AppColors.mako).s14,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                      ),
                      Radio<SingingCharacter>(
                        value: SingingCharacter.portuguese,
                        groupValue: provider.character,
                        fillColor: MaterialStateProperty.all(
                            SingingCharacter.portuguese == provider.character
                                ? AppColors.bittersweet
                                : AppColors.Iron),
                        onChanged: (SingingCharacter? value) {
                          context.setLocale( const Locale('pt'));
                          provider.updateLanguage(value);
                        },
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 0.0, bottom: 10.0),
                    child: Divider(
                      thickness: 2,
                      color: AppColors.seashell,
                    ),
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
