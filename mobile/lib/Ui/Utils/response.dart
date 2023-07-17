import 'package:flutter/material.dart';

@immutable
class Response {
  final bool isSuccessFul;
  final String message;

  const Response(this.isSuccessFul, this.message);

  factory Response.fromJson(Map<String, dynamic> json) {
    final s = json['success'] as bool;
    final m = json['message'] as String;
    return Response(s, m);
  }
}

class ResponseData {
  final bool isSuccessFul;
  final String message;
  final String data;

  const ResponseData(this.isSuccessFul, this.message, this.data);

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    final s = json['status'] as bool;
    final m = json['message'] as String;
    final d = json['data'] as String;
    return ResponseData(s, m, d);
  }
}

class ResponseBody {
  final String data;
  final int code;

  const ResponseBody(this.data, this.code);

  factory ResponseBody.fromJson(Map<String, dynamic> json) {
    final b = json['data'] as String;
    final c = json['code'] as int;
    return ResponseBody(b,c);
  }
}
