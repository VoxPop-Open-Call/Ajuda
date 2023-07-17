import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RateUsUi/widget/rate_us_conformation_pop_up.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestViewModel.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:ajuda/my_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/CommonButton.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/commanWidget/network_image.dart';
import '../../../Utils/commanWidget/textform_field.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';

class RateUsScreen extends StatefulWidget {
  static const String route = "RateUsScreen";

  const RateUsScreen({Key? key}) : super(key: key);

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  ratingCount(List<dynamic> data) {
    double sumRating = 0;

    for (var item in data) {
      sumRating += item.rating != 'null' ? double.parse(item.rating!) : 0.0;
    }

    return (sumRating / data.length);
  }

  @override
  void initState() {
    withViewModel<RequestViewModel>(context, (viewModel) {
      viewModel.addListener(() {
        if (viewModel.ratingCheck) {
          viewModel.ratingCheck = false;
          openDialog();
          // Navigator.of(navigatorKey.currentContext!).pop();
        }
      });
    });
    super.initState();
  }

  openDialog() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return RateUsConformationPopUp(
          complete: () {
            Navigator.of(navigatorKey.currentContext!).pop();
            Navigator.of(navigatorKey.currentContext!).pop();
            // ctx!.read<RequestViewModel>().getCompleteList();
          },
        );
      },
    );
  }

  BuildContext? ctx;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestViewModel>();
    return BaseScreen<RequestViewModel>(
      color: AppColors.bittersweet,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 44, right: 25, left: 25, bottom: 31),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 5.0),
              child: CommonText(
                text: SharedPrefHelper.userType == '1'
                    ? 'rate.rateService'.tr()
                    : 'rate.newRating'.tr(),
                style: Poppins.bold(AppColors.white).s22,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
            CommonText(
              text: SharedPrefHelper.userType == '1'
                  ? 'rate.requestedHasEnded'.tr()
                  : 'rate.workDone'.tr(),
              style: Poppins.medium(AppColors.white.withOpacity(0.70)).s13,
              maxLines: 3,
              textAlign: TextAlign.start,
            ),
            /*profile*/
            if (SharedPrefHelper.userType == '1')
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 27.0, bottom: 27.0),
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
                                    url: provider
                                            .completeListData[
                                                provider.comAndUpIndex]
                                            .volunteer
                                            ?.image ??
                                        ''),
                              ),
                            )
                            // CircleAvatar(
                            //   backgroundImage: NetworkImage(''),
                            //   radius: 85,
                            //   backgroundColor: AppColors.white,
                            // ),
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
                                  color: Colors.white, //color of shadow
                                  spreadRadius: 2, //spread radius
                                  blurRadius: 2, // blur radius
                                  offset: Offset(
                                      0, 2), // changes position of shadow
                                  //second parameter is top to down
                                ),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                provider
                                            .completeListData[
                                                provider.comAndUpIndex]
                                            .taskType!
                                            .title ==
                                        'company'
                                    ? 'assets/icon/keepCompany.svg'
                                    : provider
                                                .completeListData[
                                                    provider.comAndUpIndex]
                                                .taskType!
                                                .title ==
                                            'pharmacy'
                                        ? 'assets/icon/pharmacies.svg'
                                        : provider
                                                    .completeListData[
                                                        provider.comAndUpIndex]
                                                    .taskType!
                                                    .title ==
                                                'shopping'
                                            ? 'assets/icon/cart.svg'
                                            : provider
                                                        .completeListData[
                                                            provider
                                                                .comAndUpIndex]
                                                        .taskType!
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CommonText(
                        text: provider.capitalize(provider
                                .completeListData[provider.comAndUpIndex]
                                .volunteer
                                ?.name ??
                            ''),
                        style: Poppins.bold(AppColors.white).s16,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      CommonText(
                        text: provider.capitalize(provider
                            .completeListData[provider.comAndUpIndex]
                            .taskType!
                            .title),
                        style: Poppins.medium(AppColors.white).s12,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0, top: 1),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icon/date.svg',
                              width: 11,
                              height: 11.42,
                              color: AppColors.white,
                            ),
                            const SizedBox(
                              width: 7.0,
                            ),
                            CommonText(
                              text: DateFormat('MMM dd, yyyy')
                                  .format(DateTime.parse(provider
                                      .completeListData[provider.comAndUpIndex]
                                      .date!))
                                  .toString(),
                              style: Poppins.semiBold(AppColors.white).s12,
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
                            color: AppColors.white,
                          ),
                          const SizedBox(
                            width: 7.0,
                          ),
                          CommonText(
                            text: provider
                                        .completeListData[
                                            provider.comAndUpIndex]
                                        .timeFrom !=
                                    null
                                ? '${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(provider.completeListData[provider.comAndUpIndex].timeFrom!).toUtc())} • ${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(provider.completeListData[provider.comAndUpIndex].timeTo!).toUtc())}'
                                : 'any'.tr(),
                            style: Poppins.semiBold(AppColors.white).s12,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

            /*rate bar*/
            if (SharedPrefHelper.userType == '1')
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                margin: const EdgeInsets.only(bottom: 12.0, top: 29.0),
                padding: const EdgeInsets.only(
                    bottom: 27.0, top: 23.0, left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    CommonText(
                      text: 'rate.yourReview'.tr(),
                      style: Poppins.bold(AppColors.bittersweet).s20,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 19.0, bottom: 36),
                      child: RatingBar(
                        itemSize: 30,
                        initialRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                          full: SvgPicture.asset(
                            'assets/icon/rate-on.svg',
                            width: 29.12,
                            height: 29.18,
                          ),
                          half: SvgPicture.asset(
                            'assets/icon/rate-on.svg',
                            width: 29.12,
                            height: 29.18,
                          ),
                          empty: SvgPicture.asset(
                            'assets/icon/rate-off.svg',
                            width: 29.12,
                            height: 29.18,
                          ),
                        ),
                        itemPadding: const EdgeInsets.only(right: 14.65),
                        onRatingUpdate: (rating) {
                          provider.ratingReview = rating.toInt();
                        },
                      ),
                    ),
                    TextFormField_Common(
                      contentPadding: 16,
                      textStyle: Poppins.medium(AppColors.mako).s15,
                      onChanged: (String? value) {
                        context.read<RequestViewModel>().writeReview = value;
                      },
                      errorText: context.select<RequestViewModel, String?>(
                        (RequestViewModel state) => state.writeReviewError,
                      ),
                      hintText: 'rate.writeReview'.tr(),
                      textInputType: TextInputType.text,
                      maxLines: 8,
                      contentPaddingTop: 11.0,
                      obscureText: false,
                      textColor: AppColors.mako,
                      borderRadius: 6.0,
                      textStyleHint: Poppins.regular(
                        AppColors.mako.withOpacity(0.50),
                      ).s13,
                    ),
                  ],
                ),
              ),
            if (SharedPrefHelper.userType == '2')
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                margin: const EdgeInsets.only(bottom: 20.0, top: 29.0),
                padding: const EdgeInsets.only(
                    bottom: 29.0, top: 23.0, left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 27.0, bottom: 34.0),
                          width: 85,
                          height: 85,
                          // color: AppColors.madison,
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  // : ,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.bittersweet,width: 2),
                                  ),
                                  child: SizedBox(
                                    height: 85,
                                    width: 85,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(80.0),
                                      child: MyNetworkImage.circular(
                                          url: provider
                                                  .completeListData[
                                                      provider.comAndUpIndex]
                                                  .task
                                                  .requester
                                                  ?.image ??
                                              ''),
                                    ),
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
                                        color: Colors.white, //color of shadow
                                        spreadRadius: 2, //spread radius
                                        blurRadius: 2, // blur radius
                                        offset: Offset(
                                            0, 2), // changes position of shadow
                                        //second parameter is top to down
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      provider
                                                  .completeListData[
                                                      provider.comAndUpIndex]
                                                  .task
                                                  .taskType!
                                                  .title ==
                                              'company'
                                          ? 'assets/icon/keepCompany.svg'
                                          : provider
                                                      .completeListData[provider
                                                          .comAndUpIndex]
                                                      .task
                                                      .taskType!
                                                      .title ==
                                                  'pharmacy'
                                              ? 'assets/icon/pharmacies.svg'
                                              : provider
                                                          .completeListData[
                                                              provider
                                                                  .comAndUpIndex]
                                                          .task
                                                          .taskType!
                                                          .title ==
                                                      'shopping'
                                                  ? 'assets/icon/cart.svg'
                                                  : provider
                                                              .completeListData[
                                                                  provider
                                                                      .comAndUpIndex]
                                                              .task
                                                              .taskType!
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CommonText(
                              text: provider.capitalize(provider
                                      .completeListData[provider.comAndUpIndex]
                                      .task
                                      .requester
                                      ?.name ??
                                  ''),
                              style: Poppins.bold(AppColors.madison).s16,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            CommonText(
                              text: provider.capitalize(provider
                                  .completeListData[provider.comAndUpIndex]
                                  .task
                                  .taskType!
                                  .title),
                              style: Poppins.medium(
                                      AppColors.madison.withOpacity(0.80))
                                  .s12,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 3.0, top: 1),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/date.svg',
                                    width: 11,
                                    height: 11.42,
                                    color: AppColors.madison.withOpacity(0.4),
                                  ),
                                  const SizedBox(
                                    width: 7.0,
                                  ),
                                  CommonText(
                                    text: DateFormat('MMM dd, yyyy')
                                        .format(DateTime.parse(provider
                                            .completeListData[
                                                provider.comAndUpIndex]
                                            .task
                                            .date!))
                                        .toString(),
                                    style:
                                        Poppins.semiBold(AppColors.madison).s12,
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
                                  color: AppColors.madison.withOpacity(0.4),
                                ),
                                const SizedBox(
                                  width: 7.0,
                                ),
                                CommonText(
                                  text: provider
                                              .completeListData[
                                                  provider.comAndUpIndex]
                                              .task
                                              .timeFrom !=
                                          null
                                      ? '${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(provider.completeListData[provider.comAndUpIndex].task.timeFrom!).toUtc())} • ${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(provider.completeListData[provider.comAndUpIndex].task.timeTo!).toUtc())}'
                                      : 'any'.tr(),
                                  style:
                                      Poppins.semiBold(AppColors.madison).s12,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingBarIndicator(
                          rating: double.parse(provider
                              .completeListData[provider.comAndUpIndex].rating
                              .toString()),
                          itemBuilder: (context, index) => SvgPicture.asset(
                            'assets/icon/rate-on.svg',
                            width: 20.32,
                            height: 20.36,
                          ),
                          itemCount: 5,
                          itemPadding: const EdgeInsets.only(right: 11.23),
                          itemSize: 20.0,
                          unratedColor: AppColors.mako.withOpacity(0.10),
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 34, left: 25),
                      child: CommonText(
                        text: provider.completeListData[provider.comAndUpIndex]
                                .comment ??
                            '',
                        style: Poppins.regular(AppColors.baliHai).s14,
                        maxLines: 5,
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonText(
                  text: SharedPrefHelper.userType == '1'
                      ? 'rate.reviewWillAppear'.tr()
                      : 'rate.allYour'.tr(),
                  style: Poppins.medium(AppColors.white.withOpacity(0.70)).s12,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(
              height: 50.0,
            ),
            /*submit*/
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CommonButton(
                  borderColor: AppColors.madison,
                  backgroundColor: AppColors.madison,
                  onPressed: () {
                    if (SharedPrefHelper.userType == '1') {
                      if (provider.checkWriteReview()) {
                        provider.review(provider
                            .completeListData[provider.comAndUpIndex]
                            .assignments[0]
                            .id);
                      }
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  borderRadius: 27.0,
                  buttonText: SharedPrefHelper.userType == '1'
                      ? 'rate.submit'.tr()
                      : 'rate.close'.tr(),
                  style: Poppins.bold(AppColors.white).s14,
                  minimumSize: 190,
                  minimumWidget: 52,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
