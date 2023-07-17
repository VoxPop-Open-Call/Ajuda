import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/auth_view_model.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/HelpContact_Screen/widget/help_contacts_widget.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/widget/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/local/shared_pref_helper.dart';
import '../../../Utils/base_screen.dart';
import '../../../Utils/theme/appcolor.dart';

class HelpContactsScreen extends StatefulWidget {
  static const String route = "HelpContactsScreen";

  const HelpContactsScreen({Key? key}) : super(key: key);

  @override
  State<HelpContactsScreen> createState() => _HelpContactsScreenState();
}

class _HelpContactsScreenState extends State<HelpContactsScreen> {
  @override
  void initState() {
    withViewModel<AuthViewModel>(context, (viewModel) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      color: AppColors.white,
      appBar: CommonAppBar(
        title: 'profile.helpContacts'.tr(),
        color: AppColors.white,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 44, right: 25, left: 22, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonText(
                text: 'profile.usefulContacts'.tr(),
                style: Poppins.semiBold(AppColors.mako).s16,
                maxLines: 1,
                textAlign: TextAlign.start),
            const SizedBox(
              height: 25.27,
            ),
            HelpContactsWidget(
                tap: () {
                  provider.makePhoneCall('+351 808 24 24 24');
                },
                text: 'profile.saude24'.tr()),
            HelpContactsWidget(
                tap: () {
                  provider.makePhoneCall('112');
                },
                text: 'profile.callEmergency'.tr()),
            HelpContactsWidget(
                tap: () {
                  provider.makePhoneCall('+351 800 910 211');
                },
                text: 'profile.cml'.tr()),
            if (SharedPrefHelper.userType == '1')
              provider.userModel!.elder != null &&
                  provider.userModel!.elder['emergencyContacts'] != null &&
                  provider.userModel!.elder['emergencyContacts'].isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        top: 17,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          provider.userModel!.elder['emergencyContacts'].length,
                      itemBuilder: (context, index) {
                        return HelpContactsWidget(
                            tap: () {
                              provider.makePhoneCall(
                                  provider.userModel!.elder['emergencyContacts']
                                      [index]['phoneNumber']!);
                            },
                            text: provider.userModel!.elder['emergencyContacts']
                                [index]['name']!);
                      },
                    )
                  : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
