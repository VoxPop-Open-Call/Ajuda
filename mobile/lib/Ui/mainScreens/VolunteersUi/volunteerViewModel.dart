import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ajuda/Ui/Utils/commanWidget/common_validations.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/homeViewModel.dart';
import 'package:ajuda/data/remote/model/userModel/user_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/remote/model/historyModel/history_model.dart';
import '../../../data/remote/model/serviceAndNeedModel/serviceAndNeed_model.dart';
import '../../../data/repo/auth_repo.dart';
import '../../../data/repo/home_repo.dart';
import '../../../my_app.dart';
import '../../Utils/alert.dart';
import '../../Utils/misc_functions.dart';
import '../../Utils/response.dart';
import '../../Utils/theme/appcolor.dart';

class VolunteerViewModel extends ViewModel with CommonValidations {
  bool _openBottomSheet = false;

  bool get openBottomSheet => _openBottomSheet;

  set openBottomSheet(value) {
    _openBottomSheet = value;
    notifyListeners();
  }

  List<dynamic> volunteer = [];

  List<dynamic> desiredServices = [];

  List<dynamic> services = [];

  List<ServiceAndNeedModel> weekdays = [
    ServiceAndNeedModel(
      title: 'Availability.monday',
    ),
    ServiceAndNeedModel(
      title: 'Availability.tuesday',
    ),
    ServiceAndNeedModel(
      title: 'Availability.wednesday',
    ),
    ServiceAndNeedModel(
      title: 'Availability.thursday',
    ),
    ServiceAndNeedModel(
      title: 'Availability.friday',
    ),
    ServiceAndNeedModel(
      title: 'Availability.saturday',
    ),
    ServiceAndNeedModel(
      title: 'Availability.sunday',
    ),
  ];

