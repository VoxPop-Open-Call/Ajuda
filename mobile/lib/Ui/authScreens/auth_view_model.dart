import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ajuda/Ui/Utils/alert.dart';
import 'package:ajuda/Ui/Utils/commanWidget/common_validations.dart';
import 'package:ajuda/Ui/Utils/response.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:ajuda/data/remote/model/userModel/user_model.dart';
import 'package:ajuda/data/repo/auth_repo.dart';
import 'package:ajuda/my_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/remote/model/emergencyContactModel/emergencyContact_model.dart';
import '../../data/remote/model/langaugeModel/langauge_model.dart';
import '../../data/remote/model/serviceAndNeedModel/serviceAndNeed_model.dart';
import '../../route_helper.dart';
import '../Utils/app-constent.dart';
import '../Utils/misc_functions.dart';
import '../Utils/theme/appcolor.dart';

class AuthViewModel extends ViewModel with CommonValidations {
  String? emailField, password, confirmPassword, username, phoneNumber;
  String? emailError,
      passwordError,
      confirmPasswordError,
      dobError,
      usernameError,
      locationError,
      phoneNumberError;
  TextEditingController? dobController = TextEditingController();
  TextEditingController? conformController = TextEditingController();
  TextEditingController? emailController = TextEditingController();
  TextEditingController? passController = TextEditingController();
  TextEditingController? locationController = TextEditingController();

  bool passwordVisible = true, confirmVisible = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // Obscure text Update
  void updateVisible(isPassword, value) {
    if (isPassword) {
      passwordVisible = value;
    } else {
      confirmVisible = value;
    }
    notifyListeners();
  }

  File? _changeImage;

  File? get changeImage => _changeImage;

  set changeImage(File? files) {
    _changeImage = files;
    notifyListeners();
  }

  bool _RGPD = true;

  bool get RGPD => _RGPD;

  set RGPD(value) {
    _RGPD = value;
    notifyListeners();
  }

  bool _notEnterCheck = false;

  bool get notEnterCheck => _notEnterCheck;

  set notEnterCheck(value) {
    _notEnterCheck = value;
    notifyListeners();
  }

  // VoidCallBack Methods
  VoidCallback? onRegisteredSuccess;
  VoidCallback? profileUpdate;
  VoidCallback? profileEdited;
  VoidCallback? onWithUsValidateSuccess;
  VoidCallback? onLoginSuccess;
  VoidCallback? onForgotSuccess;
  VoidCallback? imageUploaded;

  List<ServiceAndNeedModel> weekdays = [
    ServiceAndNeedModel(
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
        start: TimeOfDay.now()),
  ];

  List<dynamic> desiredServices = [];

  List<dynamic> language = [];

  List<dynamic> conditions = [];

  List<EmergencyContactModel> emergencyContactData = [];

  void addNewContact(name, number, {index}) {
    if (index == null) {
      emergencyContactData
          .add(EmergencyContactModel(name: name, mobileNumber: number));
    } else {
      emergencyContactData[index].name = name;
      emergencyContactData[index].mobileNumber = number;
    }
    notifyListeners();
  }

  void editContact(name, number, {index}) {
    if (userModel!.elder['emergencyContacts'] == null) {
      userModel!.elder = {'emergencyContacts': []};
      userModel!.elder['emergencyContacts']
          .add({'name': name, 'phoneNumber': number});
    } else if (index == null) {
      // userModel!.elder.add({
      //   'emergencyContacts': [
      //     {'name': name, 'phoneNumber': number}
      //   ]
      // });

      userModel!.elder['emergencyContacts']
          .add({'name': name, 'phoneNumber': number});
    } else {
      userModel!.elder['emergencyContacts'][index]['name'] = name;
      userModel!.elder['emergencyContacts'][index]['phoneNumber'] = number;
    }
    notifyListeners();
  }

  String? contactName, contactNumber;

  void removeContact(index, type) {
    if (type) {
      emergencyContactData.removeAt(index);
    } else {
      userModel!.elder['emergencyContacts'].removeAt(index);
    }

    notifyListeners();
    Navigator.of(navigatorKey.currentContext!).pop();
  }

