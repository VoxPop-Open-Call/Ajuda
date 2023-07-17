import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/widget/app_bar_widget.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/ChatUi/chat_screen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RequestDetailUi/widget/cancel_request_pop_up.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RequestDetailUi/widget/service_widget.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestViewModel.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/commanWidget/network_image.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';
import 'AfterCancelationUi/canceldScreen.dart';

class RequestDetailScreen extends StatefulWidget {
  static const String route = "RequestDetailScreen";

  const RequestDetailScreen({Key? key}) : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    withViewModel<RequestViewModel>(context, (viewModel) {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestViewModel>();
    final data = SharedPrefHelper.userType == '1'
        ? provider.upcomingListData[provider.comAndUpIndex]
        : provider.upcomingListData[provider.comAndUpIndex].task;
    return BaseScreen<RequestViewModel>(
      color: AppColors.white,
      appBar: const CommonAppBar(
        title: '',
        color: AppColors.trans,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 10.5, right: 25, left: 25, bottom: 31),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin:
                      const EdgeInsets.only(left: 0.0, right: 14.0, top: 0.0),
                  width: 85,
                  height: 85,
                  // color: AppColors.madison,
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
                                  url: SharedPrefHelper.userType == '1'
                                      ? data.volunteer?.image ?? ''
                                      : data.requester?.image ?? ''),
                            ),
                          )

                          /* CircleAvatar(
                          backgroundImage: NetworkImage(''),
                          radius: 85,
                          backgroundColor: AppColors.madison,
                        ),*/
                          ),
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
                              data.taskType!.title == 'company'
                                  ? 'assets/icon/keepCompany.svg'
                                  : data.taskType!.title == 'pharmacy'
                                      ? 'assets/icon/pharmacies.svg'
                                      : data.taskType!.title == 'shopping'
                                          ? 'assets/icon/cart.svg'
                                          : data.taskType!.title == 'tours'
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
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CommonText(
                          text: provider.capitalize(
                              SharedPrefHelper.userType == '1'
                                  ? data.volunteer?.name ?? ''
                                  : data.requester?.name ?? ''),
                          style: Poppins.bold(AppColors.mako).s18,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        CommonText(
                          text: provider.capitalize(data.taskType!.title),
                          style: Poppins.medium(
                                  AppColors.madison.withOpacity(0.80))
                              .s12,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24.0,
            ),
            CommonText(
                text: 'volunteer.service'.tr(),
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
                textAlign: TextAlign.start),
            CommonText(
                // text: provider.capitalize(data.taskType!.title)
                text: 'servicesNeeds.${data.taskType!.title}'.tr(),
                style: Poppins.semiBold(AppColors.mako).s16,
                maxLines: 1,
                textAlign: TextAlign.start),
            const SizedBox(height: 30.0),
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CommonText(
                        text: 'volunteer.date'.tr(),
                        style: Poppins.medium(AppColors.baliHai).s12,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                    CommonText(
                        text: DateFormat('MMM dd, yyyy')
                            .format(DateTime.parse(data!.date!))
                            .toString(),
                        style: Poppins.medium(AppColors.mako).s16,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                  ],
                ),
                const SizedBox(width: 41.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CommonText(
                        text: 'volunteer.time'.tr(),
                        style: Poppins.medium(AppColors.baliHai).s12,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                    CommonText(
                        text: data.timeFrom != null
                            // ? '${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(data.timeFrom!).toUtc())} • ${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(data.timeTo!).toUtc())}'
                            ? '${parseDatetimeFromUtc(isoFormattedString: '${DateFormat('yyyy-MM-dd').format(DateTime.parse(data.date!))}T${data.timeFrom}')} • ${parseDatetimeFromUtc(isoFormattedString: '${DateFormat('yyyy-MM-dd').format(DateTime.parse(data.date!))}T${data.timeTo}')}'
                            : 'any'.tr(),
                        style: Poppins.medium(AppColors.mako).s16,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 36.0),
            CommonText(
                text: 'request.notesShared'.tr(),
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
                textAlign: TextAlign.start),
            const SizedBox(height: 5.0),
            CommonText(
                text: provider.capitalize(data.description),
                style: Poppins.medium(AppColors.mako).s15,
                maxLines: 3,
                textAlign: TextAlign.start),
            const SizedBox(
              height: 36.27,
            ),
            ServiceWidget(
              icon: 'assets/icon/chat.svg',
              title: 'request.chatWithVolunteer'.tr(),
              count: 0,
              arrowShow: true,
              goAhead: () {
                Navigator.pushNamed(context, ChatScreen.route);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: ServiceWidget(
                icon: 'assets/icon/request-call.svg',
                title: 'request.callVolunteer'.tr(),
                arrowShow: false,
                goAhead: () {
                  SharedPrefHelper.userType == '1'
                      ? data.volunteer.phoneNumber != null
                          ? provider.makePhoneCall(data.volunteer.phoneNumber)
                          : ''
                      : data.requester.phoneNumber != null
                          ? provider.makePhoneCall(data.requester.phoneNumber)
                          : '';
                },
              ),
            ),
            ServiceWidget(
              icon: 'assets/icon/cancel.svg',
              title: 'request.cancelService'.tr(),
              arrowShow: true,
              goAhead: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CancelRequestPopUp(
                      date: DateFormat('MMM dd ')
                          .format(DateTime.parse(data!.date!))
                          .toString(),
                      complete: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, CanceledScreen.route);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  parseDatetimeFromUtc({required String isoFormattedString}) {
    var dateTime = DateTime.parse(isoFormattedString);
    print(isoFormattedString);
    print(dateTime.toLocal());
    var data =
        dateTime.toLocal().toString().split(' ')[1].toString().split(':');

    return '${data[0]}:${data[1]}';
  }
}
