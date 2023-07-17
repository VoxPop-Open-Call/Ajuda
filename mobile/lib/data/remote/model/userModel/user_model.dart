import 'package:ajuda/data/remote/model/langaugeModel/langauge_model.dart';
import 'package:ajuda/data/remote/model/serviceAndNeedModel/serviceAndNeed_model.dart';

class UserModel {
  String? birthday, name, email, phoneNumber, gender, id, subject, createdAt;
  int? fontScale;
  String? image;
  bool? verified;
  List<dynamic>? conditions;
  List<dynamic>? languages;
  List<dynamic>? historyData;
  var location;
  var elder;
  var volunteer;

  /*"elder": {
  "emergencyContacts": [
  {
  "name": "string",
  "phoneNumber": "string"
  }
  ]
  },
  */
  /*"location": {
  "address": "string",
  "lat": 0,
  "long": 0,
  "radius": 0
  },*/
  /*"volunteer": {
  "availabilities": [
  {
  "end": "12:00Z",
  "start": "12:00Z",
  "weekDay": 0
  }
  ],
  "taskTypes": [
  {
  "code": "pharmacy",
  "createdAt": "2023-03-30T17:23:57.146262+02:00",
  "id": "45314277-a7a3-41d4-9626-a5f00db330fa",
  "updatedAt": "2023-03-30T17:34:43.497929+02:00"
  }
  ]
  }*/

  UserModel({
    this.birthday,
    this.name,
    this.email,
    this.phoneNumber,
    this.gender,
    this.id,
    this.subject,
    this.fontScale,
    this.verified,
    this.conditions,
    this.languages,
    this.location,
    this.image,
    this.elder,
    this.volunteer,
    this.createdAt,
    this.historyData,
  });

  UserModel.fromJson(data) {
    birthday = data['birthday'];
    name = data['name'];
    createdAt = data['createdAt'];
    email = data['email'];
    phoneNumber = data['phoneNumber'];
    gender = data['gender'];
    id = data['id'];
    subject = data['subject'];
    fontScale = data['fontScale'];
    verified = data['verified'];
    languages = data['languages'] != null
        ? data['languages'].map((e) => LanguageModel.fromJson(e)).toList()
        : [];
    conditions = data['conditions'] != null
        ? data['conditions']
            .map((e) => ServiceAndNeedModel.fromJson(e))
            .toList()
        : [];
    location = data['location'];
    elder = data['elder'];
    volunteer = data['volunteer'];
  }
}
