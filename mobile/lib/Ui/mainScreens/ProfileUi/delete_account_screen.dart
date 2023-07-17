import 'package:ajuda/Ui/mainScreens/ProfileUi/profileViewModel.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/widget/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../Utils/base_screen.dart';
import '../../../Utils/theme/appcolor.dart';

class AccountDeleteScreen extends StatefulWidget {
  const AccountDeleteScreen({Key? key}) : super(key: key);

  @override
  State<AccountDeleteScreen> createState() => _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends State<AccountDeleteScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<ProfileViewModel>();
    return BaseScreen<ProfileViewModel>(
      color: AppColors.porcelain,
      child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const ClampingScrollPhysics(),
          padding:
              const EdgeInsets.only(top: 44, right: 42, left: 25, bottom: 31),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(top: 55.0, bottom: 25.0),
              //   child: CommonText(
              //     text: provider.infoList[i].title.tr(),
              //     textAlign: TextAlign.left,
              //     style: Poppins.bold(AppColors.madison).s27,
              //     maxLines: 2,
              //   ),
              // ),
              // SvgPicture.asset(
              //   width: 314.0,
              //   height: 233.11,
              //   provider.infoList[i].imagePath,
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 25.0, bottom: 16.0),
              //   child: CommonText(
              //     text: provider.infoList[i].subtitle.tr(),
              //     textAlign: TextAlign.left,
              //     style: Poppins.semiBold(AppColors.madison).s18,
              //     maxLines: 2,
              //   ),
              // ),
              // CommonText(
              //   text: provider.infoList[i].description.tr(),
              //   textAlign: TextAlign.left,
              //   style: Poppins.medium(AppColors.baliHai).s15,
              //   maxLines: 10,
              // ),
            ],
          ),
      ),
    );
  }
}