  showTimePickerView(type, index, ctx) async {
    final result = await showTimePicker(
        context: ctx,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData().copyWith(
              colorScheme: const ColorScheme.light(
                  // surface: AppColors.madison,
                  primary: AppColors.madison,
                  onPrimary: AppColors.white),
            ),
            child: TimePickerDialog(
              initialTime: TimeOfDay.now(),
            ),
          );
        });

    if (result != null) {
      print(result.replacing());

      if (type) {
        weekdays[index].startTime =
            '${result.hour > 9 ? result.hour : '0${result.hour}'}:${result.minute > 9 ? result.minute : '0${result.minute}'}';
        weekdays[index].start = result;
      } else {
        if (int.parse(weekdays[index].startTime!.split(':')[0]) > result.hour) {
          Alert.showSnackBar(navigatorKey.currentContext!, 'timeError'.tr());
        } else {
          weekdays[index].endTime =
              '${result.hour > 9 ? result.hour : '0${result.hour}'}:${result.minute > 9 ? result.minute : '0${result.minute}'}';
          weekdays[index].end = result;
        }
      }
      notifyListeners();
    }
  }

  set setNullValue(value) {
    password = value;
    emailField = value;
    confirmPassword = value;
    emailError = value;
    passwordError = value;
    confirmPasswordError = value;
    username = value;
    dobController!.clear();
    conformController!.clear();
    emailController!.clear();
    passController!.clear();
    phoneNumber = value;
    languageIsSelected = false;
    serviceAndNeedIsSelected = false;
    availabilityIsSelected = false;
    firstDate = null;
    // notifyListeners();
  }

  bool languageIsSelected = false;
  bool serviceAndNeedIsSelected = false;
  bool availabilityIsSelected = false;

  void selectService(type, index) {
    if (type == 4) {
      weekdays[index].select = !weekdays[index].select;
      print(weekdays[index].select);
      availabilityIsSelected = availabilityIsStatus();
    } else if (type == 3) {
      language[index].select = !language[index].select;
      languageIsSelected = checkLanguageStatus();
    } else if (type == 1) {
      desiredServices[index].select = !desiredServices[index].select;
      serviceAndNeedIsSelected = serviceAndNeedStatus(type);
    } else if (type == 6) {
      desiredServices[index].select = !desiredServices[index].select;
      serviceAndNeedIsSelected = serviceAndNeedStatus(type);
    } else if (type == 5) {
      conditions[index].select = !conditions[index].select;
      serviceAndNeedIsSelected = serviceAndNeedStatus(type);
    } else {
      conditions[index].select = !conditions[index].select;
      serviceAndNeedIsSelected = serviceAndNeedStatus(type);
    }
    notifyListeners();
  }

  availabilityIsStatus() {
    bool value = false;
    for (var item in weekdays) {
      if (item.select) {
        value = item.select;
      }
    }
    return value;
  }

  serviceAndNeedStatus(type) {
    bool value = false;
    bool val = false;

    if (type == 2) {
      for (var item in conditions) {
        if (item.select) {
          value = item.select;
        }
      }
    } else if (type == 1) {
      for (var item in desiredServices) {
        if (item.select) {
          val = item.select;
        }
      }
    } else {
      for (var item in conditions) {
        if (item.select) {
          value = item.select;
        }
      }
      for (var item in desiredServices) {
        if (item.select) {
          val = item.select;
        }
      }
    }
    return type == 2
        ? value
        : type == 1
            ? val
            : value == val;
  }

  checkLanguageStatus() {
    bool value = false;
    for (var item in language) {
      if (item.select) {
        value = item.select;
      }
    }
    return value;
  }

  void validateEmail(String? email) {
    emailError = isValidEmail(email);
    notifyListeners();
  }

  void validateName(String? name) {
    usernameError = isValidName(name, 'login.firstLastName'.tr());
    notifyListeners();
  }

  void validatePassword(String? password) {
    passwordError = isValidPassword(password);
    notifyListeners();
  }

  void validateNumber(String? number) {
    password = number!.replaceAll(RegExp("[()-]"), "");
    phoneNumberError = isValidPhoneNumber(number);
    notifyListeners();
  }

  void validateConformPassword(String? value) {
    confirmPassword = value;
    confirmPasswordError = isValidConfirmPasswords(password, value);
    notifyListeners();
  }

  void urlLaunchThroughLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  DateTime? firstDate;

  void selectDate() async {
    final pickedDate = await showDatePicker(
        context: navigatorKey.currentContext!,
        initialDate: firstDate ?? DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 100),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData().copyWith(
              colorScheme: const ColorScheme.light(
                  surface: AppColors.madison,
                  primary: AppColors.madison,
                  onPrimary: AppColors.white),
            ),
            child: DatePickerDialog(
              initialDate: firstDate ?? DateTime.now(),
              firstDate: DateTime(DateTime.now().year - 100),
              lastDate: DateTime.now(),
            ),
          );
        });
    if (pickedDate != null) {
      firstDate = pickedDate;
      dobController!.clear();
      dobController!.text =
          DateFormat('dd-MM-yyyy').format(firstDate!).toString();
    }
    notifyListeners();
  }

  RangeValues radiusRange = const RangeValues(0.0, 10 * 1000.0);
  Completer<GoogleMapController> controller = Completer();

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

  String? _maxDistance;

  String? get maxDistance => _maxDistance;

  set maxDistance(String? value) {
    _maxDistance = value;
    notifyListeners();
  }

  getGeoLocationPosition(type) async {
    final Uint8List markIcons =
        await getImages('assets/icon/location.png', 150);

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
    if (type) {
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
        icon: BitmapDescriptor.fromBytes(markIcons),
        position: LatLng(position!.latitude, position!.longitude),
      );
      await _getAddress(position!, false);
    } else {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(userModel!.location['lat'], userModel!.location['long']),
            zoom: 20.0,
          ),
        ),
      );
      marker = Marker(
        markerId: const MarkerId('mapMarker'),
        icon: BitmapDescriptor.fromBytes(markIcons),
        position:
            LatLng(userModel!.location['lat'], userModel!.location['long']),
      );
    }

    markers[const MarkerId('mapMarker')] = marker!;

    notifyListeners();
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Map<MarkerId, Marker> markers =
      <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS
  Marker? marker;

  setMapOnSearchLocation(Place place, type) async {
    markers.removeWhere(
        (key, value) => key == 'mapMarker'); //clear a specific marker
    final Uint8List markIcons =
        await getImages('assets/icon/location.png', 150);
    final geolocation = await place.geolocation;
    LatLng latLng = await geolocation!.coordinates;
    Coordinates coordinates =
        Coordinates(latitude: latLng.latitude, longitude: latLng.longitude);
    locationController!.text = place.description!;

    notifyListeners();

    try {
      if (type) {
        print("Latitude: ${coordinates.latitude}");
        print("Longitude: ${coordinates.longitude}");
        if (coordinates.latitude != null) {
          position = Position(
              longitude: coordinates.longitude!,
              latitude: coordinates.latitude!,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0);

          // LatLng(coordinates.latitude!, coordinates.longitude!) as Position?;
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position!.latitude, position!.longitude),
                zoom: 20.0,
              ),
            ),
          );
          marker = Marker(
            markerId: const MarkerId('mapMarker'),
            icon: BitmapDescriptor.fromBytes(markIcons),
            position: LatLng(position!.latitude, position!.longitude),
          );
        }
      } else {
        userModel!.location['lat'] = coordinates.latitude;
        userModel!.location['long'] = coordinates.longitude;
        userModel!.location['address'] = place.description;

        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                  userModel!.location['lat'], userModel!.location['long']),
              zoom: 20.0,
            ),
          ),
        );

        marker = Marker(
          markerId: const MarkerId('mapMarker'),
          icon: BitmapDescriptor.fromBytes(markIcons),
          position:
              LatLng(userModel!.location['lat'], userModel!.location['long']),
        );
      }
    } catch (e) {
      print(e);
    }
    markers[const MarkerId('mapMarker')] = marker!;

    notifyListeners();
  }

