import 'dart:convert';

import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import '../../Ui/Utils/response.dart';
import '../remote/networking.dart';
import '../remote/url_constants.dart';

class HomeRepo {
  /////------- Agent List -----////////
  static Future<ResponseData> getNewsTab() async {
    //calling the api
    ResponseBody responseBody = await Networking.get(Endpoints.kNewsTabUrl);
    //parsing json data

    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getNewsList() async {
    //calling the api
    ResponseBody responseBody = await Networking.get(
        '${Endpoints.kNewsUrl}?offset=0&orderBy=id%20asc&type=news');
    //parsing json data

    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getNewsSubjectRelatedList(subject) async {
    //calling the api
    ResponseBody responseBody = await Networking.get(
        '${Endpoints.kNewsUrl}?offset=0&orderBy=id%20asc&subject=$subject&type=news');

    //parsing json data

    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  //---- Accept  ----//
  static Future<Response> updateAcc(http.MultipartRequest request) async {
    final streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final res = Response.fromJson(responseJson);
    return res;
  }

  //---- Reject  ----//
  static Future<Response> updateRej(http.MultipartRequest request) async {
    final streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final res = Response.fromJson(responseJson);
    return res;
  }

  /////------- Volunteer List -----////////
  static Future<ResponseData> getVolunteerList(
      date, search, taskTypeCode, timeFrom, timeTo, specificTime) async {
    //calling the api
    ResponseBody responseBody = await Networking.get(specificTime
        ? '${Endpoints.kGetVolunteerList}?date=$date&search=$search&taskTypeCode=$taskTypeCode'
        : '${Endpoints.kGetVolunteerList}?date=$date&search=$search&taskTypeCode=$taskTypeCode&timeFrom=${convertSymbol(timeFrom)}&timeTo=${convertSymbol(timeTo)}');

    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getVolunteerWithoutFilterList(
      taskType, from, to) async {
    //calling the api
    // ResponseBody responseBody = await Networking.get(
    //     '${Endpoints.kGetVolunteerList}?date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    ResponseBody responseBody = await Networking.get(taskType == null &&
            from == null &&
            to == null
        ? '${Endpoints.kGetVolunteerList}?date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}'
        : taskType != null && from == null && to == null
            ? '${Endpoints.kGetVolunteerList}?date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}&taskTypeCode=$taskType'
            : taskType == null && from != null && to != null
                ? '${Endpoints.kGetVolunteerList}?date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}&timeFrom=${convertSymbol(from)}&timeTo=${convertSymbol(to)}'
                : '${Endpoints.kGetVolunteerList}?date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}&taskTypeCode=$taskType&timeFrom=${convertSymbol(from)}&timeTo=${convertSymbol(to)}');

    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  /////------- Request -----////////
  static Future<ResponseData> createRequest(body) async {
    //calling the api

    ResponseBody responseBody =
        await Networking.post(Endpoints.kCreateTaskUrl, jsonEncode(body));
    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> assignmentsRequest(body) async {
    //calling the api

    ResponseBody responseBody =
        await Networking.post(Endpoints.kAssignmentsUrl, jsonEncode(body));
    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> acceptRequest(id) async {
    //calling the api

    ResponseBody responseBody = await Networking.put(
        '${Endpoints.kAssignmentsUrl}/$id/accept', jsonEncode({}));
    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, 'success.accept'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> rejectRequest(id) async {
    //calling the api

    ResponseBody responseBody = await Networking.put(
        '${Endpoints.kAssignmentsUrl}/$id/reject', jsonEncode({}));
    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, 'success.reject'.tr(), responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  /////------- Review request -----////////
  static Future<ResponseData> reviewRequest(id, body) async {
    //calling the api

    ResponseBody responseBody = await Networking.put(
        '${Endpoints.kAssignmentsUrl}/$id/review', jsonEncode(body));
    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  /////------- Task Data of list cancel, upcoming and complete -----////////

  static Future<ResponseData> getCancelTask(id) async {
    //calling the api
    ResponseBody responseBody = await Networking.put(
        '${Endpoints.kGetTaskList}/$id/cancel', jsonEncode({}));
    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getUpcomingTask() async {
    //calling the api
    ResponseBody? responseBody;
    if (SharedPrefHelper.userType == '1') {
      responseBody = await Networking.get(
          '${Endpoints.kGetTaskList}?completed=false&offset=0&orderBy=id%20asc&upcoming=true');
    } else {
      responseBody = await Networking.get(
          '${Endpoints.kAssignmentsUrl}?completed=false&offset=0&orderBy=id%20asc&upcoming=true');
    }
    //parsing json data
    if (responseBody!.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getPendingTask() async {
    //calling the api
    ResponseBody responseBody = await Networking.get(
        '${Endpoints.kAssignmentsUrl}?offset=0&orderBy=id%20asc');

    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> getCompleteTask() async {
    //calling the api
    ResponseBody? responseBody;
    if (SharedPrefHelper.userType == '1') {
      responseBody = await Networking.get(
          '${Endpoints.kGetTaskList}?completed=true&offset=0&orderBy=id%20asc&upcoming=false');
    } else {
      responseBody = await Networking.get(
          '${Endpoints.kAssignmentsUrl}?completed=true&offset=0&orderBy=id%20asc&upcoming=false');
    }
    //parsing json data
    if (responseBody!.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static convertSymbol(String data) {
    var first = data.replaceAll(':', '%3A');
    return first.replaceAll('+', '%2B');
  }

  static Future<ResponseData> deletedAccount() async {
    //calling the api
    ResponseBody responseBody = await Networking.delete(
        '${Endpoints.kUserUrl}/${SharedPrefHelper.userId}');
    //parsing json data
    if (responseBody.code == 200 ||
        responseBody.code == 201 ||
        responseBody.code == 204) {
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }

  static Future<ResponseData> userHistory(id) async {
    /*SharedPrefHelper.userId*/
    //calling the api
    ResponseBody responseBody = await Networking.get(
        '${Endpoints.kUserUrl}/$id/reviews?offset=0&orderBy=id%20asc');
    //parsing json data
    if (responseBody.code == 200 || responseBody.code == 201) {
      return ResponseData(true, '', responseBody.data);
    } else if (responseBody.code == 400 ||
        responseBody.code == 401 ||
        responseBody.code == 403) {
      final responseJson = jsonDecode(responseBody.data);
      return ResponseData(false, responseJson['error']['message'], '');
    } else {
      return ResponseData(false, 'errorMessage.error'.tr(), '');
    }
  }
}
