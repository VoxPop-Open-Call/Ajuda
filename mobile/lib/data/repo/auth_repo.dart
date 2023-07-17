import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../../Ui/Utils/response.dart';
import '../local/shared_pref_helper.dart';
import '../remote/networking.dart';
import '../remote/url_constants.dart';

class AuthRepo {
  ///in memory cache of user

  //--------Register Password--------//
  static Future<ResponseData> register(Map<String, String> body) async {
    ResponseBody responseBody =
        await Networking.post(Endpoints.kUserUrl, jsonEncode(body));
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      SharedPrefHelper.userId = jsonDecode(responseBody.data)['id'];

      // SharedPrefHelper.accessToken = jsonDecode(responseBody.data)['access_token'];
      return ResponseData(true, 'success.register'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> updateUserById(Map<String, dynamic> body) async {
    ResponseBody responseBody = await Networking.put(
        "${Endpoints.kUserUrl}/${SharedPrefHelper.userId}", jsonEncode(body));
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      SharedPrefHelper.userId = jsonDecode(responseBody.data)['id'];
      return ResponseData(true, 'success.update'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      print(responseJson['error']['message']);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getImageUrl() async {
    ResponseBody responseBody = await Networking.get(
        "${Endpoints.kUserUrl}/${SharedPrefHelper.userId}${Endpoints.kUploadImageUrl}");

    if (responseBody.code == 200 || responseBody.code == 201) {
      return ResponseData(true, 'success.register'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      print(responseJson['error']['message']);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> uploadImage(url, File image) async {
    ResponseBody responseBody =
        await Networking.putWithoutHeader(url, image.readAsBytesSync());

    if (responseBody.code == 200 || responseBody.code == 201) {
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else if (responseBody.code == 403) {
      return ResponseData(false, responseBody.code.toString(), '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getShowImageUrl({id}) async {
    ResponseBody responseBody = await Networking.get(
        "${Endpoints.kUserUrl}/${id ?? SharedPrefHelper.userId}${Endpoints.kGetImageUrl}");

    if (responseBody.code == 200 || responseBody.code == 201) {
      return ResponseData(true, 'success.register'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      print(responseJson['error']['message']);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  //--------Login Password--------//
  static Future<ResponseData> login(emailField, password, type) async {
    final response = await http.post(
      Uri.parse(Endpoints.kApiTokenCrateUrl),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        "username": emailField!,
        "password": password!,
        "grant_type": 'password',
        "client_id": "android-app",
        "client_secret":
            "mYsjpwxRnKH48N5VHr3fqaL5CNgah0stGdooME68tIb8XGyhmu5WjttcYp7gggYN",
        "scope": 'openid profile email offline_access'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseJson = jsonDecode(response.body);
      SharedPrefHelper.refreshToken = responseJson['refresh_token'];
      SharedPrefHelper.accessToken = responseJson['access_token'];
      SharedPrefHelper.idToken = responseJson['id_token'];
      if (type == 1) {
        var data = parseJwt(responseJson['access_token']);
        SharedPrefHelper.userId = data['name'];
        ResponseData rd = await userById();
        return ResponseData(true, 'success;login'.tr(), rd.data);
      } else {
        return ResponseData(true, 'success;login'.tr(), '');
      }
    } else if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      final responseJson = jsonDecode(response.body);
      return ResponseData(false, responseJson['error_description'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<bool> refreshToken() async {
    final response = await http.post(
      Uri.parse(Endpoints.kApiTokenCrateUrl),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName('utf-8'),
      body: {
        "refresh_token": SharedPrefHelper.refreshToken,
        "grant_type": 'refresh_token',
        "client_id": "android-app",
        "client_secret":
            "mYsjpwxRnKH48N5VHr3fqaL5CNgah0stGdooME68tIb8XGyhmu5WjttcYp7gggYN",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseJson = jsonDecode(response.body);
      SharedPrefHelper.accessToken = responseJson['access_token'];
      SharedPrefHelper.refreshToken = responseJson['refresh_token'];
      SharedPrefHelper.idToken = responseJson['id_token'];
      ResponseData rd = await userById();
      return true;
    } else if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      return false;
    } else {
      return false;
    }
  }

  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  static Future<ResponseData> userById({id}) async {
    ResponseBody responseBody = await Networking.get(
        '${Endpoints.kUserUrl}/${id ?? SharedPrefHelper.userId}');
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      if (id == null) {
        SharedPrefHelper.userId = jsonDecode(responseBody.data)['id'];
      }
      return ResponseData(true, 'success.register'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  //--------Social Login Password--------//
  static Future<ResponseData> socialLogin(Map<String, String> body) async {
    final response =
        await Networking.post(Endpoints.kUserUrl, jsonEncode(body));
    final responseJson = jsonDecode(response.data);
    return ResponseData(
        responseJson['success'], responseJson['message'], responseJson['data']);
  }

  //--------Forgot Password--------//
  static Future<ResponseData> forgot(Map<String, String> body, email) async {
    //making api call
    ResponseBody responseBody =
        await Networking.put(Endpoints.kResetUrl, jsonEncode(body));
    //parsing json data
    if (responseBody.code == 200 ||
        responseBody.code == 201 ||
        responseBody.code == 202) {
      SharedPrefHelper.email = email;
      return ResponseData(true, 'forgot.linkSuccess'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  //---- resendOtp  ----//

  //---- Profile -----//

  static Future<ResponseData> getTaskList(int limit) async {
    //calling the api
    ResponseBody responseBody =
        await Networking.get('${Endpoints.kTasksUrl}?orderBy=id%20asc');

    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      return ResponseData(true, 'success.register'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getLanguageList() async {
    //calling the api
    ResponseBody responseBody =
        await Networking.get('${Endpoints.kLanguagesUrl}?&orderBy=code%20asc');

    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      return ResponseData(true, 'success.register'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getConditionList() async {
    //calling the api
    ResponseBody responseBody =
        await Networking.get('${Endpoints.kConditionsUrl}?orderBy=id%20asc');

    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      return ResponseData(true, 'success.register'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403 ||
        responseBody.code == 404) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  //---- Fcm -----//
  static Future<ResponseData> updateFcm() async {
    String? token = await FirebaseMessaging.instance.getToken();
    Map<String, dynamic> body = {'token': token};
    ResponseBody rb =
        await Networking.post(Endpoints.kFcmUrl, jsonEncode(body));
    final responseJson = jsonDecode(rb.data);
    print(responseJson);
    //parsing json data
    if (rb.code == 200 || rb.code == 201) {
      return ResponseData(true, '', rb.data);
    } else if (rb.code == 400 || rb.code == 401 || rb.code == 403) {
      final responseJson = jsonDecode(rb.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<Response> updateProfileDetails(
      http.MultipartRequest request) async {
    final streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final res = Response.fromJson(responseJson);
    return res;
  }
}
