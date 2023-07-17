class EmergencyContactModel {
  String? name, mobileNumber;

  EmergencyContactModel({required this.name, required this.mobileNumber});

  EmergencyContactModel.fromJson(data) {
    name = data['name'];
    mobileNumber = data['number'];
  }
}
