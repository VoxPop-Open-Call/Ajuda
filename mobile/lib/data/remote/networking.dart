import 'dart:convert';

import 'package:ajuda/data/repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Ui/Utils/response.dart';
import '../local/shared_pref_helper.dart';

class Networking {
  static Future<ResponseBody> post(url, body) async {
    Map<String, String> header = {
      'Authorization': "Bearer ${SharedPrefHelper.accessToken}",
      'Content-Type': 'application/json'
    };
    debugPrint(url);
    debugPrint(SharedPrefHelper.accessToken);
    final http.Response res = await http.post(
      Uri.parse(url),
      body: body,
      headers: header,
    );
    print('check post api');
    debugPrint(res.statusCode.toString());
    debugPrint(res.hashCode.toString());
    debugPrint(res.toString());
    if (res.statusCode == 201 || res.statusCode == 200) {
      return ResponseBody(res.body, res.statusCode);
    } else if (res.statusCode == 400 ||
        res.statusCode == 401 ||
        res.statusCode == 403||
        res.statusCode == 404) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['error']['code'] == 'Invalid Authorization Token') {
        await AuthRepo.refreshToken();
        return post(url, body);
      } else {
        return ResponseBody(res.body, res.statusCode);
      }
    } else {
      return ResponseBody('', res.statusCode);
    }
  }
  static Future<ResponseBody> postWithoutHeader(url, body) async {
    Map<String, String> header = {
      'Content-Type': 'application/json'
    };
    debugPrint(url);
    debugPrint(SharedPrefHelper.accessToken);
    final http.Response res = await http.post(
      Uri.parse(url),
      body: body,
      headers: header,
    );
    print('check post api');
    debugPrint(res.statusCode.toString());
    debugPrint(res.hashCode.toString());
    debugPrint(res.toString());
    if (res.statusCode == 201 || res.statusCode == 200) {
      return ResponseBody(res.body, res.statusCode);
    } else if (res.statusCode == 400 ||
        res.statusCode == 401 ||
        res.statusCode == 403||
        res.statusCode == 404) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['error']['code'] == 'Invalid Authorization Token') {
        await AuthRepo.refreshToken();
        return postWithoutHeader(url, body);
      } else {
        return ResponseBody(res.body, res.statusCode);
      }
    } else {
      return ResponseBody('', res.statusCode);
    }
  }

  static Future<ResponseBody> get(url) async {
    debugPrint(SharedPrefHelper.accessToken);

    Map<String, String> header = {
      'Authorization': "Bearer ${SharedPrefHelper.accessToken}",
      'Content-Type': 'application/json'
    };

    debugPrint(url);

    http.Response res = await http.get(Uri.parse(url), headers: header);
    if (res.statusCode == 201 || res.statusCode == 200) {
      return ResponseBody(res.body, res.statusCode);
    } else if (res.statusCode == 400 ||
        res.statusCode == 401 ||
        res.statusCode == 403||
        res.statusCode == 404) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['error']['code'] == 'Invalid Authorization Token') {
        await AuthRepo.refreshToken();
        return get(url);
      } else {
        return ResponseBody(res.body, res.statusCode);
      }
    } else {
      return ResponseBody('', res.statusCode);
    }
  }

  static Future<ResponseBody> getWithoutHeader(url) async {
    debugPrint(SharedPrefHelper.accessToken);

    debugPrint(url);

    http.Response res = await http.get(Uri.parse(url));
    if (res.statusCode == 201 || res.statusCode == 200) {
      return ResponseBody(res.body, res.statusCode);
    } else if (res.statusCode == 400 ||
        res.statusCode == 401 ||
        res.statusCode == 403||
        res.statusCode == 404) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['error']['code'] == 'Invalid Authorization Token') {
        await AuthRepo.refreshToken();
        return getWithoutHeader(url);
      } else {
        return ResponseBody(res.body, res.statusCode);
      }
    } else {
      return ResponseBody('', res.statusCode);
    }
  }

  static Future<ResponseBody> put(url, body) async {
    debugPrint(url);

    Map<String, String> header = {
      'Authorization': "Bearer ${SharedPrefHelper.accessToken}",
      'Content-Type': 'application/json'
    };
    debugPrint(SharedPrefHelper.accessToken);
    debugPrint(body);

    http.Response res =
        await http.put(Uri.parse(url), headers: header, body: body);

    if (res.statusCode == 201 || res.statusCode == 200|| res.statusCode == 202) {
      return ResponseBody(res.body, res.statusCode);
    } else if (res.statusCode == 400 ||
        res.statusCode == 401 ||
        res.statusCode == 403 ||
        res.statusCode == 404) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['error']['code'] == 'Invalid Authorization Token') {
        await AuthRepo.refreshToken();

        return put(url, body);
      } else {
        return ResponseBody(res.body, 400);
      }
    } else {
      return ResponseBody('', res.statusCode);
    }
  }

  static Future<ResponseBody> delete(url) async {
    Map<String, String> header = {
      'Authorization': "Bearer ${SharedPrefHelper.accessToken}",
      'Content-Type': 'application/json'
    };
    debugPrint(SharedPrefHelper.accessToken);

    http.Response res = await http.delete(Uri.parse(url), headers: header);

    if (res.statusCode == 201 ||
        res.statusCode == 200 ||
        res.statusCode == 204) {
      return ResponseBody(res.body, res.statusCode);
    } else if (res.statusCode == 400 ||
        res.statusCode == 401 ||
        res.statusCode == 403||
        res.statusCode == 404) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['error']['code'] == 'Invalid Authorization Token') {
        await AuthRepo.refreshToken();

        return delete(url);
      } else {
        return ResponseBody(res.body, res.statusCode);
      }
    } else {
      return ResponseBody('', res.statusCode);
    }
  }

  static Future<ResponseBody> putWithoutHeader(url, body) async {
    debugPrint(url);

    debugPrint(SharedPrefHelper.accessToken);
    // debugPrint(body);

    http.Response res = await http.put(Uri.parse(url), body: body);

    if (res.statusCode == 201 || res.statusCode == 200) {
      return ResponseBody(res.body, res.statusCode);
    } else if (res.statusCode == 400 ||
        res.statusCode == 401 ||
        res.statusCode == 403||
        res.statusCode == 404) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['error']['code'] == 'Invalid Authorization Token') {
        await AuthRepo.refreshToken();
        return putWithoutHeader(url, body);
      } else {
        return ResponseBody(res.body, res.statusCode);
      }
      return ResponseBody(res.body, res.statusCode);
    } else {
      return ResponseBody('', res.statusCode);
    }
  }
}
