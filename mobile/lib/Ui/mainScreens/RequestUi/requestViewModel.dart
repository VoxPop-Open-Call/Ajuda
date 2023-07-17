import 'dart:convert';

import 'package:ajuda/Ui/Utils/commanWidget/common_validations.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/volunteerViewModel.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:ajuda/data/remote/model/userModel/user_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/remote/model/pendingTaskModel/pending_task_model.dart';
import '../../../data/remote/model/taskModel/task_model.dart';
import '../../../data/repo/auth_repo.dart';
import '../../../data/repo/home_repo.dart';
import '../../Utils/Event.dart';
import '../../Utils/misc_functions.dart';
import '../../Utils/response.dart';

class RequestViewModel extends ViewModel with CommonValidations {
  bool _selectButton = false;

  bool get selectButton => _selectButton;

  DateTime _focusedDay = DateTime.now();

  DateTime get focusedDay => _focusedDay;

  set focusedDay(DateTime value) {
    _focusedDay = value;
    notifyListeners();
  }

  DateTime? _selectedDay;

  DateTime? get selectedDay => _selectedDay;

  set selectedDay(DateTime? value) {
    _selectedDay = value;
    notifyListeners();
  }

  set selectButton(bool value) {
    _selectButton = value;
    notifyListeners();
  }

  bool _openCalender = false;

  bool get openCalender => _openCalender;

  set openCalender(bool value) {
    _openCalender = value;
    notifyListeners();
  }

  List<Event> getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  List<dynamic> listMessage = List.from([]);
  final int _limitIncrement = 20;
  int limit = 20;

  scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      limit += _limitIncrement;
    }
    notifyListeners();
  }

  bool checkMessageTime(int index) {
    if (index > 0) {
      if (DateFormat('dd MMM kk:mm').format(
            DateTime.fromMicrosecondsSinceEpoch(listMessage[index - 1]
                .data()['timestamp']
                .microsecondsSinceEpoch),
          ) !=
          DateFormat('dd MMM kk:mm').format(
            DateTime.fromMicrosecondsSinceEpoch(
                listMessage[index].data()['timestamp'].microsecondsSinceEpoch),
          )) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].data()['idFrom'] !=
                SharedPrefHelper.userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  VolunteerViewModel? _volunteerViewModel;

  VolunteerViewModel? get volunteerViewModel => _volunteerViewModel;

  set volunteerViewModel(VolunteerViewModel? viewModel) {
    _volunteerViewModel = viewModel;
    notifyListeners();
  }

  String? chatText, chatTextError;

  int _comAndUpIndex = 0;

  int get comAndUpIndex => _comAndUpIndex;

  set comAndUpIndex(int value) {
    _comAndUpIndex = value;
    notifyListeners();
  }

  List<dynamic> upcomingListData = [];
  List<dynamic> completeListData = [];
  List<dynamic> pendingListData = [];

  int _selectPendingIndex = 0;

  int get selectPendingIndex => _selectPendingIndex;

  set selectPendingIndex(int value) {
    _selectPendingIndex = value;
    notifyListeners();
  }

  getAddress(po) async {
    // Places are retrieved using the coordinates
    List<Placemark> p =
        await placemarkFromCoordinates(po.latitude, po.longitude);

    // Taking the most probable result
    Placemark place = p[0];
    // Structuring the address

    return "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
  }

  getUpcomingList() async {
    upcomingListData.clear();
    hideKeyboard();
    notifyListeners();
    callApi(() async {
      ResponseData response = await HomeRepo.getUpcomingTask();
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        if (SharedPrefHelper.userType == '1') {
          upcomingListData = json.map((e) => TaskModel.fromJson(e)).toList();
        } else {
          upcomingListData =
              json.map((e) => PendingTaskModel.fromJson(e)).toList();
        }
        if (SharedPrefHelper.userType == '1') {
          await getVolunteerData(type: 2);
        } else {
          for (var item in upcomingListData) {
            await getAddImage(id: item.task.requester);
          }
        }
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  getCompleteList() async {
    completeListData.clear();
    hideKeyboard();
    notifyListeners();
    callApi(() async {
      ResponseData response = await HomeRepo.getCompleteTask();
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        if (SharedPrefHelper.userType == '1') {
          completeListData = json.map((e) => TaskModel.fromJson(e)).toList();
        } else {
          completeListData =
              json.map((e) => PendingTaskModel.fromJson(e)).toList();
        }
        if (SharedPrefHelper.userType == '1') {
          await getVolunteerData(type: 1);
        } else {
          for (var item in completeListData) {
            await getAddImage(id: item.task.requester);
          }
        }
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
      // await addImage(type: 1);
    });
  }

  getVolunteerData({type}) async {
    for (var item in type == 1
        ? completeListData
        : type == 2
            ? upcomingListData
            : pendingListData) {
      callApi(() async {
        ResponseData rd = await AuthRepo.userById(
            id: type == 3
                ? item.task.requester.id
                : item.assignments[0].userId);
        if (rd.isSuccessFul) {
          var json = jsonDecode(rd.data);
          if (type == 3) {
            item.task.requester.image = jsonDecode(rd.data)['url'];
          } else {
            item.volunteer = UserModel.fromJson(json);
            notifyListeners();
            await getAddImage(id: item.volunteer);
          }
          /*      if (type == 1) {
            if (item == completeListData.last) {
              await addImage(type: type);
            }
          } else if (type == 2) {
            if (item == upcomingListData.last) {
              await addImage(type: type);
            }
          } else if (type == 3) {
            if (item == pendingListData.last) {
              await addImage(type: type);
            }
          }*/
        } else {
          snackBarText = rd.message;
          onError?.call();
          notifyListeners();
        }
        notifyListeners();
      });
    }
  }

  getPendingList() async {
    pendingListData.clear();
    List<dynamic> temp = [];
    hideKeyboard();
    callApi(() async {
      ResponseData response = await HomeRepo.getPendingTask();
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        pendingListData =
            json.map((e) => PendingTaskModel.fromJson(e)).toList();
        for (var data in pendingListData) {
          if (data.state == 'pending') {
            temp.add(data);
          }
        }
        pendingListData = temp;
        await getVolunteerData(type: 3);
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  addImage({type}) async {
    for (var item in type == 1
        ? completeListData
        : type == 2
            ? upcomingListData
            : pendingListData) {
      callApi(() async {
        ResponseData rd = await AuthRepo.getShowImageUrl(
            id: type == 3
                ? item.task.requester.id
                : item.volunteer?.id ?? item.assignments[0].userId);
        if (rd.isSuccessFul) {
          if (type == 3) {
            item.task.requester.image = jsonDecode(rd.data)['url'];
          } else {
            item.volunteer.image = jsonDecode(rd.data)['url'];
          }
        } else {
          snackBarText = rd.message;
          onError?.call();
        }
        notifyListeners();
      });
    }
  }

  getAddImage({id}) async {
    callApi(() async {
      ResponseData rd = await AuthRepo.getShowImageUrl(id: id.id);
      if (rd.isSuccessFul) {
        id.image = jsonDecode(rd.data)['url'];
      } else {
        // snackBarText = rd.message;
        // onError?.call();
      }
      notifyListeners();
    });
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  String capitalize(String value) {
    if (value != '') {
      var result = value[0].toUpperCase();
      bool cap = true;
      for (int i = 1; i < value.length; i++) {
        if (value[i - 1] == " " && cap == true) {
          result = result + value[i].toUpperCase();
        } else {
          result = result + value[i];
          cap = false;
        }
      }
      return result;
    }
    return '';
  }

  VoidCallback? acceptRejectSuccess;

  acceptRequest(id, index) async {
    hideKeyboard();
    notifyListeners();
    callApi(() async {
      ResponseData response = await HomeRepo.acceptRequest(id);
      if (response.isSuccessFul) {
        requestAccept = true;
        snackBarText = response.message;
        pendingListData.removeAt(index);
        acceptRejectSuccess?.call();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  bool requestReject = false;
  bool requestAccept = false;

  rejectRequest(id, index) async {
    hideKeyboard();
    notifyListeners();
    callApi(() async {
      ResponseData response = await HomeRepo.rejectRequest(id);
      if (response.isSuccessFul) {
        requestReject = true;
        snackBarText = response.message;
        pendingListData.removeAt(index);
        acceptRejectSuccess?.call();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  bool cancelDone = false;

  cancelRequest(id, index) async {
    hideKeyboard();
    notifyListeners();
    callApi(() async {
      ResponseData response = await HomeRepo.getCancelTask(id);
      if (response.isSuccessFul) {
        snackBarText = 'request.requestCanceled'.tr();
        cancelDone = response.isSuccessFul;
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  /*review */
  String? writeReview, writeReviewError;

  int? _ratingReview;

  int? get ratingReview => _ratingReview;

  set ratingReview(int? value) {
    _ratingReview = value;
    notifyListeners();
  }

  checkWriteReview() {
    String? writeReviewCheck =
        isNotEmpty(writeReview, 'errorMessage.writeReviewError'.tr());
    if (writeReviewCheck != null) {
      snackBarText = writeReviewCheck;
      onError?.call();
      return false;
    } else {
      return true;
    }
  }

  bool ratingCheck = false;

  review(id) async {
    hideKeyboard();
    notifyListeners();
    String? writeReviewCheck =
        isNotEmpty(writeReview, 'errorMessage.writeReviewError'.tr());
    if (writeReviewCheck != null) {
      snackBarText = writeReviewCheck;
      onError?.call();
    } else {
      callApi(() async {
        Map<String, dynamic> body = {
          "rating": ratingReview,
          "comment": writeReview
        };

        ResponseData response = await HomeRepo.reviewRequest(id, body);
        if (response.isSuccessFul) {
          ratingCheck = response.isSuccessFul;
        } else {
          snackBarText = response.message;
          onError?.call();
        }
        notifyListeners();
      });
    }
  }

  Future<void> makePhoneCall(String contact) async {
    String telScheme = 'tel:$contact';

    if (await canLaunch(telScheme)) {
      await launch(telScheme);
    } else {
      throw 'Could not launch $telScheme';
    }
  }
}
