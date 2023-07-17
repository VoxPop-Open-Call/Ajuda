import 'package:ajuda/Ui/Utils/alert.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/volunteerViewModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/CommonButton.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/commanWidget/textform_field.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';
import '../../../Utils/view_model.dart';
import '../../HomeUi/homeViewModel.dart';
import '../VolunteersProfile/VolunteersProfileScreen.dart';
import '../widget/volunteers_widget.dart';
import 'widget/request_sent_pop_up.dart';
import 'widget/servise_widget.dart';

class NewRequestStepScreen extends StatefulWidget {
  static const String route = "NewRequestStepScreen";

  const NewRequestStepScreen({Key? key}) : super(key: key);

  @override
  State<NewRequestStepScreen> createState() => _NewRequestStepScreenState();
}

class _NewRequestStepScreenState extends State<NewRequestStepScreen> {
  @override
  void initState() {
    withViewModel<VolunteerViewModel>(context, (viewModel) {
      viewModel.back(false);
      viewModel.selectedIndex = null;

      viewModel.homeViewModel =
          Provider.of<HomeViewModel>(context, listen: false);
      viewModel.dobController!.text =
          DateFormat('MMM dd, yyyy').format(DateTime.now()).toString();
      viewModel.startTimeRequest = DateFormat('hh:mm').format(DateTime.now());
      viewModel.endTimeRequest = DateFormat('hh:mm')
          .format(DateTime.now().add(const Duration(minutes: 60)));
      viewModel.getService();

      viewModel.addListener(() {
        if (viewModel.requestCreate) {
          viewModel.requestCreate = false;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return RequestSentPopUp(
                complete: () {
                  if (viewModel.back(true)) {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          );
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VolunteerViewModel>();
    return WillPopScope(
      onWillPop: () => provider.back(true),
      child: BaseScreen<VolunteerViewModel>(
        color: AppColors.white,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 44, right: 25, left: 25, bottom: 21),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: SvgPicture.asset(
                        'assets/icon/close.svg',
                        height: 14.01,
                        width: 14.0,
                      ),
                      onTap: () {
                        provider.back(true);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 6.0),
                      child: CommonText(
                          text: provider.requestReview
                              ? 'volunteer.requestReview'.tr()
                              : 'volunteer.newRequest'.tr(),
                          style: Poppins.bold(AppColors.bittersweet).s22,
                          maxLines: 1,
                          textAlign: TextAlign.start),
                    ),
                    CommonText(
                        text: provider.requestReview
                            ? 'volunteer.pleaseConfirm'.tr()
                            : 'volunteer.volunteerThatBestSuit'.tr(),
                        style: Poppins.medium(AppColors.mako).s13,
                        maxLines: 3,
                        textAlign: TextAlign.start),
                    Padding(
                      padding: const EdgeInsets.only(top: 11.0, bottom: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.20,
                            height: 6,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: provider.newRequest1
                                    ? AppColors.bittersweet
                                    : AppColors.softPeach),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.20,
                            height: 6,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: provider.newRequest2
                                    ? AppColors.bittersweet
                                    : AppColors.softPeach),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.20,
                            height: 6,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: provider.newRequest3
                                    ? AppColors.bittersweet
                                    : AppColors.softPeach),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.20,
                            height: 6,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: provider.requestReview
                                    ? AppColors.bittersweet
                                    : AppColors.softPeach),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          /*select service*/
                          Visibility(
                            visible: provider.newRequest1 &&
                                !provider.newRequest3 &&
                                !provider.newRequest2 &&
                                !provider.requestReview,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CommonText(
                                    text: 'volunteer.selectService'.tr(),
                                    style: Poppins.semiBold(AppColors.mako).s16,
                                    maxLines: 1,
                                    textAlign: TextAlign.start),
                                ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: provider.services.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ServiceWidget(
                                        tab: () {
                                          provider.selectService(false, index);
                                        },
                                        select: provider.services[index].select,
                                        title: provider.services[index].title!,
                                        icon: provider.services[index].icon!);
                                  },
                                ),
                              ],
                            ),
                          ),
                          /*select date and time*/
                          Visibility(
                            visible: provider.newRequest2 &&
                                provider.newRequest1 &&
                                !provider.newRequest3 &&
                                !provider.requestReview,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CommonText(
                                    text: 'volunteer.pickDateTime'.tr(),
                                    style: Poppins.semiBold(AppColors.mako).s16,
                                    maxLines: 1,
                                    textAlign: TextAlign.start),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 26.0, bottom: 5.0),
                                  child: CommonText(
                                      text: 'volunteer.date'.tr(),
                                      style:
                                          Poppins.medium(AppColors.baliHai).s12,
                                      maxLines: 1,
                                      textAlign: TextAlign.start),
                                ),
                                TextFormField_Common(
                                  contentPadding: 16,
                                  textEditingController: provider.dobController,
                                  textStyle:
                                      Poppins.semiBold(AppColors.mako).s15,
                                  onChanged: (String? value) {},
                                  errorText: context
                                      .select<VolunteerViewModel, String?>(
                                    (VolunteerViewModel state) =>
                                        state.dateError,
                                  ),
                                  onTap: () {
                                    provider.selectDate();
                                  },
                                  readOnly: true,
                                  hintText: 'Apr 30 2023',
                                  textInputType: TextInputType.visiblePassword,
                                  maxLines: 1,
                                  obscureText: false,
                                  textColor: AppColors.mako,
                                  textStyleHint: Poppins.medium(
                                          AppColors.mako.withOpacity(0.7))
                                      .s15,
                                  suffixIcon: const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: AppColors.mako,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 36.0, bottom: 5.0),
                                  child: CommonText(
                                      text: 'volunteer.Hours'.tr(),
                                      style:
                                          Poppins.medium(AppColors.baliHai).s12,
                                      maxLines: 1,
                                      textAlign: TextAlign.start),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    CommonButton(
                                      borderColor:
                                          AppColors.mako.withOpacity(0.20),
                                      backgroundColor: AppColors.trans,
                                      onPressed: () {
                                        provider.requestTimePickerView(
                                            true, context);
                                      },
                                      borderRadius: 11,
                                      style: Poppins.bold(AppColors.mako).s16,
                                      minimumSize: 140,
                                      minimumWidget: 40,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          CommonText(
                                              text: provider.startTimeRequest ??
                                                  '',
                                              style: Poppins.semiBold(
                                                      provider.specificTime
                                                          ? AppColors.mako
                                                              .withOpacity(0.60)
                                                          : AppColors.mako)
                                                  .s15,
                                              maxLines: 1,
                                              textAlign: TextAlign.center),
                                          const Icon(
                                            Icons.arrow_drop_down,
                                            color: AppColors.mako,
                                          ),
                                        ],
                                      ),
                                    ),
                                    CommonText(
                                        text: 'Availability.to'.tr(),
                                        style:
                                            Poppins.medium(AppColors.mako).s14,
                                        maxLines: 1,
                                        textAlign: TextAlign.center),
                                    CommonButton(
                                      borderColor:
                                          AppColors.mako.withOpacity(0.20),
                                      backgroundColor: AppColors.trans,
                                      onPressed: () {
                                        provider.requestTimePickerView(
                                            false, context);
                                      },
                                      borderRadius: 11,
                                      style: Poppins.bold(AppColors.mako).s16,
                                      minimumSize: 140,
                                      minimumWidget: 40,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          CommonText(
                                              text:
                                                  provider.endTimeRequest ?? '',
                                              style: Poppins.semiBold(
                                                      provider.specificTime
                                                          ? AppColors.mako
                                                              .withOpacity(0.60)
                                                          : AppColors.mako)
                                                  .s15,
                                              maxLines: 1,
                                              textAlign: TextAlign.center),
                                          const Icon(
                                            Icons.arrow_drop_down,
                                            color: AppColors.mako,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 19.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    provider.specificTime =
                                        !provider.specificTime;
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(provider.specificTime
                                          ? 'assets/icon/checkbox-on.svg'
                                          : "assets/icon/checkbox-off.svg"),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: CommonText(
                                          text: 'volunteer.specificTime'.tr(),
                                          maxLines: 3,
                                          style: Poppins.medium(AppColors.mako
                                                  .withOpacity(0.80))
                                              .s14,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /*volunteer list*/
                          Visibility(
                            visible: provider.newRequest3 &&
                                provider.newRequest1 &&
                                provider.newRequest2 &&
                                !provider.requestReview,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CommonText(
                                    text: 'volunteer.chooseVolunteer'.tr(),
                                    style: Poppins.semiBold(AppColors.mako).s16,
                                    maxLines: 1,
                                    textAlign: TextAlign.start),
                                const SizedBox(
                                  height: 11,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: TextFormField_Common(
                                    textEditingController:
                                        provider.searchController,
                                    contentPadding: 16,
                                    textStyle:
                                        Poppins.semiBold(AppColors.mako).s15,
                                    onChanged: (String? value) {
                                      provider.searchVolunteer(value!);
                                    },
                                    hintText: 'volunteer.search'.tr(),
                                    textInputType: TextInputType.text,
                                    maxLines: 1,
                                    borderRadius: 14.0,
                                    width: 50,
                                    prefixIcon: SvgPicture.asset(
                                      'assets/icon/search.svg',
                                      color: AppColors.mako,
                                    ),
                                    obscureText: false,
                                    textColor: AppColors.mako,
                                    textStyleHint:
                                        Poppins.medium(AppColors.silver).s14,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16.46,
                                ),
                                VolunteersWidget(
                                  volunteersList: provider.volunteersList,
                                  scroll: false,
                                  tab: (int index) {
                                    provider.selectedIndex = index;
                                    provider.resetScreenCall = false;
                                    provider.addNewRequest = true;

                                    Navigator.pushNamed(
                                        context, VolunteersProfileScreen.route);
                                  },
                                ),
                              ],
                            ),
                          ),
                          /*create request*/
                          Visibility(
                            visible: provider.newRequest3 &&
                                provider.newRequest1 &&
                                provider.newRequest2 &&
                                provider.requestReview,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(provider
                                                      .volunteersList.isNotEmpty
                                                  ? provider.selectedIndex !=
                                                          null
                                                      ? provider
                                                              .volunteersList[
                                                                  provider
                                                                      .selectedIndex!]
                                                              .image ??
                                                          ''
                                                      : ''
                                                  : ''),
                                              radius: 85,
                                              backgroundColor:
                                                  AppColors.madison,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                color: AppColors.madison,
                                                // shape: BoxShape.circle,
                                                borderRadius:
                                                    BorderRadius.circular(35),
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
                                                  provider.serviceAndNeedModel !=
                                                          null
                                                      ? provider
                                                          .serviceAndNeedModel!
                                                          .icon!
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        CommonText(
                                          text: provider
                                                  .volunteersList.isNotEmpty
                                              ? provider.selectedIndex != null
                                                  ? provider
                                                      .volunteersList[provider
                                                          .selectedIndex!]
                                                      .name
                                                  : ''
                                              : '',
                                          style:
                                              Poppins.bold(AppColors.mako).s18,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 7.0),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icon/rate-on.svg',
                                                width: 13.99,
                                                height: 14.01,
                                              ),
                                              const SizedBox(
                                                width: 6.01,
                                              ),
                                              CommonText(
                                                text: provider.volunteersList
                                                        .isNotEmpty
                                                    ? provider.selectedIndex !=
                                                            null
                                                        ? '${provider.volunteersList[provider.selectedIndex!].historyData != null && provider.volunteersList[provider.selectedIndex!].historyData!.isNotEmpty ? provider.ratingCount(provider.volunteersList[provider.selectedIndex!].historyData).toStringAsFixed(2) : 0}'
                                                        : ''
                                                    : '',
                                                style:
                                                    Poppins.bold(AppColors.mako)
                                                        .s14,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 24.0,
                                ),
                                CommonText(
                                    text: 'volunteer.service'.tr(),
                                    style:
                                        Poppins.medium(AppColors.baliHai).s12,
                                    maxLines: 1,
                                    textAlign: TextAlign.start),
                                CommonText(
                                    text: provider.serviceAndNeedModel != null
                                        ? provider.capitalize(provider
                                            .serviceAndNeedModel!.title!)
                                        : '',
                                    style: Poppins.semiBold(AppColors.mako).s16,
                                    maxLines: 1,
                                    textAlign: TextAlign.start),
                                const SizedBox(height: 36.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          CommonText(
                                              text: 'volunteer.date'.tr(),
                                              style: Poppins.medium(
                                                      AppColors.baliHai)
                                                  .s12,
                                              maxLines: 1,
                                              textAlign: TextAlign.start),
                                          CommonText(
                                              text:
                                                  provider.dobController!.text,
                                              style: Poppins.semiBold(
                                                      AppColors.mako)
                                                  .s16,
                                              maxLines: 1,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          CommonText(
                                              text: 'volunteer.time'.tr(),
                                              style: Poppins.medium(
                                                      AppColors.baliHai)
                                                  .s12,
                                              maxLines: 1,
                                              textAlign: TextAlign.start),
                                          CommonText(
                                              text: !provider.specificTime
                                                  ? "${provider.startTimeRequest ?? ''} - ${provider.endTimeRequest ?? ''}"
                                                  : 'volunteer.specificTime'
                                                      .tr(),
                                              style: provider.specificTime
                                                  ? Poppins.medium(
                                                          AppColors.mako)
                                                      .s16
                                                  : Poppins.semiBold(
                                                          AppColors.mako)
                                                      .s16,
                                              maxLines: 10,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 36.0),
                                CommonText(
                                    text: 'volunteer.importantNotes'.tr(),
                                    style:
                                        Poppins.medium(AppColors.baliHai).s12,
                                    maxLines: 1,
                                    textAlign: TextAlign.start),
                                const SizedBox(height: 7.0),
                                TextFormField_Common(
                                  contentPadding: 16,
                                  textStyle: Poppins.medium(AppColors.mako).s15,
                                  onChanged: (String? value) {
                                    provider.typeHereFiled = value;
                                  },
                                  errorText: context
                                      .select<VolunteerViewModel, String?>(
                                    (VolunteerViewModel state) =>
                                        state.typeHereError,
                                  ),
                                  hintText: 'volunteer.typeHere'.tr(),
                                  textInputType: TextInputType.text,
                                  maxLines: 5,
                                  contentPaddingTop: 11.0,
                                  obscureText: false,
                                  textColor: AppColors.mako,
                                  borderRadius: 8.0,
                                  textStyleHint: Poppins.regular(
                                    AppColors.mako.withOpacity(0.50),
                                  ).s15,
                                ),
                                const SizedBox(height: 14.0),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: SvgPicture.asset(
                                          'assets/icon/info.svg',
                                          height: 15,
                                          width: 15,
                                          color:
                                              AppColors.mako.withOpacity(0.80),
                                        ),
                                      ),
                                      const WidgetSpan(
                                        child: SizedBox(
                                          width: 5,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'volunteer.requestAccepted'.tr(),
                                        style: Poppins.medium(AppColors.mako
                                                .withOpacity(0.80))
                                            .s14,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 24.17,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CommonButton(
                    borderColor: provider.newRequest1
                        ? AppColors.madison.withOpacity(0.08)
                        : AppColors.madison.withOpacity(0.40),
                    backgroundColor: provider.newRequest1
                        ? AppColors.madison.withOpacity(0.08)
                        : AppColors.trans,
                    onPressed: () {
                      if (provider.requestReview) {
                        provider.requestReview = false;
                      } else if (provider.newRequest3) {
                        provider.newRequest3 = false;
                      } else if (provider.newRequest2) {
                        provider.newRequest2 = false;
                      } else {
                        provider.back(true);
                      }
                    },
                    borderRadius: 27.0,
                    buttonText: provider.newRequest1
                        ? 'login.back'.tr()
                        : 'login.cancel'.tr(),
                    style: Poppins.bold(AppColors.madison).s14,
                    minimumSize: 145,
                    minimumWidget: 52,
                  ),
                  CommonButton(
                    borderColor: AppColors.trans,
                    backgroundColor: provider.requestReview
                        ? AppColors.madison
                        : AppColors.madison.withOpacity(0.08),
                    onPressed: () {
                      if (provider.requestReview) {
                        provider.sendRequest(1);
                      } else if (provider.newRequest3) {
                        Alert.showSnackBar(
                            context, 'request.selectVolunteer'.tr());
                      } else if (provider.newRequest2) {
                        provider.getVolunteerListData();

                        provider.newRequest3 = true;
                      } else if (provider.newRequest1) {
                        provider.newRequest2 = true;
                      } else {
                        provider.newRequest1 = true;
                      }
                    },
                    borderRadius: 27.0,
                    buttonText: provider.requestReview
                        ? 'volunteer.send'.tr()
                        : 'login.next'.tr(),
                    style: Poppins.bold(provider.requestReview
                            ? AppColors.white
                            : AppColors.madison)
                        .s14,
                    minimumSize: 145,
                    minimumWidget: 52,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