  showTimePickerView(type, ctx) async {
    final TimeOfDay? result = await showTimePicker(
        context: ctx,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  // Using 12-Hour format set false
                  alwaysUse24HourFormat: true),
              // If you want 24-Hour format, just change alwaysUse24HourFormat to true
              child: child!);
        });
    if (result != null) {
      if (type) {
        startTime =
            '${result.hour > 9 ? result.hour : '0${result.hour}'}:${result.minute > 9 ? result.minute : '0${result.minute}'}';

        // startTime = result.format(ctx);
      } else {
        if (int.parse(startTime!.split(':')[0]) > result.hour) {
          Alert.showSnackBar(navigatorKey.currentContext!, 'timeError'.tr());
        } else {
          endTime =
              '${result.hour > 9 ? result.hour : '0${result.hour}'}:${result.minute > 9 ? result.minute : '0${result.minute}'}';
        }
        // endTime = result.format(ctx);
      }
      notifyListeners();
    }
  }

  String? _startTime;

  String? get startTime => _startTime;

  set startTime(String? time) {
    _startTime = time;
    notifyListeners();
  }

  String? _endTime;

  String? get endTime => _endTime;

  set endTime(String? time) {
    _endTime = time;
    notifyListeners();
  }

  countryCodeToEmoji(data) {
    // const data = 'CA';
    final int firstLetter = data.toUpperCase().codeUnitAt(0) - 0x41 + 0x1F1E6;

    final int secondLetter = data.toUpperCase().codeUnitAt(1) - 0x41 + 0x1F1E6;

    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  void selectWeekDays(index) {
    weekdays[index].select = !weekdays[index].select;
    notifyListeners();
  }

  void selectService(type, index) {
    if (type) {
      for (var item in desiredServices) {
        item.select = false;
      }
      desiredServices[index].select = !desiredServices[index].select;
    } else {
      for (var item in services) {
        item.select = false;
      }
      services[index].select = !services[index].select;
      serviceAndNeedModel = services[index];
    }
    notifyListeners();
    newRequest1 = true;
  }

  clearFilter() {
    for (var data in desiredServices) {
      data.select = false;
    }
    for (var data in weekdays) {
      data.select = false;
    }

    notifyListeners();
    // openBottomSheet = false;
  }

  int? _selectedIndex;

  int? get selectedIndex => _selectedIndex;

  set selectedIndex(int? value) {
    _selectedIndex = value;
    notifyListeners();
  }

  bool _resetScreenCall = false;

  bool get resetScreenCall => _resetScreenCall;

  set resetScreenCall(bool value) {
    _resetScreenCall = value;
    notifyListeners();
  }

  bool _addNewRequest = false;

  bool get addNewRequest => _addNewRequest;

  set addNewRequest(bool value) {
    _addNewRequest = value;
    notifyListeners();
  }

  RangeValues radiusRange = const RangeValues(0.0, 10 * 500.0);

  GoogleMapController? _mapController; //controller for Google map
  GoogleMapController? get mapController =>
      _mapController; //controller for Google map

  set mapController(GoogleMapController? controller) {
    _mapController = controller;
    notifyListeners();
  }

  CameraPosition initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0));

  Position? position;

  getGeoLocationPosition() async {
    final Uint8List markIcons = await getImages('assets/icon/location.png', 150);

    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      Alert.showSnackBar(
          navigatorKey.currentContext!, 'Location services are disabled.');
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Alert.showSnackBar(
            navigatorKey.currentContext!, 'Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Alert.showSnackBar(navigatorKey.currentContext!,
          'First provide Location permission via Phone setting option');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    if (selectedIndex == null) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position po) async {
        position = po;
        notifyListeners();
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position!.latitude, position!.longitude),
              zoom: 20.0,
            ),
          ),
        );
      });
      marker = Marker(
        markerId: const MarkerId('mapMarker'),
        position: LatLng(position!.latitude, position!.longitude),
        icon: BitmapDescriptor.fromBytes(markIcons),

      );
    } else {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(volunteersList[selectedIndex!]!.location['lat'],
                volunteersList[selectedIndex!]!.location['long']),
            zoom: 20.0,
          ),
        ),
      );
      marker = Marker(
        markerId: const MarkerId('mapMarker'),
        icon: BitmapDescriptor.fromBytes(markIcons),

        position:
        LatLng(volunteersList[selectedIndex!]!.location['lat'], volunteersList[selectedIndex!]!.location['long']),
      );
    }

    markers[const MarkerId('mapMarker')] = marker!;

  }
  Map<MarkerId, Marker> markers =
  <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS
  Marker? marker;

  bool _newRequest1 = false;

  bool get newRequest1 => _newRequest1;

  set newRequest1(bool value) {
    _newRequest1 = value;
    notifyListeners();
  }

  bool _newRequest2 = false;

  bool get newRequest2 => _newRequest2;

  set newRequest2(bool value) {
    _newRequest2 = value;
    notifyListeners();
  }

  bool _requestReview = false;

  bool get requestReview => _requestReview;

  set requestReview(bool value) {
    _requestReview = value;
    notifyListeners();
  }

  TextEditingController? dobController = TextEditingController();
  TextEditingController? searchController = TextEditingController();
  String? dateError;
  DateTime firstDate = DateTime.now();

  void selectDate() async {
    final pickedDate = await showDatePicker(
      context: navigatorKey.currentContext!,
      initialDate: firstDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 100),
      builder: (context, child) {
        return Theme(
          data: ThemeData().copyWith(
            colorScheme: const ColorScheme.light(
                surface: AppColors.madison,
                primary: AppColors.madison,
                onPrimary: AppColors.white),
          ),
          child: DatePickerDialog(
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 100),
          ),
        );
      },
    );
    firstDate = pickedDate!;
    dobController!.text =
        DateFormat('MMM dd, yyyy').format(firstDate).toString();
    notifyListeners();
  }

  requestTimePickerView(type, ctx) async {
    final TimeOfDay? result = await showTimePicker(
      context: ctx,
      initialTime: type
          ? startTimeRequest!.isNotEmpty
              ? TimeOfDay(
                  hour: int.parse(startTimeRequest!.split(':')[0]),
                  minute: int.parse(startTimeRequest!.split(':')[1]))
              : TimeOfDay.now()
          : endTimeRequest!.isNotEmpty
              ? TimeOfDay(
                  hour: int.parse(endTimeRequest!.split(':')[0]),
                  minute: int.parse(endTimeRequest!.split(':')[1]))
              : TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(
                // Using 12-Hour format
                alwaysUse24HourFormat: true),
            // If you want 24-Hour format, just change alwaysUse24HourFormat to true
            child: child!);
      },
    );
    if (result != null) {
      if (type) {
        startTimeRequest =
            '${result.hour > 9 ? result.hour : '0${result.hour}'}:${result.minute > 9 ? result.minute : '0${result.minute}'}';
      } else {
        if (int.parse(startTimeRequest!.split(':')[0]) > result.hour) {
          Alert.showSnackBar(navigatorKey.currentContext!, 'timeError'.tr());
        } else {
          endTimeRequest =
              '${result.hour > 9 ? result.hour : '0${result.hour}'}:${result.minute > 9 ? result.minute : '0${result.minute}'}';
        }
      }
      notifyListeners();
    }
  }

  String? _startTimeRequest;

  String? get startTimeRequest => _startTimeRequest;

  set startTimeRequest(String? time) {
    _startTimeRequest = time;
    notifyListeners();
  }

  String? _endTimeRequest;

  String? get endTimeRequest => _endTimeRequest;

  set endTimeRequest(String? time) {
    _endTimeRequest = time;
    notifyListeners();
  }

  bool _specificTime = false;

  bool get specificTime => _specificTime;

  set specificTime(bool value) {
    _specificTime = value;
    notifyListeners();
  }

  String? typeHereFiled, typeHereError;

  HomeViewModel? _homeViewModel;

  HomeViewModel? get homeViewModel => _homeViewModel;

  set homeViewModel(HomeViewModel? viewModel) {
    _homeViewModel = viewModel;
    notifyListeners();
  }

  setSelection() {
    for (var data in services) {
      print(homeViewModel!.addRequest);
      if (homeViewModel!.addRequest == data.title) {
        data.select = true;
        newRequest1 = true;
      } else {
        data.select = false;
      }
    }
    notifyListeners();
  }

  bool _newRequest3 = false;

  bool get newRequest3 => _newRequest3;

  set newRequest3(bool value) {
    _newRequest3 = value;
    notifyListeners();
  }

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
        services = desiredServices;
        if (homeViewModel != null && homeViewModel!.addRequest != null) {
          setSelection();
        }
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  back(bool check) {
    newRequest1 = true;
    newRequest2 = false;
    newRequest3 = false;
    requestReview = false;
    specificTime = false;
    dobController!.clear();
    notifyListeners();
    if (check) {
      Navigator.of(navigatorKey.currentContext!).pop();
    }
    return true;
  }

  List<dynamic> volunteersList = [];
  List<dynamic> volunteersListCopy = [];

  ServiceAndNeedModel? serviceAndNeedModel;

  searchVolunteer(String text) async {
    List<dynamic> temp = [];

    if (text.isEmpty) {
      volunteersList = volunteersListCopy;
    } else {
      for (var item in volunteersListCopy) {
        if (item.name!.toLowerCase().contains(text.toLowerCase())) {
          temp.add(item);
        }
      }
      volunteersList = temp;
    }
    notifyListeners();
  }

  getVolunteerListWithFilter() {
    volunteersList.clear();
    hideKeyboard();
    notifyListeners();

    for (var item in desiredServices) {
      if (item.select) {
        serviceAndNeedModel = item;
      }
    }

    var utc = DateTime.now().timeZoneOffset.toString().split(':');
    var h = int.parse(utc[0]) > 9 ? utc[0] : "0${int.parse(utc[0])}";
    var m = int.parse(utc[1]) > 9 ? utc[1] : "0${int.parse(utc[1])}";
    var data = '$h:$m';
    notifyListeners();
    // if (serviceAndNeedModel == null) {
    //   snackBarText = 'volunteer.selectService'.tr();
    //   onError?.call();
    // } else {
    print(startTimeRequest);
    callApi(() async {
      ResponseData response = await HomeRepo.getVolunteerWithoutFilterList(
        serviceAndNeedModel != null ? serviceAndNeedModel!.title : null,
        startTime != null ? '${startTime!}+$data' : null,
        endTime != null ? '${endTime!}+$data' : null,
      );
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        volunteersList = json.map((e) => UserModel.fromJson(e)).toList();
        volunteersListCopy = volunteersList;
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
      await getVolunteersImageAndData();
    });
    // }
  }

  // declared method to get Images
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  getVolunteerListData() {
    volunteersList.clear();
    hideKeyboard();
    // var taskTypeCode;
    for (var item in services) {
      if (item.select) {
        serviceAndNeedModel = item;
        // taskTypeCode = item.title;
      }
    }
    print(startTimeRequest);

    var utc = DateTime.now().timeZoneOffset.toString().split(':');
    var h = int.parse(utc[0]) > 9 ? utc[0] : "0${int.parse(utc[0])}";
    var m = int.parse(utc[1]) > 9 ? utc[1] : "0${int.parse(utc[1])}";
    var data = '$h:$m';
    notifyListeners();
    callApi(() async {
      ResponseData response = await HomeRepo.getVolunteerList(
          DateFormat('yyyy-MM-dd').format(firstDate).toString(),
          searchController!.text,
          serviceAndNeedModel!.title,
          '${startTimeRequest!}+$data',
          '${endTimeRequest!}+$data',
          specificTime);
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        volunteersList = json.map((e) => UserModel.fromJson(e)).toList();
        volunteersListCopy = volunteersList;
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
      await getVolunteersImageAndData();
    });
  }

  getVolunteersImageAndData() async {
    hideKeyboard();
    notifyListeners();
    for (var item in volunteersList) {
      callApi(() async {
        ResponseData response = await AuthRepo.userById(id: item.id);
        if (response.isSuccessFul) {
          var json = jsonDecode(response.data);
          item.location = json['location'];
        } else {
          snackBarText = response.message;
          onError?.call();
        }
        notifyListeners();
      });
    }
    await addImage();
  }

  getAddress(po) async {
    // Places are retrieved using the coordinates
    List<Placemark> p =
        await placemarkFromCoordinates(po.latitude, po.longitude);

    // Taking the most probable result
    Placemark place = p[0];
    print('place');
    print(place);
    // Structuring the address

    return "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
  }

  addImage() async {
    for (var item in volunteersList) {
      callApi(() async {
        ResponseData rd = await AuthRepo.getShowImageUrl(id: item.id);
        if (rd.isSuccessFul) {
          var json = jsonDecode(rd.data);
          item.image = jsonDecode(rd.data)['url'];
        } else {
          snackBarText = rd.message;
          onError?.call();
        }
        notifyListeners();
      });
    }
    await addUserHistory();
  }

  addUserHistory() async {
    hideKeyboard();
    notifyListeners();
    for (var item in volunteersList) {
      callApi(() async {
        ResponseData response = await HomeRepo.userHistory(item.id);
        if (response.isSuccessFul) {
          var json = jsonDecode(response.data);
          item.historyData = json.map((e) => HistoryModel.fromJson(e)).toList();
        } else {
          snackBarText = response.message;
          onError?.call();
        }
        notifyListeners();
      });
    }
  }

  addImageHistoryUser() async {
    for (var item in volunteersList) {
      for (var data in item.historyData) {
        callApi(() async {
          ResponseData rd =
              await AuthRepo.getShowImageUrl(id: data.task.requester.id);
          if (rd.isSuccessFul) {
            var json = jsonDecode(rd.data);
            data.task.requester.image = jsonDecode(rd.data)['url'];
          } else {
            snackBarText = rd.message;
            onError?.call();
          }
          notifyListeners();
        });
      }
    }
  }

  bool requestCreate = false;
  bool request = false;

  sendRequest(type) async {
    hideKeyboard();
    var utc = DateTime.now().timeZoneOffset.toString().split(':');
    var h = int.parse(utc[0]) > 9 ? utc[0] : "0${int.parse(utc[0])}";
    var m = int.parse(utc[1]) > 9 ? utc[1] : "0${int.parse(utc[1])}";
    var data = '$h:$m';
    notifyListeners();
    String? typeCheck =
        isNotEmpty(typeHereFiled, 'volunteer.importantNotes'.tr());
    if (typeCheck != null) {
      snackBarText = typeCheck;
      onError?.call();
    } else {
      callApi(() async {
        Map<String, String> body = specificTime
            ? {
                "date": DateFormat('yyyy-MM-dd').format(firstDate).toString(),
                "description": typeHereFiled!,
                "taskTypeCode": serviceAndNeedModel!.title!
              }
            : {
                "date": DateFormat('yyyy-MM-dd').format(firstDate).toString(),
                "description": typeHereFiled!,
                "taskTypeCode": serviceAndNeedModel!.title!,
                "timeFrom": '${startTimeRequest!}+$data',
                "timeTo": '${endTimeRequest!}+$data'
              };

        ResponseData response = await HomeRepo.createRequest(body);
        if (response.isSuccessFul) {
          // requestCreate = response.isSuccessFul;
          var json = jsonDecode(response.data);
          type == 1
              ? await assignmentsNewTaskStep(json['id'])
              : await assignments(json['id']);
        } else {
          snackBarText = response.message;
          onError?.call();
        }
        notifyListeners();
      });
    }
  }

  assignmentsNewTaskStep(taskId) async {
    hideKeyboard();
    notifyListeners();
    callApi(() async {
      Map<String, String> body = {
        "taskId": taskId,
        "userId": volunteersList[selectedIndex!].id
      };

      ResponseData response = await HomeRepo.assignmentsRequest(body);
      if (response.isSuccessFul) {
        requestCreate = response.isSuccessFul;
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  assignments(taskId) async {
    hideKeyboard();
    notifyListeners();
    callApi(() async {
      Map<String, String> body = {
        "taskId": taskId,
        "userId": volunteersList[selectedIndex!].id
      };

      ResponseData response = await HomeRepo.assignmentsRequest(body);
      if (response.isSuccessFul) {
        request = response.isSuccessFul;
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  List<dynamic> historyData = [];

  getUserHistory(id) {
    hideKeyboard();

    notifyListeners();
    callApi(() async {
      ResponseData response = await HomeRepo.userHistory(id);
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

  ratingCount(List<dynamic> data) {
    double sumRating = 0;

    for (var item in data) {
      sumRating += item.rating != 'null' ? double.parse(item.rating!) : 0.0;
    }

    return (sumRating / data.length);
  }
}
