import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/PendingRequestUi/pending_request_details.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/PendingRequestUi/pending_request_widget.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestViewModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../my_app.dart';
import '../../../Utils/alert.dart';
import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';

class PendingRequestScreen extends StatefulWidget {
  static const String route = "PendingRequestScreen";

  const PendingRequestScreen({Key? key}) : super(key: key);

  @override
  State<PendingRequestScreen> createState() => _PendingRequestScreenState();
}

class _PendingRequestScreenState extends State<PendingRequestScreen> {
  @override
  void initState() {
    withViewModel<RequestViewModel>(context, (viewModel) {
      viewModel.getPendingList();

      viewModel.addListener(() {
        viewModel.acceptRejectSuccess = () {
          Alert.showSnackBarSuccess(
              navigatorKey.currentContext!, viewModel.snackBarText!);
        };
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestViewModel>();
    return BaseScreen<RequestViewModel>(
      color: AppColors.porcelain,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 45, right: 22, left: 15, bottom: 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 39,
              width: 39,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: const Center(
                child: BackButton(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 21.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CommonText(
                    text: 'home.requests'.tr(),
                    style: Poppins.semiBold(AppColors.mako).s16,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.pendingListData.isEmpty
                  ? Center(
                      child: CommonText(
                          text: 'errorMessage.not_data'.tr(),
                          style: Poppins.semiBold(AppColors.bittersweet).s15,
                          maxLines: 2,
                          textAlign: TextAlign.center),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.pendingListData.length,
                      padding: EdgeInsets.zero,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            provider.selectPendingIndex = index;
                            Navigator.pushNamed(
                                context, PendingRequestDetails.route);
                          },
                          child: PendingRequestWidget(
                            name: provider.capitalize(provider
                                .pendingListData[index].task.requester.name),
                            year: provider
                                .calculateAge(DateTime.parse(provider
                                    .pendingListData[index]
                                    .task
                                    .requester
                                    .birthday))
                                .toString(),
                            image: provider.pendingListData[index].task
                                    .requester.image ??
                                '',
                            task: provider.capitalize(provider
                                .pendingListData[index].task.taskType.title),
                            description: provider.capitalize(provider
                                .pendingListData[index].task.description),
                            date: DateFormat('MMM dd, yyyy')
                                .format(DateTime.parse(
                                    provider.pendingListData[index].task.date))
                                .toString(),
                            time: 'Any',
                            onPressedAccept: () {
                              provider.acceptRequest(
                                  provider.pendingListData[index].id, index);
                            },
                            onPressedReject: () {
                              provider.rejectRequest(
                                  provider.pendingListData[index].id, index);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
