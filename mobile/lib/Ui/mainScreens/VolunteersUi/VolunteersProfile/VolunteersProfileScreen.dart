import 'package:ajuda/Ui/Utils/commanWidget/CommonButton.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/VolunteersProfile/widget/volunteer_peofile_widget.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/volunteerViewModel.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';
import '../../../Utils/view_model.dart';
import '../../ProfileUi/History_Screen/widget/history_screen_widget.dart';
import '../NewRequestScreen/new_request_screen.dart';

class VolunteersProfileScreen extends StatefulWidget {
  static const String route = "VolunteersProfileScreen";

  const VolunteersProfileScreen({Key? key}) : super(key: key);

  @override
  State<VolunteersProfileScreen> createState() =>
      _VolunteersProfileScreenState();
}

class _VolunteersProfileScreenState extends State<VolunteersProfileScreen> {
  @override
  void initState() {
    withViewModel<VolunteerViewModel>(context, (viewModel) {
      viewModel.getGeoLocationPosition();
      viewModel.addImageHistoryUser();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VolunteerViewModel>();

    return BaseScreen<VolunteerViewModel>(
      color: AppColors.white,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 31),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*image */
            SizedBox(
              height: 250,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Stack(
                children: <Widget>[
                  provider.selectedIndex != null &&
                      provider.volunteersList[provider.selectedIndex!]
                          .image !=
                          null
                      ? Image.network(
                    provider
                        .volunteersList[provider.selectedIndex!].image,
                    fit: BoxFit.cover,
                    height: 250,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                  )
                      : Image.asset(
                    'assets/images/Rectangle.png',
                    fit: BoxFit.cover,
                    height: 250,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 46.5, left: 15.0),
                      child: Container(
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
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 14.0, right: 20, left: 20, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /*about dynamic*/
                  CommonText(
                      text:
                      provider.volunteersList[provider.selectedIndex!].name,
                      style: Poppins
                          .bold(AppColors.bittersweet)
                          .s22,
                      maxLines: 1,
                      textAlign: TextAlign.start),
                  CommonText(
                      text:
                      '${"request.volunteerSince".tr()} ${DateFormat(
                          'MMM, yyyy').format(DateTime.parse(
                          provider.volunteersList[provider.selectedIndex!]
                              .createdAt))}',
                      style:
                      Poppins
                          .medium(AppColors.mako.withOpacity(0.80))
                          .s15,
                      maxLines: 1,
                      textAlign: TextAlign.start),

                  /*rating, review*/
                  Row(
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/icon/rate-on.svg',
                        width: 13.99,
                        height: 14.01,
                      ),
                      const SizedBox(
                        width: 6.01,
                      ),
                      CommonText(
                        text:
                        '${provider.volunteersList[provider.selectedIndex!]
                            .historyData != null &&
                            provider.volunteersList[provider.selectedIndex!]
                                .historyData!.isNotEmpty ? provider.ratingCount(
                            provider.volunteersList[provider.selectedIndex!]
                                .historyData).toStringAsFixed(2) : 0}',
                        style: Poppins
                            .bold(AppColors.mako)
                            .s14,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        width: 14.0,
                      ),
                      CommonText(
                          text:
                          '( ${provider.volunteersList[provider.selectedIndex!]
                              .historyData?.length ?? 0} ${'volunteer.review'
                              .tr()})',
                          style:
                          Poppins
                              .medium(AppColors.mako.withOpacity(0.60))
                              .s14,
                          maxLines: 1,
                          textAlign: TextAlign.center)
                    ],
                  ),
                  const SizedBox(
                    height: 19.0,
                  ),

