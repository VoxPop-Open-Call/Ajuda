import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:flutter/material.dart';

import '../../../../data/remote/model/onBoardingModel/info_model.dart';

class DotView extends StatelessWidget {
  final int currentIndex;
  final List<InfoModel> allInfo;

  const DotView({Key? key, required this.currentIndex, required this.allInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        allInfo.length,
            (index) => buildDot(index, context),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.only(right: 5, left: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index
            ? Theme.of(context).primaryColor
            : AppColors.mako.withOpacity(0.15),
      ),
    );
  }

}
