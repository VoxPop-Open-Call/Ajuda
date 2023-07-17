import 'package:ajuda/Ui/Utils/alert.dart';
import 'package:ajuda/Ui/Utils/commanWidget/CommonButton.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RequestDetailUi/AfterCancelationUi/selectNewVolunteerScreen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestViewModel.dart';
import 'package:ajuda/my_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../data/local/shared_pref_helper.dart';
import '../../../../Utils/base_screen.dart';
import '../../../../Utils/commanWidget/commonText.dart';
import '../../../../Utils/commanWidget/network_image.dart';
import '../../../../Utils/font_style.dart';
import '../../../../Utils/theme/appcolor.dart';

class CanceledScreen extends StatefulWidget {
  static const String route = "CanceledScreen";

  const CanceledScreen({Key? key}) : super(key: key);

  @override
  State<CanceledScreen> createState() => _CanceledScreenState();
}

class _CanceledScreenState extends State<CanceledScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    withViewModel<RequestViewModel>(context, (viewModel) {
      viewModel.addListener(() {
        if (viewModel.cancelDone) {
          viewModel.cancelDone = false;
          Alert.showSnackBarSuccess(
              navigatorKey.currentContext!, viewModel.snackBarText!);
          Navigator.of(navigatorKey.currentContext!).pop();
          Navigator.of(navigatorKey.currentContext!).pop();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestViewModel>();

    final data = SharedPrefHelper.userType == '1'
        ? provider.upcomingListData[provider.comAndUpIndex]
        : provider.upcomingListData[provider.comAndUpIndex].task;
    return BaseScreen<RequestViewModel>(
      color: AppColors.madison,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 80, right: 25, left: 25, bottom: 21),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonText(
                text: 'request.requestCanceled'.tr(),
                style: Poppins.bold(AppColors.white).s22,
                maxLines: 1,
                textAlign: TextAlign.start),
            Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: CommonText(
                  text: SharedPrefHelper.userType == '1'
                      ? 'request.canceled'.tr()
                      : 'request.canceledUser'.tr(),
                  style: Poppins.medium(AppColors.white.withOpacity(0.70)).s13,
                  maxLines: 2,
                  textAlign: TextAlign.start),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                    top: 40.0,
                    bottom: SharedPrefHelper.userType == '1' ? 56.0 : 63.0),
                shrinkWrap: true,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.white),
                    margin: const EdgeInsets.only(bottom: 56.0),
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 30, bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 0.0,
                                  right: 14.0,
                                  top: 0.0,
                                  bottom: 27.0),
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
                                        borderRadius:
                                            BorderRadius.circular(80.0),
                                        child: MyNetworkImage.circular(
                                            url: SharedPrefHelper.userType ==
                                                    '1'
                                                ? data.volunteer?.image ?? ''
                                                : data.requester?.image ?? ''),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.bittersweet,
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
                                            offset: Offset(0,
                                                2), // changes position of shadow
                                            //second parameter is top to down
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          data.taskType!.title == 'company'
                                              ? 'assets/icon/keepCompany.svg'
                                              : data.taskType!.title ==
                                                      'pharmacy'
                                                  ? 'assets/icon/pharmacies.svg'
                                                  : data.taskType!.title ==
                                                          'shopping'
                                                      ? 'assets/icon/cart.svg'
                                                      : data.taskType!.title ==
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CommonText(
                                  text: provider.capitalize(
                                      SharedPrefHelper.userType == '1'
                                          ? data.volunteer?.name ?? ''
                                          : data.requester?.name ?? ''),
                                  style: Poppins.bold(AppColors.madison).s16,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                                CommonText(
                                  text: 'servicesNeeds.${data.taskType!.title}'
                                      .tr()
                                  /*    provider.capitalize(provider
                                      .upcomingListData[provider.comAndUpIndex]
                                      .taskType!
                                      .title)*/
                                  ,
                                  style: Poppins.medium(AppColors.mako).s12,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 3.0, top: 1),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icon/date.svg',
                                        width: 11,
                                        height: 11.42,
                                        color: AppColors.mako,
                                      ),
                                      const SizedBox(
                                        width: 7.0,
                                      ),
                                      CommonText(
                                        text: DateFormat('MMM dd, yyyy')
                                            .format(DateTime.parse(data!.date!))
                                            .toString(),
                                        style: Poppins.semiBold(AppColors.mako)
                                            .s12,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icon/time.svg',
                                      width: 11,
                                      height: 11.42,
                                      color: AppColors.mako,
                                    ),
                                    const SizedBox(
                                      width: 7.0,
                                    ),
                                    CommonText(
                                      text: data.timeFrom != null
                                          // ? '${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(provider.upcomingListData[provider.comAndUpIndex].timeFrom!).toUtc())} • ${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(provider.upcomingListData[provider.comAndUpIndex].timeTo!).toUtc())}'
                                          ? '${parseDatetimeFromUtc(isoFormattedString: '${DateFormat('yyyy-MM-dd').format(DateTime.parse(data.date!))}T${data.timeFrom}')} • ${parseDatetimeFromUtc(isoFormattedString: '${DateFormat('yyyy-MM-dd').format(DateTime.parse(data.date!))}T${data.timeTo}')}'
                                          : 'any'.tr(),
                                      style:
                                          Poppins.semiBold(AppColors.mako).s12,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                  text: 'volunteer.service'.tr(),
                                  style: Poppins.medium(AppColors.baliHai).s12,
                                  maxLines: 1,
                                  textAlign: TextAlign.start),
                              CommonText(
                                  text: provider.capitalize(data.description),
                                  style: Poppins.regular(AppColors.mako).s14,
                                  maxLines: 3,
                                  textAlign: TextAlign.start),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  CommonText(
                      text: SharedPrefHelper.userType == '1'
                          ? 'request.anotherVolunteer'.tr()
                          : 'request.willNoLonger'.tr(),
                      style: Poppins.medium(AppColors.white).s13,
                      maxLines: 6,
                      textAlign: TextAlign.start),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (SharedPrefHelper.userType == '1')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonButton(
                    borderColor: AppColors.white.withOpacity(0.40),
                    backgroundColor: AppColors.trans,
                    onPressed: () {
                      provider.cancelRequest(data!.id, provider.comAndUpIndex);
                      // Navigator.of(context).pop();
                      // Navigator.of(context).pop();
                    },
                    borderRadius: 27.0,
                    style: Poppins.bold(AppColors.white).s14,
                    minimumSize: 224,
                    minimumWidget: 52,
                    buttonText: 'request.justCancel'.tr(),
                  ),
                ],
              ),
            if (SharedPrefHelper.userType == '1')
              const SizedBox(
                height: 18.0,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonButton(
                  borderColor: AppColors.white,
                  backgroundColor: AppColors.white,
                  onPressed: () {
                    if (SharedPrefHelper.userType == '1') {
                      Navigator.pushNamed(
                          context, SelectNewVolunteerScreen.route);
                    } else {
                      Navigator.of(context).pop();
                      // provider.cancelRequest(data!.id, provider.comAndUpIndex);
                    }
                  },
                  borderRadius: 27.0,
                  style: Poppins.bold(AppColors.madison).s14,
                  minimumSize: 224,
                  minimumWidget: 52,
                  buttonText: SharedPrefHelper.userType == '1'
                      ? 'request.newVolunteer'.tr()
                      : 'request.gotIt'.tr(),
                ),
              ],
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
