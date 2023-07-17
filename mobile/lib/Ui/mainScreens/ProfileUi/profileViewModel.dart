import 'dart:convert';

import 'package:ajuda/Ui/Utils/commanWidget/common_validations.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:ajuda/my_app.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/remote/model/historyModel/history_model.dart';
import '../../../data/remote/model/userModel/user_model.dart';
import '../../../data/repo/auth_repo.dart';
import '../../../data/repo/home_repo.dart';
import '../../Utils/misc_functions.dart';
import '../../Utils/response.dart';
import '../../authScreens/login/login_screen.dart';

enum SingingCharacter { english, portuguese }

class ProfileViewModel extends ViewModel with CommonValidations {
  SingingCharacter? character = SingingCharacter.english;

  bool _showNotification = true;

  bool get showNotification => _showNotification;

  set showNotification(value) {
    print('showNotification');
    print(value);
    _showNotification = value;
    notifyListeners();
  }

  updateLanguage(SingingCharacter? value) {
    character = value;
    notifyListeners();
  }

  deleteUserAccount() {
    hideKeyboard();
    notifyListeners();
    callApi(() async {
      ResponseData response = await HomeRepo.deletedAccount();
      if (response.isSuccessFul) {
        SharedPrefHelper.userId = null;
        Navigator.pushNamedAndRemoveUntil(
            navigatorKey.currentContext!, LoginScreen.route, (route) => false);
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  List<dynamic> historyData = [];

  getUserHistory() {
    hideKeyboard();

    notifyListeners();
    callApi(() async {
      ResponseData response =
          await HomeRepo.userHistory(SharedPrefHelper.userId);
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        historyData = json.map((e) => HistoryModel.fromJson(e)).toList();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  UserModel? userModel = UserModel();

  Future<void> getUserData() async {
    hideKeyboard();

    callApi(() async {
      ResponseData rd = await AuthRepo.userById();

      if (rd.isSuccessFul) {
        snackBarText = rd.message;
        userModel = UserModel.fromJson(jsonDecode(rd.data));
      } else {
        snackBarText = rd.message;
        onError?.call();
      }
      notifyListeners();
      await getUserHistory();
    });
  }

  void urlLaunchThroughLink({url}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
