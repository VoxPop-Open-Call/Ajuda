import 'package:ajuda/Ui/Utils/commanWidget/CommonButton.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/widget/upcoming_services_widget.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/PendingRequestUi/pading_request_screen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RequestDetailUi/request_details_screen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestViewModel.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/volunteerViewModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../data/local/shared_pref_helper.dart';
import '../../../main.dart';
import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../HomeUi/widget/upcoming_services_volunteer_widget.dart';
import '../VolunteersUi/NewRequestScreen/newRequestStepScreen.dart';
import 'RateUsUi/reateUsScreen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({Key? key}) : super(key: key);

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> with RouteAware {
  @override
  void dispose() {
    print("dispose $widget");
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
      //Subscribe it here
    });
    withViewModel<RequestViewModel>(context, (viewModel) {
      viewModel.volunteerViewModel =
          Provider.of<VolunteerViewModel>(context, listen: false);
      viewModel.selectButton = false;
      if (SharedPrefHelper.userType == '2') {
        viewModel.getPendingList();
      }

      if (viewModel.selectButton) {
        viewModel.getCompleteList();
      } else {
        viewModel.getUpcomingList();
      }
    });
  }

  @override
  void didPopNext() {
    withViewModel<RequestViewModel>(context, (viewModel) {
      viewModel.volunteerViewModel =
          Provider.of<VolunteerViewModel>(context, listen: false);
      if (SharedPrefHelper.userType == '2') {
        viewModel.getPendingList();
      }
      if (SharedPrefHelper.userType == '1') {
        if (viewModel.selectButton) {
          viewModel.getCompleteList();
        } else {
          viewModel.getUpcomingList();
        }
      }
    });
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestViewModel>();

    return BaseScreen<RequestViewModel>(
      color: AppColors.porcelain,
      child: Padding(
        padding: EdgeInsets.only(
          top: SharedPrefHelper.userType == '1' ? 45 : 0,
          right: 0,
          left: 0,
          bottom: 31,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (SharedPrefHelper.userType == '1')
              Padding(
                padding: const EdgeInsets.only(
                  right: 22,
                  left: 22,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, NewRequestStepScreen.route);
                      },
                      child: SvgPicture.asset(
                        'assets/icon/add.svg',
                        height: 36,
                        width: 36,
                      ),
                    )
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.only(left: 22, right: 22, top: 45),
              margin: EdgeInsets.only(bottom: provider.openCalender ? 32 : 0),
              color: provider.openCalender ? AppColors.white : AppColors.trans,
              child: Column(
                children: <Widget>[
                  if (SharedPrefHelper.userType == '2')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        provider.openCalender
                            ? CommonText(
                                text: DateFormat('MMMM, yyyy')
                                    .format(provider.focusedDay),
                                style: Poppins.medium(AppColors.madison).s16,
                                maxLines: 1,
                                textAlign: TextAlign.start)
                            : const SizedBox.shrink(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, PendingRequestScreen.route);
                              },
                              child: SizedBox(
                                height: 40,
                                width: 38,
                                child: Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        height: 36,
                                        width: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.baliHai
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.notifications_none_outlined,
                                            color: AppColors.baliHai,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        height: 18,
                                        width: 18,
                                        decoration: const BoxDecoration(
                                            color: AppColors.bittersweet,
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: CommonText(
                                            text: provider
                                                .pendingListData.length
                                                .toString(),
                                            style: Poppins.bold(AppColors.white)
                                                .s12,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                provider.openCalender = !provider.openCalender;
                                provider.selectButton = false;
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 13),
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.madison,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Center(
                                  child: Icon(
                                    provider.openCalender
                                        ? Icons.list
                                        : Icons.calendar_today_outlined,
                                    color: AppColors.white,
                                    size: provider.openCalender ? 25 : 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (provider.openCalender)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime(DateTime.now().year + 100),
                        focusedDay: provider.focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          // Use `selectedDayPredicate` to determine which day is currently selected.
                          // If this returns true, then `day` will be marked as selected.

                          // Using `isSameDay` is recommended to disregard
                          // the time-part of compared DateTime objects.
                          return isSameDay(provider.selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(provider.selectedDay, selectedDay)) {
                            // Call `setState()` when updating the selected day
                            setState(() {
                              provider.selectedDay = selectedDay;
                              provider.focusedDay = focusedDay;
                            });
                          }
                        },
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            // Call `setState()` when updating calendar format
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          // No need to call `setState()` here
                          print(focusedDay);
                          provider.focusedDay = focusedDay;
                        },
                        headerVisible: false,
                        daysOfWeekStyle: DaysOfWeekStyle(
                          dowTextFormatter: (date, locale) =>
                              DateFormat.E(locale).format(date)[0],
                          weekdayStyle:
                              Poppins.semiBold(AppColors.mako.withOpacity(0.50))
                                  .s11,
                          weekendStyle:
                              Poppins.semiBold(AppColors.mako.withOpacity(0.50))
                                  .s11,
                        ),
                        startingDayOfWeek: StartingDayOfWeek.monday,

                        // eventLoader: provider.getEventsForDay,

                        calendarStyle: CalendarStyle(
                          disabledTextStyle:
                              Poppins.semiBold(AppColors.mako.withOpacity(0.30))
                                  .s16,
                          todayDecoration: BoxDecoration(
                            color: AppColors.madison.withOpacity(0.80),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: AppColors.bittersweet,
                            shape: BoxShape.circle,
                          ),
                          markerSize: 4.0,
                          markersAlignment: Alignment.topCenter,
                          markerMargin:
                              const EdgeInsets.only(right: 0.4, top: 0),
                          weekendTextStyle:
                              Poppins.semiBold(AppColors.mako).s16,
                          outsideTextStyle:
                              Poppins.semiBold(AppColors.mako.withOpacity(0.30))
                                  .s16,
                          defaultTextStyle:
                              Poppins.semiBold(AppColors.mako).s16,
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.madison,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // calendarStyle: CalendarStyle(),
                      ),
                    ),
                ],
              ),
            ),
            if (!provider.openCalender)
              Padding(
                padding: const EdgeInsets.only(
                    top: 19.0, right: 33.0, left: 33.0, bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CommonButton(
                      borderColor: AppColors.mako.withOpacity(0.20),
                      backgroundColor: provider.selectButton
                          ? AppColors.trans
                          : AppColors.bittersweet,
                      onPressed: () {
                        provider.selectButton = false;
                        provider.getUpcomingList();
                      },
                      borderRadius: 22.0,
                      style: provider.selectButton
                          ? Poppins.semiBold(AppColors.mako.withOpacity(0.80))
                              .s12
                          : Poppins.bold(AppColors.white).s12,
                      minimumSize: 144,
                      minimumWidget: 44,
                      buttonText: 'request.upcoming'.tr(),
                    ),
                    CommonButton(
                      borderColor: AppColors.mako.withOpacity(0.20),
                      backgroundColor: provider.selectButton
                          ? AppColors.bittersweet
                          : AppColors.trans,
                      onPressed: () {
                        provider.selectButton = true;
                        provider.getCompleteList();
                      },
                      borderRadius: 22.0,
                      style: provider.selectButton
                          ? Poppins.bold(AppColors.white).s12
                          : Poppins.semiBold(AppColors.mako.withOpacity(0.80))
                              .s12,
                      minimumSize: 144,
                      minimumWidget: 44,
                      buttonText: 'request.completed'.tr(),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 22,
                  left: 22,
                ),
                child: provider.selectButton
                    ? provider.completeListData.isEmpty
                        ? Center(
                            child: CommonText(
                                text: 'errorMessage.not_data'.tr(),
                                style:
                                    Poppins.semiBold(AppColors.bittersweet).s15,
                                maxLines: 2,
                                textAlign: TextAlign.center),
                          )
                        : getData(context)
                    : provider.upcomingListData.isEmpty
                        ? Center(
                            child: CommonText(
                                text: 'errorMessage.not_data'.tr(),
                                style:
                                    Poppins.semiBold(AppColors.bittersweet).s15,
                                maxLines: 2,
                                textAlign: TextAlign.center),
                          )
                        : getData(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getData(ctx) {
    final provider = context.read<RequestViewModel>();
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: provider.selectButton
          ? provider.completeListData.length
          : provider.upcomingListData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: SharedPrefHelper.userType == '1'
              ? UpcomingServicesWidget(
                  calender: provider.openCalender,
                  type: provider.openCalender ? false : provider.selectButton,
                  upcomingList: provider.selectButton
                      ? provider.completeListData[index]
                      : provider.upcomingListData[index],
                  tab: provider.openCalender
                      ? () {}
                      : () {
                          provider.comAndUpIndex = index;
                          Navigator.pushNamed(
                              context,
                              provider.selectButton
                                  ? RateUsScreen.route
                                  : RequestDetailScreen.route);
                        },
                )
              : UpcomingServicesVolunteerWidget(
                  calender: provider.openCalender,
                  type: provider.openCalender ? false : provider.selectButton,
                  upcomingList: provider.selectButton
                      ? provider.completeListData[index]
                      : provider.upcomingListData[index],
                  tab: provider.openCalender
                      ? () {}
                      : () {
                          provider.comAndUpIndex = index;
                          Navigator.pushNamed(
                              context,
                              provider.selectButton
                                  ? RateUsScreen.route
                                  : RequestDetailScreen.route);
                        },
                ),
        );
      },
    );
  }
}