                  /*choose*/
                  CommonButton(
                    borderColor: AppColors.madison,
                    backgroundColor: AppColors.madison,
                    onPressed: () {
                      if (!provider.addNewRequest) {
                        if (provider.resetScreenCall) {
                          provider.newRequest1 = true;
                          provider.newRequest2 = true;
                        } else {
                          provider.newRequest1 = true;
                        }
                        Navigator.pushNamed(context, NewRequestScreen.route);
                      } else {
                        provider.requestReview = true;
                        Navigator.of(context).pop();
                      }
                    },
                    borderRadius: 17.0,
                    style: Poppins
                        .semiBold()
                        .s16,
                    minimumWidget: 52,
                    minimumSize: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CommonText(
                            text: 'volunteer.chooseThisVolunteer'.tr(),
                            style: Poppins
                                .bold(AppColors.white)
                                .s14,
                            maxLines: 1,
                            textAlign: TextAlign.start),
                        SvgPicture.asset(
                          'assets/icon/arrow.svg',
                          width: 13,
                          height: 10.82,
                          color: AppColors.white,
                        )
                      ],
                    ),
                  ),

                  /*MAP*/
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                    ),
                    child: CommonText(
                        text: 'volunteer.areaOfActivity'.tr(),
                        style: Poppins
                            .semiBold(AppColors.mako)
                            .s16,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 23.5, top: 10),
                    child: SizedBox(
                      height: 160,
                      width: 325,
                      child: GoogleMap(
                        markers: Set<Marker>.of(provider.markers.values),
                        mapType: MapType.normal,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        initialCameraPosition: provider.initialLocation,
                        onMapCreated: (GoogleMapController controller) {
                          if (controller != null) {
                            provider.mapController = controller;
                          }
                        },
                        // circles: provider
                        //             .volunteersList[provider.selectedIndex!]
                        //             .location !=
                        //         null
                        //     ? {
                        //         Circle(
                        //           circleId: CircleId('currentCircle'),
                        //           center: LatLng(
                        //               provider
                        //                   .volunteersList[
                        //                       provider.selectedIndex!]
                        //                   .location['lat'],
                        //               provider
                        //                   .volunteersList[
                        //                       provider.selectedIndex!]
                        //                   .location['long']),
                        //           radius: double.parse(provider
                        //               .volunteersList[provider.selectedIndex!]
                        //               .location['radius']
                        //               .toString()),
                        //           fillColor:
                        //               AppColors.bittersweet.withOpacity(0.05),
                        //           strokeColor:
                        //               AppColors.bittersweet.withOpacity(0.05),
                        //           strokeWidth: 2,
                        //         ),
                        //       }
                        //     : {},
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: AppColors.seashell,
                  ),

                  /*Availability dynamic*/
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 23.5,
                    ),
                    child: CommonText(
                        text: 'volunteer.availability'.tr(),
                        style: Poppins
                            .semiBold(AppColors.mako)
                            .s16,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        top: 24.0,
                        right: MediaQuery
                            .of(context)
                            .size
                            .width * 0.11,
                        bottom: 24),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.volunteersList[provider.selectedIndex!]
                        .volunteer['availabilities'].length,
                    itemBuilder: (context, index) {
                      return VolunteersProfileWidget(
                        weekDay: provider
                            .volunteersList[provider.selectedIndex!]
                            .volunteer['availabilities'][index],
                      );
                    },
                  ),
                  const Divider(
                    thickness: 2,
                    color: AppColors.seashell,
                  ),

                  /*Services Provided dynamic*/
                  Padding(
                    padding: const EdgeInsets.only(top: 23.5, bottom: 7.5),
                    child: CommonText(
                        text: 'onBoarding.servicesProvided'.tr(),
                        style: Poppins
                            .semiBold(AppColors.mako)
                            .s16,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 7.5, bottom: 24),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 3),
                    itemCount: provider.volunteersList[provider.selectedIndex!]
                        .volunteer['taskTypes'].length,
                    itemBuilder: (context, ind) {
                      return Container(
                        padding: const EdgeInsets.only(
                            top: 7.0, bottom: 7.0, right: 0.0, left: 0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: AppColors.madison.withOpacity(0.10),
                          border: Border.all(
                            color: AppColors.madison.withOpacity(0.10),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: CommonText(
                            text: /*provider.capitalize(provider
                                .volunteersList[provider.selectedIndex!]
                                .volunteer['taskTypes'][ind]['code']),*/
                            'servicesNeeds.${provider.volunteersList[provider
                                .selectedIndex!]
                                .volunteer['taskTypes'][ind]['code']}'
                                .tr(),
                            style: Poppins
                                .semiBold(AppColors.madison)
                                .s11,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      );
                    },
                  ),
                  if (!provider.resetScreenCall)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 24.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: SvgPicture.asset(
                                'assets/icon/info.svg',
                                height: 15,
                                width: 15,
                                color: AppColors.mako.withOpacity(0.80),
                              ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(
                                width: 5,
                              ),
                            ),
                            TextSpan(
                              text: 'volunteer.requestAccepted'.tr(),
                              style: Poppins
                                  .medium(
                                  AppColors.mako.withOpacity(0.80))
                                  .s14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(
                    thickness: 2,
                    color: AppColors.seashell,
                  ),

                  /*languages Spoken*/
                  Padding(
                    padding: const EdgeInsets.only(top: 23.5, bottom: 7.5),
                    child: CommonText(
                        text: 'language.languagesSpoken'.tr(),
                        style: Poppins
                            .semiBold(AppColors.mako)
                            .s16,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 7.5, bottom: 0),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1),
                    itemCount: provider.volunteersList[provider.selectedIndex!]
                        .languages.length,
                    itemBuilder: (context, ind) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleFlag(
                              provider.volunteersList[provider.selectedIndex!]
                                  .languages[ind].id ==
                                  'en'
                                  ? 'gb'
                                  : provider
                                  .volunteersList[provider.selectedIndex!]
                                  .languages[ind]
                                  .id,
                              size: 34.99),
                          const SizedBox(
                            height: 4.01,
                          ),
                          Center(
                            child: CommonText(
                              text: /*provider
                                  .volunteersList[provider.selectedIndex!]
                                  .languages[ind]
                                  .title*/
                              ('language.${provider
                                  .volunteersList[provider.selectedIndex!]
                                  .languages[ind].id}').tr()
                              ,
                              style: Poppins
                                  .medium(
                                  AppColors.madison.withOpacity(0.50))
                                  .s11,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(
                    thickness: 2,
                    color: AppColors.seashell,
                  ),

                  /*History*/
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 28),
                    child: CommonText(
                        text: 'onBoarding.history'.tr(),
                        style: Poppins
                            .semiBold(AppColors.mako)
                            .s16,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.volunteersList[provider.selectedIndex!]
                        .historyData?.length ??
                        0,
                    itemBuilder: (context, index) {
                      return HistoryScreenWidget(
                        activityName: provider
                            .volunteersList[provider.selectedIndex!]
                            .historyData[index]
                            .task
                            .taskType
                            .title,
                        dateTime:
                        '${DateFormat('MMM dd, yyyy')
                            .format(DateTime.parse(
                            provider.volunteersList[provider.selectedIndex!]
                                .historyData[index].task.date!))
                            .toString()} • ${provider.volunteersList[provider
                            .selectedIndex!].historyData[index].task.timeFrom !=
                            null
                            ? '${DateFormat('hh:mm').format(DateFormat('hh:mm')
                            .parse(
                            provider.volunteersList[provider.selectedIndex!]
                                .historyData[index].task.timeFrom!)
                            .toUtc())} • ${DateFormat('hh:mm').format(
                            DateFormat('hh:mm').parse(
                                provider.volunteersList[provider.selectedIndex!]
                                    .historyData[index].task.timeTo!).toUtc())}'
                            : 'any'.tr()}',
                        image: provider.volunteersList[provider.selectedIndex!]
                            .historyData[index].task.requester.image ??
                            '',
                        name: provider.volunteersList[provider.selectedIndex!]
                            .historyData[index].task.requester.name ??
                            '',
                        comment: provider
                            .volunteersList[provider.selectedIndex!]
                            .historyData[index]
                            .comment,
                        rating: double.parse(provider
                            .volunteersList[provider.selectedIndex!]
                            .historyData[index]
                            .rating!),
                      );
                    },
                  ),

                  /*Joined dynamic*/
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
                              text: 'request.joined'.tr(),
                              style:
                              Poppins
                                  .semiBold(AppColors.bittersweet)
                                  .s15,
                              maxLines: 1,
                              textAlign: TextAlign.start),
                          CommonText(
                              text: DateFormat('MMM, yyyy').format(
                                  DateTime.parse(provider
                                      .volunteersList[provider.selectedIndex!]
                                      .createdAt)),
                              style: Poppins
                                  .regular(AppColors.baliHai)
                                  .s12,
                              maxLines: 1,
                              textAlign: TextAlign.start),
                        ],
                      ),
                    ],
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
