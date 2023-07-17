import 'package:ajuda/Ui/authScreens/signup/widget/availability_widget.dart';
import 'package:ajuda/Ui/bottombarScreen/HomeMainScreen.dart';
import 'package:ajuda/my_app.dart';
import 'package:ajuda/route_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Utils/alert.dart';
import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/CommonButton.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../auth_view_model.dart';

class AvailabilityScreen extends StatefulWidget {
  static const String route = "AvailabilityScreen";

  const AvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  @override
  initState() {
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.profileUpdate = () {
      changeIndex.value = 0;
      changeIndex.notifyListeners();
      Alert.showSnackBarSuccess(
          navigatorKey.currentContext!, provider.snackBarText!);
      Navigator.pushNamedAndRemoveUntil(
          context, HomeMainScreen.route, (route) => false);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*languagesSpoken*/
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 5.0),
              child: CommonText(
                text: 'Availability.availability'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 1,
              ),
            ),

            /*whichLanguages*/
            CommonText(
              text: 'Availability.yourWeeklyAvailability'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.medium(AppColors.baliHai).s15,
              maxLines: 4,
            ),
            const SizedBox(
              height: 33.0,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: provider.weekdays.length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return AvailabilityWidget(
                    tab: () {
                      provider.selectService(4, index);
                    },
                    title: provider.weekdays[index].title!.tr(),
                    startTime: provider.weekdays[index].startTime ??
                        DateFormat('hh:mm').format(DateTime.now()),
                    endTime: provider.weekdays[index].endTime ??
                        DateFormat('hh:mm').format(DateTime.now()),
                    selected: provider.weekdays[index].select,
                    startDateTab: () {
                      provider.showTimePickerView(true, index, context);
                    },
                    endDateTab: () {
                      provider.showTimePickerView(false, index, context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              height: 19,
            ),
            CommonText(
              text: 'Availability.yourSettings'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.medium(AppColors.baliHai).s12,
              maxLines: 4,
            ),
            /*back-next*/

            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonButton(
                    buttonText: 'login.back'.tr(),
                    borderColor: AppColors.trans,
                    backgroundColor: AppColors.madison.withOpacity(0.08),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: 27.0,
                    style: Poppins.bold(AppColors.madison).s14,
                    minimumSize: 145.0,
                  ),
                  CommonButton(
                    buttonText: 'done'.tr(),
                    borderColor: provider.availabilityIsSelected
                        ? AppColors.madison
                        : AppColors.trans,
                    backgroundColor: provider.availabilityIsSelected
                        ? AppColors.madison
                        : AppColors.madison.withOpacity(0.08),
                    onPressed: provider.availabilityIsSelected
                        ? () {
                            provider.updateUserViaId(true);
                          }
                        : () {},
                    borderRadius: 27.0,
                    style: Poppins.bold(provider.availabilityIsSelected
                            ? AppColors.white
                            : AppColors.madison)
                        .s14,
                    minimumSize: 145.0,
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
