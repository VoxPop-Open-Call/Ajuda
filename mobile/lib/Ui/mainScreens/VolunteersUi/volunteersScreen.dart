import 'package:ajuda/Ui/Utils/commanWidget/CommonButton.dart';
import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/VolunteersProfile/VolunteersProfileScreen.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/volunteerViewModel.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/widget/volunteers_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/textform_field.dart';
import '../../Utils/theme/appcolor.dart';

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({Key? key}) : super(key: key);

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    withViewModel<VolunteerViewModel>(context, (viewModel) async {
      // viewModel.startTime = DateFormat('h:mm a').format(DateTime.now());
      // viewModel.endTime = DateFormat('h:mm a').format(DateTime.now());
      await viewModel.getService();
      await viewModel.getVolunteerListWithFilter();
    });
    initializeDateFormatting().then((_) {
      final dateFormat = DateFormat.yMd('en_AU');
      print(dateFormat.format(DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VolunteerViewModel>();
    return BaseScreen<VolunteerViewModel>(
      color: AppColors.white,
      bottomSheet: provider.openBottomSheet
          ? BottomSheet(
              elevation: 10,
              backgroundColor: AppColors.black.withOpacity(0.60),
              enableDrag: false,
              onClosing: () {
                provider.openBottomSheet = false;
              },
              builder: (BuildContext ctx) => bottomSheet(ctx),
            )
          : null,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 45, right: 22, left: 22, bottom: 12.87),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonText(
                text: 'volunteer.volunteers'.tr(),
                style: Poppins.bold(AppColors.madison).s22,
                maxLines: 1,
                textAlign: TextAlign.left),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 12.0),
              child: CommonText(
                  text: 'volunteer.volunteerThatBestSuit'.tr(),
                  style: Poppins.medium(AppColors.mako).s13,
                  maxLines: 4,
                  textAlign: TextAlign.left),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 6,
                  child: TextFormField_Common(
                    textEditingController: provider.searchController,
                    contentPadding: 16,
                    textStyle: Poppins.semiBold(AppColors.mako).s15,
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
                    textStyleHint: Poppins.medium(AppColors.silver).s14,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 9.0),
                    child: InkWell(
                      onTap: () {
                        provider.openBottomSheet = true;
                      },
                      child: SvgPicture.asset(
                        'assets/icon/filter.svg',
                        height: 36,
                        width: 36,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: VolunteersWidget(
                volunteersList: provider.volunteersList,
                scroll: false,
                tab: (int index) {
                  provider.selectedIndex = index;
                  provider.resetScreenCall = false;
                  provider.addNewRequest = false;

                  Navigator.pushNamed(context, VolunteersProfileScreen.route);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bottomSheet(BuildContext context) {
    return Container(
      height: double.infinity,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 39.0),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          color: AppColors.white),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*close-button and title*/
            Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, right: 25.0, bottom: 15.0, top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      context.read<VolunteerViewModel>().openBottomSheet =
                          false;
                    },
                    child: SvgPicture.asset(
                      'assets/icon/close.svg',
                      width: 14,
                      height: 14.01,
                    ),
                  ),
                  CommonText(
                      text: 'volunteer.filters'.tr(),
                      style: Poppins.bold(AppColors.madison).s18,
                      maxLines: 1,
                      textAlign: TextAlign.center),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
            const Divider(
              thickness: 2,
              color: AppColors.seashell,
            ),

            /*serviceType*/
            Padding(
              padding:
                  const EdgeInsets.only(top: 27.5, left: 25.0, bottom: 7.0),
              child: CommonText(
                text: 'volunteer.serviceType'.tr(),
                style: Poppins.semiBold(AppColors.mako).s16,
                maxLines: 1,
                textAlign: TextAlign.left,
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 0, right: 20, left: 20),
              itemCount:
                  context.watch<VolunteerViewModel>().desiredServices.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    context
                        .read<VolunteerViewModel>()
                        .selectService(true, index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0, top: 14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context
                                        .watch<VolunteerViewModel>()
                                        .desiredServices[index]
                                        .select
                                    ? AppColors.bittersweet.withOpacity(0.10)
                                    : AppColors.mako.withOpacity(0.10),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  context
                                      .watch<VolunteerViewModel>()
                                      .desiredServices[index]
                                      .icon!,
                                  height: 18.22,
                                  width: 18.15,
                                  color: context
                                          .watch<VolunteerViewModel>()
                                          .desiredServices[index]
                                          .select
                                      ? AppColors.bittersweet
                                      : AppColors.mako,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16.35,
                            ),
                            CommonText(
                              text:
                                  'servicesNeeds.${context.watch<VolunteerViewModel>().desiredServices[index].title!}'
                                      .tr(),
                              textAlign: TextAlign.left,
                              style: Poppins.medium(context
                                          .watch<VolunteerViewModel>()
                                          .desiredServices[index]
                                          .select
                                      ? AppColors.bittersweet
                                      : AppColors.mako)
                                  .s14,
                              maxLines: 1,
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          context
                                  .watch<VolunteerViewModel>()
                                  .desiredServices[index]
                                  .select
                              ? 'assets/icon/checkbox-on.svg'
                              : "assets/icon/checkbox-off.svg",
                          height: 26,
                          width: 26,
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  thickness: 1,
                  color: AppColors.seashell,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 22, left: 25),
              child: CommonText(
                text: 'volunteer.availability'.tr(),
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),

            /*weekdays*/
            Padding(
              padding:
                  const EdgeInsets.only(left: 25.0, top: 2.0, bottom: 15.0),
              child: CommonText(
                text: 'volunteer.weekdays'.tr(),
                style: Poppins.regular(AppColors.mako.withOpacity(0.80)).s13,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 25, right: 25),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 3),
              itemCount: context.watch<VolunteerViewModel>().weekdays.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    context.read<VolunteerViewModel>().selectWeekDays(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 7.0, bottom: 7.0, right: 8.0, left: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17.0),
                      color: context
                              .watch<VolunteerViewModel>()
                              .weekdays[index]
                              .select
                          ? AppColors.bittersweet
                          : AppColors.trans,
                      border: Border.all(
                        color: context
                                .watch<VolunteerViewModel>()
                                .weekdays[index]
                                .select
                            ? AppColors.bittersweet
                            : AppColors.mako.withOpacity(0.20),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: CommonText(
                        text: context
                            .watch<VolunteerViewModel>()
                            .weekdays[index]
                            .title!
                            .tr(),
                        style: context
                                .watch<VolunteerViewModel>()
                                .weekdays[index]
                                .select
                            ? Poppins.semiBold(AppColors.white).s13
                            : Poppins.medium(AppColors.mako.withOpacity(0.80))
                                .s13,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),

            /*Hours*/
            Padding(
              padding: const EdgeInsets.only(
                  left: 25, right: 25, top: 32, bottom: 9),
              child: CommonText(
                  text: 'volunteer.Hours'.tr(),
                  style: Poppins.regular(AppColors.mako.withOpacity(0.80)).s13,
                  maxLines: 1,
                  textAlign: TextAlign.start),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 73.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CommonButton(
                    borderColor: AppColors.mako.withOpacity(0.20),
                    backgroundColor: AppColors.trans,
                    onPressed: () {
                      context
                          .read<VolunteerViewModel>()
                          .showTimePickerView(true, context);
                    },
                    borderRadius: 11,
                    style: Poppins.bold(AppColors.mako).s16,
                    minimumSize: 140,
                    minimumWidget: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        CommonText(
                            text:
                                context.watch<VolunteerViewModel>().startTime ??
                                    '00:00',
                            style:
                                context.watch<VolunteerViewModel>().startTime !=
                                        null
                                    ? Poppins.bold(AppColors.mako).s16
                                    : Poppins.medium(
                                            AppColors.mako.withOpacity(0.50))
                                        .s16,
                            maxLines: 1,
                            textAlign: TextAlign.center),
                        Icon(
                          Icons.arrow_drop_down,
                          color:
                              context.watch<VolunteerViewModel>().startTime !=
                                      null
                                  ? AppColors.mako
                                  : AppColors.mako.withOpacity(0.50),
                        ),
                      ],
                    ),
                  ),
                  CommonText(
                      text: 'Availability.to'.tr(),
                      style: Poppins.medium(AppColors.mako).s14,
                      maxLines: 1,
                      textAlign: TextAlign.center),
                  CommonButton(
                    borderColor: AppColors.mako.withOpacity(0.20),
                    backgroundColor: AppColors.trans,
                    onPressed: () {
                      context
                          .read<VolunteerViewModel>()
                          .showTimePickerView(false, context);
                    },
                    borderRadius: 11,
                    style: Poppins.bold(AppColors.mako).s16,
                    minimumSize: 140,
                    minimumWidget: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        CommonText(
                            text: context.watch<VolunteerViewModel>().endTime ??
                                '00:00',
                            style:
                                context.watch<VolunteerViewModel>().endTime !=
                                        null
                                    ? Poppins.bold(AppColors.mako).s16
                                    : Poppins.medium(
                                            AppColors.mako.withOpacity(0.50))
                                        .s16,
                            maxLines: 1,
                            textAlign: TextAlign.center),
                        Icon(
                          Icons.arrow_drop_down,
                          color: context.watch<VolunteerViewModel>().endTime !=
                                  null
                              ? AppColors.mako
                              : AppColors.mako.withOpacity(0.50),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /*clear-save*/
            Padding(
              padding:
                  const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CommonButton(
                    borderColor: AppColors.madison.withOpacity(0.20),
                    backgroundColor: AppColors.trans,
                    onPressed: () {
                      context.read<VolunteerViewModel>().clearFilter();
                    },
                    borderRadius: 16,
                    style: Poppins.semiBold(AppColors.madison).s16,
                    minimumSize: 140.03,
                    minimumWidget: 47,
                    buttonText: 'volunteer.clearFilter'.tr(),
                  ),
                  CommonButton(
                    borderColor: AppColors.madison,
                    backgroundColor: AppColors.madison,
                    onPressed: () async {
                      context.read<VolunteerViewModel>().openBottomSheet =
                          false;

                      await context
                          .read<VolunteerViewModel>()
                          .getVolunteerListWithFilter();
                    },
                    borderRadius: 16,
                    style: Poppins.semiBold(AppColors.white).s16,
                    minimumSize: 140.03,
                    minimumWidget: 47,
                    buttonText: 'volunteer.save'.tr(),
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
