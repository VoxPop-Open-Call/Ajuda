import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/widget/app_bar_widget.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestViewModel.dart';
import 'package:ajuda/my_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../Utils/alert.dart';
import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/CommonButton.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/commanWidget/network_image.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';

class PendingRequestDetails extends StatefulWidget {
  static const String route = "PendingRequestDetails";

  const PendingRequestDetails({Key? key}) : super(key: key);

  @override
  State<PendingRequestDetails> createState() => _PendingRequestDetailsState();
}

class _PendingRequestDetailsState extends State<PendingRequestDetails> {
  @override
  void initState() {
    withViewModel<RequestViewModel>(context, (viewModel) {
      viewModel.addListener(() {
        if (viewModel.requestReject) {
          viewModel.requestReject = false;
          Alert.showSnackBarSuccess(
              navigatorKey.currentContext!, viewModel.snackBarText!);
          Navigator.of(navigatorKey.currentContext!).pop();
        }
        if (viewModel.requestAccept) {
          viewModel.requestAccept = false;
          Alert.showSnackBarSuccess(
              navigatorKey.currentContext!, viewModel.snackBarText!);
          Navigator.of(navigatorKey.currentContext!).pop();
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestViewModel>();
    return BaseScreen<RequestViewModel>(
      color: AppColors.white,
      appBar: const CommonAppBar(
        title: '',
        color: AppColors.trans,
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10.5, right: 25, left: 25, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      left: 0.0, right: 14.0, top: 0.0, bottom: 0.0),
                  width: 85,
                  height: 85,
                  child: Stack(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 85,
                            width: 85,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(80.0),
                              child: MyNetworkImage.circular(
                                  url: provider
                                          .pendingListData[
                                              provider.selectPendingIndex]
                                          .task
                                          .requester
                                          .image ??
                                      ''),
                            ),
                          )),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: AppColors.madison,
                            // shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.white,
                                //color of shadow
                                spreadRadius: 2,
                                //spread radius
                                blurRadius: 2,
                                // blur radius
                                offset:
                                    Offset(0, 2), // changes position of shadow
                                //second parameter is top to down
                              ),
                            ],
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              provider
                                          .pendingListData[
                                              provider.selectPendingIndex]
                                          .task
                                          .taskType
                                          .title ==
                                      'company'
                                  ? 'assets/icon/keepCompany.svg'
                                  : provider
                                              .pendingListData[
                                                  provider.selectPendingIndex]
                                              .task
                                              .taskType
                                              .title ==
                                          'pharmacy'
                                      ? 'assets/icon/pharmacies.svg'
                                      : provider
                                                  .pendingListData[provider
                                                      .selectPendingIndex]
                                                  .task
                                                  .taskType
                                                  .title ==
                                              'shopping'
                                          ? 'assets/icon/cart.svg'
                                          : provider
                                                      .pendingListData[provider
                                                          .selectPendingIndex]
                                                      .task
                                                      .taskType
                                                      .title ==
                                                  'tours'
                                              ? 'assets/icon/map.svg'
                                              : 'assets/icon/file.svg',
                              width: 20,
                              height: 20,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CommonText(
                        text: provider.capitalize(provider
                            .pendingListData[provider.selectPendingIndex]
                            .task
                            .requester
                            .name),
                        style: Poppins.bold(AppColors.mako).s18,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      CommonText(
                        text:
                            '${provider.calculateAge(DateTime.parse(provider.pendingListData[provider.selectPendingIndex].task.requester.birthday))} ${'volunteer.years_old'.tr()}',
                        style: Poppins.medium(AppColors.mako.withOpacity(0.80))
                            .s12,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 28.0,
              ),
              child: CommonText(
                text: 'volunteer.service'.tr(),
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
            CommonText(
              text: provider.capitalize(provider
                  .pendingListData[provider.selectPendingIndex]
                  .task
                  .taskType
                  .title),
              style: Poppins.bold(AppColors.madison).s14,
              maxLines: 1,
              textAlign: TextAlign.start,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 35),
              child: CommonText(
                text: provider.capitalize(provider
                    .pendingListData[provider.selectPendingIndex]
                    .task
                    .description),
                style: Poppins.semiBold(AppColors.mako).s12,
                maxLines: 4,
                textAlign: TextAlign.start,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: 'volunteer.date'.tr(),
                      style: Poppins.medium(AppColors.baliHai).s12,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    CommonText(
                      text: DateFormat('MMM dd, yyyy')
                          .format(DateTime.parse(provider
                              .pendingListData[provider.selectPendingIndex]
                              .task
                              .date))
                          .toString(),
                      style: Poppins.semiBold(AppColors.mako).s12,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: 'volunteer.time'.tr(),
                      style: Poppins.medium(AppColors.baliHai).s12,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    CommonText(
                      text: 'Any',
                      style: Poppins.semiBold(AppColors.mako).s12,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            const Expanded(child: SizedBox.shrink()),
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 31.83),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CommonButton(
                    borderColor: AppColors.madison.withOpacity(0.08),
                    backgroundColor: AppColors.madison.withOpacity(0.08),
                    onPressed: () {
                      provider.rejectRequest(
                          provider
                              .pendingListData[provider.selectPendingIndex].id,
                          provider.selectPendingIndex);
                    },
                    borderRadius: 27,
                    style: Poppins.bold(AppColors.madison).s14,
                    minimumSize: 140,
                    buttonText: 'volunteer.decline'.tr(),
                    minimumWidget: 52,
                  ),
                  CommonButton(
                    borderColor: AppColors.bittersweet,
                    backgroundColor: AppColors.bittersweet,
                    onPressed: () {
                      provider.acceptRequest(
                          provider
                              .pendingListData[provider.selectPendingIndex].id,
                          provider.selectPendingIndex);
                    },
                    borderRadius: 27,
                    style: Poppins.bold(AppColors.white).s14,
                    minimumSize: 140,
                    buttonText: 'volunteer.accept'.tr(),
                    minimumWidget: 52,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
