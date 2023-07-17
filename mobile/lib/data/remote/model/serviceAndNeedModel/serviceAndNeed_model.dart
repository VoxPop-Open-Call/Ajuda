import 'package:flutter/material.dart';

class ServiceAndNeedModel {
  String? title;
  String? icon;
  TimeOfDay? start;
  String? startTime;
  TimeOfDay? end;
  String? endTime;
  bool select = false;
  String? id;

  ServiceAndNeedModel(
      {required this.title,
      this.icon,
      this.startTime,
      this.endTime,
      this.id,
      this.end,
      this.start});

  ServiceAndNeedModel.fromJson(data) {
    title = data['code'];
    id = data['id'];
  }
}
