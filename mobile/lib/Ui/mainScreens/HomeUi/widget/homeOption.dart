import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeOption extends StatelessWidget {
  final image;
  final optionImage;
  final Function() onTap;

  const HomeOption({Key? key, this.image, this.optionImage, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      onTap: onTap,
      child: Card(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        shadowColor: AppColors.black.withOpacity(0.30),
        elevation: 2,
        child: SizedBox(
          height: MediaQuery.of(context).size.width / 2.6,
          width: MediaQuery.of(context).size.width / 2.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 70,
                width: 70,
                margin: const EdgeInsets.only(bottom: 13),
                decoration: ShapeDecoration(
                  shape: const CircleBorder(),
                  color: AppColors.madison.withOpacity(0.10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    image ?? 'assets/icon/info.svg',
                    width: 45.5,
                    height: 45.5,
                  ),
                ),
              ),
              CommonText(
                  text: optionImage ?? '-',
                  style: Poppins.medium(AppColors.mako).s14,
                  maxLines: 1,
                  textAlign: TextAlign.center)
            ],
          ),
        ),
      ),
    );
  }
}
