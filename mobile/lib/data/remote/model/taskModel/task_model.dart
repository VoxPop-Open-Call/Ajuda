import 'package:ajuda/data/remote/model/serviceAndNeedModel/serviceAndNeed_model.dart';
import 'package:ajuda/data/remote/model/userModel/user_model.dart';

class TaskModel {
  List<dynamic>? assignments;
  String? date, description, id, requesterId, taskTypeId, timeFrom, timeTo;

  UserModel? requester;
  UserModel? volunteer;

  ServiceAndNeedModel? taskType;

  TaskModel({
    this.assignments,
    this.date,
    this.description,
    this.id,
    this.requesterId,
    this.taskTypeId,
    this.timeFrom,
    this.timeTo,
    this.requester,
    this.taskType,
    this.volunteer
  });

  TaskModel.fromJson(data) {
    assignments = data['assignments'] != null
        ? data['assignments'].map((e) => Assignments.fromJson(e)).toList()
        : [];
    date = data['date'];
    description = data['description'];
    id = data['id'];
    requesterId = data['requesterId'];
    taskTypeId = data['taskTypeId'];
    timeFrom = data['timeFrom'];
    timeTo = data['timeTo'];
    requester = UserModel.fromJson(data['requester']);
    taskType = ServiceAndNeedModel.fromJson(data['taskType']);
  }
}

class Assignments {
  String? comment;
  String? createdAt;
  String? id;
  String? rating;
  String? state;
  String? task;
  String? taskId;
  String? updatedAt;
  String? userId;

  Assignments({
    this.comment,
    this.createdAt,
    this.id,
    this.rating,
    this.state,
    this.task,
    this.taskId,
    this.updatedAt,
    this.userId,
  });

  Assignments.fromJson(data) {
    comment = data['comment'];
    createdAt = data['createdAt'];
    id = data['id'];
    rating = data['rating'].toString();
    state = data['state'];
    task = data['task'];
    taskId = data['taskId'];
    updatedAt = data['updatedAt'];
    userId = data['userId'];
  }
}
