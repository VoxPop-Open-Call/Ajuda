import 'package:ajuda/Ui/Utils/base_screen.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/History_Screen/widget/history_screen_widget.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/profileViewModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';
import '../widget/app_bar_widget.dart';

class HistoryScreen extends StatefulWidget {
  static const String route = "HistoryScreen";

  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    withViewModel<ProfileViewModel>(context, (viewModel) {
      viewModel.getUserData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileViewModel>();
    return BaseScreen<ProfileViewModel>(
      color: AppColors.white,
      appBar: CommonAppBar(
        title: 'profile.myHistory'.tr(),
        color: AppColors.white,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 44, right: 25, left: 22, bottom: 31),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.historyData.length,
              itemBuilder: (context, index) {
                return HistoryScreenWidget(
                  activityName: provider.historyData[index].task.taskType.title,
                  dateTime:
                      '${DateFormat('MMM dd, yyyy').format(DateTime.parse(provider.historyData[index].task.date!)).toString()} • ${provider.historyData[index].task.timeFrom != null ? '${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(provider.historyData[index].task.timeFrom!).toUtc())} • ${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(provider.historyData[index].task.timeTo!).toUtc())}' : 'any'.tr()}',
                  image: provider.historyData[index].task.requester.image ?? '',
                  name: provider.historyData[index].task.requester.name ?? '',
                  comment: provider.historyData[index].comment,
                  rating: double.parse(provider.historyData[index].rating!),
                );
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 30.0,
                  width: 30.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bittersweet.withOpacity(0.10),
                  ),
                  child: Center(
                    child: Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bittersweet,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 11.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CommonText(
                        text: 'joined_this_community'.tr(),
                        style: Poppins.semiBold(AppColors.bittersweet).s15,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                    CommonText(
                        text: provider.userModel!.createdAt != null
                            ? DateFormat('MMM dd, yyyy')
                                .format(DateTime.parse(
                                    provider.userModel!.createdAt!))
                                .toString()
                            : 'login.pleaseWait'.tr(),
                        style: Poppins.regular(AppColors.baliHai).s12,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
