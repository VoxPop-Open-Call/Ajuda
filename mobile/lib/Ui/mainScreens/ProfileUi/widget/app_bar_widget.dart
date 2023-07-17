import 'package:ajuda/Ui/Utils/commanWidget/commonText.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarWidget extends StatelessWidget {
  final String title;

  const AppBarWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        centerTitle: true,
        leading: SvgPicture.asset(
          'assets/icon/back.svg',
          height: 12.48,
          width: 15.0,
          color: AppColors.madison,
        ),
        title: CommonText(
          text: title,
          style: Poppins.bold(AppColors.madison).s18,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Color color;

  const CommonAppBar({
    Key? key,
    required this.title,
    required this.color,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);
  @override
  final Size preferredSize; // default is 56.0
  @override
  State<CommonAppBar> createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: SvgPicture.asset(
            'assets/icon/back.svg',
            height: 12.48,
            width: 15.0,
            color: AppColors.madison,
          ),
        ),
      ),
      backgroundColor: widget.color,
      centerTitle: true,
      title: CommonText(
        text: widget.title,
        style: Poppins.bold(AppColors.madison).s18,
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
      elevation: 0,
    );
  }
}
