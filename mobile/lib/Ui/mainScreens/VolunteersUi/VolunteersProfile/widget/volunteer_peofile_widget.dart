import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class VolunteersProfileWidget extends StatelessWidget {
  final weekDay;

  const VolunteersProfileWidget({Key? key, required this.weekDay})
      : super(key: key);

/*ServiceAndNeedModel(
        title: 'Availability.monday',
        id: '1',
        end: TimeOfDay.now(),
        start: TimeOfDay.now()),
    ServiceAndNeedModel(
        title: 'Availability.tuesday',
        id: '2',
        end: TimeOfDay.now(),
        start: TimeOfDay.now()),
    ServiceAndNeedModel(
        title: 'Availability.wednesday',
        id: '3',
        end: TimeOfDay.now(),
        start: TimeOfDay.now()),
    ServiceAndNeedModel(
        title: 'Availability.thursday',
        id: '4',
        end: TimeOfDay.now(),
        start: TimeOfDay.now()),
    ServiceAndNeedModel(
        title: 'Availability.friday',
        id: '5',
        end: TimeOfDay.now(),
        start: TimeOfDay.now()),
    ServiceAndNeedModel(
        title: 'Availability.saturday',
        id: '6',
        end: TimeOfDay.now(),
        start: TimeOfDay.now()),
    ServiceAndNeedModel(
        title: 'Availability.sunday',
        id: '0',
        end: TimeOfDay.now(),
        start: TimeOfDay.now()*/

  // parseDatetimeFromUtc({required String isoFormattedString}) {
  //   var dateTime = DateTime.parse(isoFormattedString);
  //   print(isoFormattedString);
  //   print(dateTime.toLocal());
  //   var data = dateTime.toLocal().toString().split(' ');
  //   print(data[1].split(':')[0]);
  //   return '${data[1].split(':')[0]}:${data[1].split(':')[1]}';
  // }
  parseDatetimeFromUtc({required String isoFormattedString}) {
    var dateTime = DateTime.parse(isoFormattedString);
    print(isoFormattedString);
    print(dateTime.toLocal());
    var data =
        dateTime.toLocal().toString().split(' ')[1].toString().split(':');

    return '${data[0]}:${data[1]}';
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.9,
            child: CommonText(
                text: weekDay['weekDay'] == 1
                    ? 'Availability.monday'.tr()
                    : weekDay['weekDay'] == 2
                        ? 'Availability.tuesday'.tr()
                        : weekDay['weekDay'] == 3
                            ? 'Availability.wednesday'.tr()
                            : weekDay['weekDay'] == 4
                                ? 'Availability.thursday'.tr()
                                : weekDay['weekDay'] == 5
                                    ? 'Availability.friday'.tr()
                                    : weekDay['weekDay'] == 6
                                        ? 'Availability.saturday'.tr()
                                        : 'Availability.sunday'.tr(),
                style: Poppins.semiBold(AppColors.mako.withOpacity(0.80)).s14,
                maxLines: 1,
                textAlign: TextAlign.left),
          ),
          // SizedBox(width: 19.0,),
          CommonText(
              text:
                  '${parseDatetimeFromUtc(isoFormattedString: '${formattedDate}T${weekDay['start']}')} • ${parseDatetimeFromUtc(isoFormattedString: '${formattedDate}T${weekDay['end']}')}',
              style: Poppins.regular(AppColors.mako.withOpacity(0.80)).s14,
              maxLines: 1,
              textAlign: TextAlign.left),
        ],
      ),
    );
  }
}
