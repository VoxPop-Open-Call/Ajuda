import 'theme/appcolor.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:flutter/material.dart';

class Alert {
  static void showSnackBar(BuildContext context, String title,
      {int durationInMilliseconds = 3000}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: Poppins.medium(AppColors.white).s16,
        ),
        backgroundColor: AppColors.bittersweet,
        duration: Duration(milliseconds: durationInMilliseconds),
      ),
    );
  }

  static void showSnackBarSuccess(BuildContext context, String title,
      {int durationInMilliseconds = 3000}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: Poppins.medium(AppColors.white).s16,
        ),
        backgroundColor: AppColors.madison,
        duration: Duration(milliseconds: durationInMilliseconds),
      ),
    );
  }
}
