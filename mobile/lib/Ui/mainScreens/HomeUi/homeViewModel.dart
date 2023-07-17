import 'dart:convert';

import 'package:ajuda/Ui/Utils/commanWidget/common_validations.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/auth_view_model.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:ajuda/data/remote/model/pendingTaskModel/pending_task_model.dart';

import '../../../data/remote/model/NewsModel/newsmodel.dart';
import '../../../data/remote/model/serviceAndNeedModel/serviceAndNeed_model.dart';
import '../../../data/remote/model/taskModel/task_model.dart';
import '../../../data/remote/model/userModel/user_model.dart';
import '../../../data/repo/auth_repo.dart';
import '../../../data/repo/home_repo.dart';
import '../../Utils/misc_functions.dart';
import '../../Utils/response.dart';
import '../NewsUi/newsViewModel.dart';

class HomeViewModel extends ViewModel with CommonValidations {
  String? _addRequest;

  String? get addRequest => _addRequest;

  set addRequest(String? value) {
    _addRequest = value;
    notifyListeners();
  }

  /*news*/

  NewsViewModel? _newsViewModel;

  NewsViewModel? get newsViewModel => _newsViewModel;

  set newsViewModel(NewsViewModel? viewModel) {
    _newsViewModel = viewModel;
    notifyListeners();
  }

  AuthViewModel? _authViewModel;

  AuthViewModel? get authViewModel => _authViewModel;

  set authViewModel(AuthViewModel? viewModel) {
    _authViewModel = viewModel;
    notifyListeners();
  }

  getListData() async {
    hideKeyboard();
    callApi(() async {
      ResponseData response = await HomeRepo.getNewsList();
      if (response.isSuccessFul) {
        newsViewModel!.newsData = jsonDecode(response.data)
            .map((e) => NewsModel.fromJson(e))
            .toList();
        await authViewModel!.getUserData();
        await getService();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  String capitalize(String value) {
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

  List<dynamic> desiredServices = [];

  getService() async {
    hideKeyboard();
    callApi(() async {
      ResponseData response = await AuthRepo.getTaskList(10);
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        desiredServices =
            json.map((e) => ServiceAndNeedModel.fromJson(e)).toList();
        for (var item in desiredServices) {
          item.icon = item.title == 'other'
              ? 'assets/icon/file.svg'
              : item.title == 'company'
                  ? 'assets/icon/keepCompany.svg'
                  : item.title == 'pharmacy'
                      ? 'assets/icon/pharmacies.svg'
                      : item.title == 'shopping'
                          ? 'assets/icon/cart.svg'
                          : item.title == 'tours'
                              ? 'assets/icon/map.svg'
                              : 'assets/icon/file.svg';
        }
        var data;
        for (var item in desiredServices) {
          if (item.title == 'other') {
            data = item;
          }
        }
        desiredServices.remove(data);
        await getUpcomingList();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  List<dynamic> upcomingListData = [];

  getUpcomingList() async {
    hideKeyboard();
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
          await getVolunteerData();
        } else {
          for (var item in upcomingListData) {
            await getAddImage(id: item.task.requester);
          }
        }
        await sendFcm();

        if (SharedPrefHelper.userType == '2') getPendingList();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  getVolunteerData() async {
    for (var item in upcomingListData) {
      callApi(() async {
        ResponseData rd = await AuthRepo.userById(
            id: SharedPrefHelper.userType == '1'
                ? item.assignments[0].userId
                : item.userId);
        if (rd.isSuccessFul) {
          var json = jsonDecode(rd.data);

          item.volunteer = UserModel.fromJson(json);
          notifyListeners();
          await getAddImage(id: item.volunteer);
        } else {
          snackBarText = rd.message;
          onError?.call();
          notifyListeners();
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
        notifyListeners();
      } else {
        // snackBarText = rd.message;
        // onError?.call();
      }
      notifyListeners();
    });
  }

  List<dynamic> pendingListData = [];

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
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  sendFcm() async {
    callApi(() async {
      ResponseData response = await AuthRepo.updateFcm();

      if (response.isSuccessFul) {}
      notifyListeners();
    });
  }
}