/*  addressLatLong(add) async {
    GeoCode geoCode = GeoCode();
    markers.removeWhere(
        (key, value) => key == 'mapMarker'); //clear a specific marker
    notifyListeners();
    final Uint8List markIcons =
        await getImages('assets/icon/location.png', 150);
    try {
      Coordinates coordinates = await geoCode.forwardGeocoding(address: add);

      print("Latitude: ${coordinates.latitude}");
      print("Longitude: ${coordinates.longitude}");
      if (coordinates.latitude != null) {
        position = Position(
            longitude: coordinates.longitude!,
            latitude: coordinates.latitude!,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0);

        // LatLng(coordinates.latitude!, coordinates.longitude!) as Position?;
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position!.latitude, position!.longitude),
              zoom: 20.0,
            ),
          ),
        );
        marker = Marker(
          markerId: const MarkerId('mapMarker'),
          icon: BitmapDescriptor.fromBytes(markIcons),
          position: LatLng(position!.latitude, position!.longitude),
        );
      }
    } catch (e) {
      print(e);
    }
    markers[const MarkerId('mapMarker')] = marker!;

    notifyListeners();
  }

  addLatLong(add, type) async {
    markers.removeWhere(
        (key, value) => key == 'mapMarker'); //clear a specific marker
    notifyListeners();
    final Uint8List markIcons =
        await getImages('assets/icon/location.png', 150);
    if (type) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position po) async {
        userModel!.location['lat'] = po.latitude;
        userModel!.location['long'] = po.longitude;
        notifyListeners();
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                  userModel!.location['lat'], userModel!.location['long']),
              zoom: 20.0,
            ),
          ),
        );
      });
      await _getAddress(
          LatLng(userModel!.location['lat'], userModel!.location['long']),
          true);
      marker = Marker(
        markerId: const MarkerId('mapMarker'),
        icon: BitmapDescriptor.fromBytes(markIcons),
        position:
            LatLng(userModel!.location['lat'], userModel!.location['long']),
      );
    } else {
      GeoCode geoCode = GeoCode();

      try {
        Coordinates coordinates = await geoCode.forwardGeocoding(address: add);

        print("Latitude: ${coordinates.latitude}");
        print("Longitude: ${coordinates.longitude}");
        if (coordinates.latitude != null) {
          userModel!.location['lat'] = coordinates.latitude;
          userModel!.location['long'] = coordinates.longitude;
          userModel!.location['address'] = add;
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                    userModel!.location['lat'], userModel!.location['long']),
                zoom: 20.0,
              ),
            ),
          );
          notifyListeners();
        }
      } catch (e) {
        print(e);
      }
      marker = Marker(
        markerId: const MarkerId('mapMarker'),
        icon: BitmapDescriptor.fromBytes(markIcons),
        position:
            LatLng(userModel!.location['lat'], userModel!.location['long']),
      );
    }
    markers[const MarkerId('mapMarker')] = marker!;
    notifyListeners();
  }*/

  _getAddress(po, type) async {
    // Places are retrieved using the coordinates
    List<Placemark> p =
        await placemarkFromCoordinates(po.latitude, po.longitude);

    // Taking the most probable result
    Placemark place = p[0];
    print('place');
    print(place);
    // Structuring the address

    locationController!.text =
        "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    if (type) {
      userModel!.location['address'] =
          "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    }
    notifyListeners();
  }

  getDataForProfile(type) async {
    await getLanguageList();
    await getConditionList();
    await getTaskList(10);
  }

  setDataOfProfile() async {
    for (var data in language) {
      for (var item in userModel!.languages!) {
        if (data.title == item.title) {
          data.select = true;
        }
      }
    }

    for (var data in conditions) {
      for (var item in userModel!.conditions!) {
        if (data.title == item.title) {
          data.select = true;
        }
      }
    }

    if (SharedPrefHelper.userType == '2') {
      for (var data in desiredServices) {
        for (var item in userModel!.volunteer['taskTypes']!) {
          if (data.title == item['code']) {
            data.select = true;
          }
        }
      }
    }

    if (SharedPrefHelper.userType == '2') {
      for (var data in weekdays) {
        for (var item in userModel!.volunteer['availabilities']!) {
          if (data.id == item['weekDay'].toString()) {
            data.select = true;
            data.startTime = item['start'].split('Z')[0];
            data.endTime = item['end'].split('Z')[0];
            data.end = null;
            data.start = null;
          }
        }
      }
    }

    notifyListeners();
  }

  getTaskList(limit) async {
    hideKeyboard();
    callApi(() async {
      ResponseData response = await AuthRepo.getTaskList(limit);
      if (response.isSuccessFul) {
        print(response.data);
        var json = jsonDecode(response.data);
        desiredServices =
            json.map((e) => ServiceAndNeedModel.fromJson(e)).toList();
        print('simarjot');
        print(desiredServices);
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
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  getLanguageList() {
    hideKeyboard();
    callApi(() async {
      ResponseData response = await AuthRepo.getLanguageList();
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        language = json.map((e) => LanguageModel.fromJson(e)).toList();
        print('simarjot');
        print(language);
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  getConditionList() {
    hideKeyboard();
    callApi(() async {
      ResponseData response = await AuthRepo.getConditionList();
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        conditions = json.map((e) => ServiceAndNeedModel.fromJson(e)).toList();
        print('simarjot');
        print(conditions);
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  String? uploadImageUrl;

  getImageUrl() {
    hideKeyboard();
    callApi(() async {
      ResponseData response = await AuthRepo.getImageUrl();
      if (response.isSuccessFul) {
        var json = jsonDecode(response.data);
        uploadImageUrl = json['url'];
        await uploadImage();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  showImageUrl() {
    hideKeyboard();
    callApi(() async {
      ResponseData response = await AuthRepo.getShowImageUrl();
      if (response.isSuccessFul) {
        userModel!.image = jsonDecode(response.data)['url'];
        changeImage = null;
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  uploadImage() {
    hideKeyboard();
    callApi(() async {
      ResponseData response =
          await AuthRepo.uploadImage(uploadImageUrl, changeImage!);
      if (response.isSuccessFul) {
        imageUploaded?.call();
        showImageUrl();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
    });
    notifyListeners();
  }

  UserModel? userModel = UserModel();

  Future<void> registerUser() async {
    hideKeyboard();
    String? mailCheck = isValidEmail(emailField);
    String? passwordValid = isValidPassword(password);
    String? nameValid = isValidName(username, "Full Name");
    String? confirmValid = isConfirmPasswordValid(password, confirmPassword);
    if (!RGPD) {
      snackBarText = 'validate.gdpr_not_selected'.tr();
      onError?.call();
    } else if (mailCheck != null) {
      snackBarText = mailCheck;
      onError?.call();
    } else if (passwordValid != null) {
      snackBarText = passwordValid;
      onError?.call();
    } else if (confirmValid != null) {
      snackBarText = confirmValid;
      onError?.call();
    } else {
      callApi(() async {
        String? token = await FirebaseMessaging.instance.getToken();
        Map<String, String> body = {
          "email": emailField!,
          // "name": '',
          "password": password!,
          "subject": ""
        };
        ResponseData response = await AuthRepo.register(body);
        if (response.isSuccessFul) {
          await AuthRepo.login(emailField, password, 2);
          snackBarText = response.message;
          onRegisteredSuccess?.call();
        } else {
          snackBarText = response.message;
          onError?.call();
        }
        notifyListeners();
      });
    }
  }

  void updateUserViaId(bool type) {
    hideKeyboard();
    if (isLoading) return;
    notifyListeners();

    List emergencyContacts = [];
    List languages = [];
    List condition = [];
    List availabilities = [];
    List taskTypes = [];

    for (var item in language) {
      if (item.select) {
        languages.add({
          "code": item.id,
          "name": '${item.title}'.tr(),
          "nativeName": '${item.title}'.tr()
        });
      }
    }

    for (var item in conditions) {
      if (item.select) {
        condition.add({
          "code": item.title,
          "id": item.id,
        });
      }
    }

    Map<String, dynamic> body = {};

    if (type) {
      //volunteer

      for (var item in weekdays) {
        if (item.select) {
          availabilities.add({
            "end":
                '${item.end!.hour}:${item.end!.minute > 9 ? item.end!.minute : '0${item.end!.minute}'}Z',
            "start":
                '${item.start!.hour}:${item.start!.minute > 9 ? item.start!.minute : '0${item.start!.minute}'}Z',
            "weekDay": int.parse(item.id!),
          });
        }
      }

      for (var item in desiredServices) {
        if (item.select) {
          taskTypes.add({
            "code": '${item.title}'.tr(),
            "id": item.id,
          });
        }
      }

      body = {
        "birthday": DateFormat('yyyy-MM-dd').format(firstDate!).toString(),
        "email": emailField,
        "fontScale": 0,
        "gender": "M",
        "conditions": condition,
        "location": {
          "address": locationController!.text,
          "lat": position!.latitude,
          "long": position!.longitude,
          "radius": int.parse(maxDistance!.split(' ')[0])
        },
        "name": username,
        "phoneNumber": phoneNumber,
        "languages": languages,
        "volunteer": {"availabilities": availabilities, "taskTypes": taskTypes}
      };
    } else {
      //elder
      for (var item in emergencyContactData) {
        emergencyContacts
            .add({"name": item.name, "phoneNumber": item.mobileNumber});
      }

      body = {
        "birthday": DateFormat('yyyy-MM-dd').format(firstDate!).toString(),
        "email": emailField,
        "fontScale": 0,
        "gender": "M",
        "conditions": condition,
        "location": {
          "address": locationController!.text,
          "lat": position!.latitude,
          "long": position!.longitude,
          "radius": 0
        },
        "name": username,
        "phoneNumber": phoneNumber,
        "languages": languages,
        "elder": {
          "emergencyContacts": emergencyContacts,
        }
      };
    }
    callApi(() async {
      ResponseData response = await AuthRepo.updateUserById(body);
      if (response.isSuccessFul) {
        snackBarText = response.message;
        profileUpdate?.call();
        clearAllData();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  void updateProfile(bool type) {
    hideKeyboard();
    if (isLoading) return;
    notifyListeners();

    List emergencyContacts = [];
    List languages = [];
    List condition = [];
    List availabilities = [];
    List taskTypes = [];

    for (var item in language) {
      if (item.select) {
        languages.add({
          "code": item.id,
          "name": '${item.title}'.tr(),
          "nativeName": '${item.title}'.tr()
        });
      }
    }

    for (var item in conditions) {
      if (item.select) {
        condition.add({
          "code": item.title,
          "id": item.id,
        });
      }
    }

    Map<String, dynamic> body = {};

    if (type) {
      //volunteer

      for (var item in weekdays) {
        if (item.select) {
          availabilities.add({
            "end": item.end != null
                ? '${item.end!.hour}:${item.end!.minute > 9 ? item.end!.minute : '0${item.end!.minute}'}Z'
                : '${item.endTime}Z',
            "start": item.start != null
                ? '${item.start!.hour}:${item.start!.minute > 9 ? item.start!.minute : '0${item.start!.minute}'}Z'
                : '${item.startTime}Z',
            "weekDay": int.parse(item.id!),
          });
        }
      }

      for (var item in desiredServices) {
        if (item.select) {
          taskTypes.add({
            "code": '${item.title}'.tr(),
            "id": item.id,
          });
        }
      }

      body = {
        "birthday": firstDate != null
            ? DateFormat('yyyy-MM-dd').format(firstDate!).toString()
            : userModel!.birthday,
        "email": userModel!.email,
        "fontScale": 0,
        "gender": "M",
        "conditions": condition,
        "location": {
          "address": locationController!.text,
          "lat": userModel!.location['lat'],
          "long": userModel!.location['long'],
          "radius": userModel!.location['radius']
        },
        "name": userModel!.name,
        "phoneNumber": userModel!.phoneNumber,
        "languages": languages,
        "volunteer": {"availabilities": availabilities, "taskTypes": taskTypes}
      };
    } else {
      //elder
      if (userModel!.elder != null && userModel!.elder.isNotEmpty) {
        for (var item in userModel!.elder['emergencyContacts']) {
          emergencyContacts
              .add({"name": item['name'], "phoneNumber": item['phoneNumber']});
        }
      }

      body = {
        "birthday": firstDate != null
            ? DateFormat('yyyy-MM-dd').format(firstDate!).toString()
            : userModel!.birthday,
        "email": userModel!.email,
        "fontScale": 0,
        "gender": "M",
        "conditions": condition,
        "location": {
          "address": locationController!.text,
          "lat": userModel!.location['lat'],
          "long": userModel!.location['long'],
          "radius": 0
        },
        "name": userModel!.name,
        "phoneNumber": userModel!.phoneNumber,
        "languages": languages,
        "elder": {
          "emergencyContacts": emergencyContacts,
        }
      };
    }
    callApi(() async {
      ResponseData response = await AuthRepo.updateUserById(body);
      if (response.isSuccessFul) {
        snackBarText = response.message;
        userModel = UserModel.fromJson(jsonDecode(response.data));
        if (changeImage == null) {
          await showImageUrl();
          profileEdited?.call();
        } else {
          await getImageUrl();
          profileEdited?.call();
        }
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  checkConditions(id) {
    for (var item in conditions) {
      if (item.id == id) {
        return item.select;
      } else {
        return item.select;
      }
    }
  }

  void validateWithUsScreen() async {
    hideKeyboard();

    String? nameValid = isValidName(
      username,
      'login.firstLastName'.tr(),
    );

    String? mobile = isValidPhoneNumber(phoneNumber);
    bool? dob = isAdult(dobController!.text);
    if (nameValid != null) {
      snackBarText = nameValid;
      onError?.call();
    } else if (mobile != null) {
      snackBarText = mobile;
      onError?.call();
    } else if (!dob) {
      snackBarText =
          '${'login.dateOfBirth'.tr()} ${'validate.isNotValid'.tr()}';
      onError?.call();
    } else {
      onWithUsValidateSuccess?.call();
    }
  }

  void loginUser() {
    hideKeyboard();
    String? mailCheck = isValidEmail(emailField);
    String? passwordValid = isValidPassword(password);
    if (mailCheck != null) {
      snackBarText = mailCheck;
      onError?.call();
    } else if (passwordValid != null) {
      snackBarText = passwordValid;
      onError?.call();
    } else {
      callApi(() async {
        ResponseData response = await AuthRepo.login(emailField, password, 1);

        if (response.isSuccessFul) {
          snackBarText = response.message;
          userModel = UserModel.fromJson(jsonDecode(response.data));
          changeIndex.value = 0;
          // changeIndex.notifyListeners();
          onLoginSuccess?.call();
        } else {
          snackBarText = response.message;
          onError?.call();
        }
        notifyListeners();
      });
    }
  }

  Future<void> getUserData() async {
    hideKeyboard();

    callApi(() async {
      ResponseData rd = await AuthRepo.userById();

      if (rd.isSuccessFul) {
        snackBarText = rd.message;
        userModel = UserModel.fromJson(jsonDecode(rd.data));
        await showImageUrl();
      } else {
        snackBarText = rd.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  void forgotCall(email) {
    hideKeyboard();
    String? mailCheck = isValidEmail(email ?? emailField);
    if (mailCheck != null) {
      snackBarText = mailCheck;
      onError?.call();
    } else {
      callApi(() async {
        Map<String, String> body = {"email": email ?? emailField!};
        ResponseData response =
            await AuthRepo.forgot(body, email ?? emailField);
        if (response.isSuccessFul) {
          snackBarText = response.message;
          onForgotSuccess?.call();
          clearAllData();
        } else {
          snackBarText = response.message;
          onError?.call();
        }
      });
    }
  }

  clearAllData() {
    dobController!.clear();
    locationController!.clear();
    emergencyContactData.clear();
    username = null;
    phoneNumber = null;
    password = null;
    confirmPassword = null;
    emailError = null;
    maxDistance = null;
    contactName = null;
    contactName = null;
    changeImage = null;
    notEnterCheck = false;
    emergencyContactData = [];
    languageIsSelected = false;
    serviceAndNeedIsSelected = false;
    availabilityIsSelected = false;
    firstDate = null;
    notifyListeners();
  }

  /*social media start*/

  String _getType(SocialType socialType) {
    switch (socialType) {
      case SocialType.apple:
        return "3";
      case SocialType.facebook:
        return "2";
      case SocialType.google:
        return "1";
      case SocialType.email:
        return "0";
    }
  }

  void _socialMediaLogin(SocialData socialData) {
    callApi(() async {
      String? token = await FirebaseMessaging.instance.getToken();
      String deviceId = await FlutterUdid.consistentUdid;
      if (token != null) {
        Map<String, String> body = {
          "email": socialData.email,
          "login_by": _getType(socialData.type),
          "user_type": "3",
          "phone_number": socialData.mobile,
          "device_id": deviceId,
          "fcm_token": token,
          "full_name": socialData.username
        };
        ResponseData response = await AuthRepo.socialLogin(body);
        if (response.isSuccessFul) {
          snackBarText = response.message;
          _socialLoginLogOut(socialData.type, true);
          onLoginSuccess?.call();
        } else {
          snackBarText = response.message;
          _socialLoginLogOut(socialData.type, false);
          onError?.call();
        }
      } else {
        _socialLoginLogOut(socialData.type, false);
        snackBarText = "Token Not Generate.Restart App And Try Again.";
        onError?.call();
      }
    });
  }

  void _socialLoginLogOut(SocialType socialType, bool isLogin) {
    switch (socialType) {
      case SocialType.facebook:
        if (isLogin) SharedPrefHelper.loginType = facebook;
        if (!isLogin) FacebookAuth.instance.logOut();
        break;
      case SocialType.google:
        if (isLogin) SharedPrefHelper.loginType = google;
        if (!isLogin) _googleSignIn.signOut();
        break;
      case SocialType.apple:
        if (isLogin) SharedPrefHelper.loginType = apple;
        break;
      case SocialType.email:
        if (isLogin) SharedPrefHelper.loginType = email;
        break;
    }
  }

  void googleUser() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        SocialData socialData = SocialData(
            email: googleSignInAccount.email,
            username: googleSignInAccount.displayName ?? "",
            mobile: "",
            type: SocialType.google);
        _socialMediaLogin(socialData);
      } else {
        snackBarText = "Something Went Wrong With Google Authentication!!";
        onError?.call();
      }
    } catch (error) {
      snackBarText = "Exception $error";
      onError?.call();
    }
  }

  void facebookUser() async {
    try {
      final LoginResult result = await FacebookAuth.instance
          .login(loginBehavior: LoginBehavior.webOnly);
      if (result.status == LoginStatus.success) {
        Map<String, dynamic> userData =
            await FacebookAuth.instance.getUserData();
        SocialData socialData = SocialData(
            email: userData["email"],
            username: userData["name"],
            mobile: userData["mobile"] ?? "",
            type: SocialType.facebook);
        _socialMediaLogin(socialData);
      } else {
        snackBarText = "Something Went Wrong With Facebook Authentication!!";
        onError?.call();
      }
    } catch (error) {
      snackBarText = "Exception $error";
      onError?.call();
    }
  }

/*social media end*/
/*help contact start */
  Future<void> makePhoneCall(String contact) async {
    String telScheme = 'tel:$contact';

    if (await canLaunch(telScheme)) {
      await launch(telScheme);
    } else {
      throw 'Could not launch $telScheme';
    }
  }

/*help contact  end*/

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
}

class SocialData {
  String email, username, mobile;
  SocialType type;

  SocialData(
      {required this.email,
      required this.username,
      required this.type,
      required this.mobile});

  factory SocialData.fromJson(var json) {
    return SocialData(
        email: json["email"],
        type: json["type"],
        username: json["username"],
        mobile: json["mobile"]);
  }
}

enum SocialType { facebook, google, apple, email }
