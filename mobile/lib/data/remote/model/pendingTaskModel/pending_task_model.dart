import 'package:ajuda/data/remote/model/serviceAndNeedModel/serviceAndNeed_model.dart';

class PendingTaskModel {
  String? id, createdAt, updatedAt, state, taskId, taskTypeId, userId,comment;
  int? rating;
  Task? task;

  PendingTaskModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.state,
    this.taskId,
    this.taskTypeId,
    this.userId,
    this.task,
  });

  PendingTaskModel.fromJson(data) {
    id = data['id'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
    state = data['state'];
    taskId = data['taskId'];
    taskTypeId = data['taskTypeId'];
    userId = data['userId'];
    comment = data['comment']??'';
    rating = data['rating']??0;
    task = Task.fromJson(data['task']);
  }
}

class Task {
  String? id, createdAt, updatedAt, description, date, requesterId, taskTypeId,timeTo,timeFrom;
  ServiceAndNeedModel? taskType;
  Requester? requester;


  Task({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.date,
    this.requesterId,
    this.taskTypeId,
    this.timeTo,
    this.timeFrom,
    this.taskType,
    this.requester,
  });

  Task.fromJson(data) {
    id = data['id'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
    timeFrom = data['timeFrom'];
    timeTo = data['timeTo'];
    description = data['description'];
    date = data['date'];
    requesterId = data['requesterId'];
    taskTypeId = data['taskTypeId'];
    taskType = ServiceAndNeedModel.fromJson(data['taskType']);
    requester = Requester.fromJson(data['requester']);
  }
}

class Requester {
  String? id,
      createdAt,
      updatedAt,
      name,
      birthday,
      gender,
      phoneNumber,
      subject,
      email,
      image;
  bool? verified;

  Requester({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.birthday,
    this.gender,
    this.phoneNumber,
    this.subject,
    this.email,
    this.image,
    this.verified,
  });

  Requester.fromJson(data) {
    id = data['id'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
    name = data['name'];
    birthday = data['birthday'];
    gender = data['gender'];
    phoneNumber = data['phoneNumber'];
    subject = data['subject'];
    email = data['email'];
    image = data['image']??'';
    verified = data['verified'];
  }
}
