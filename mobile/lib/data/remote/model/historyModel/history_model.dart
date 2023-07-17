import 'package:ajuda/data/remote/model/taskModel/task_model.dart';

class HistoryModel {
  String? comment, id, rating, taskId;
  TaskModel? task;

  HistoryModel({
    this.comment,
    this.id,
    this.rating,
    this.taskId,
    this.task,
  });

  HistoryModel.fromJson(data) {
    comment = data['comment'];
    id = data['id'];
    rating = data['rating'].toString();
    taskId = data['taskId'];
    task = TaskModel.fromJson(data['task']);
  }
}
