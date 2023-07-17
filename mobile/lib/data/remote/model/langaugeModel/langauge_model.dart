class LanguageModel {
  String? title;
  String? nativeName;
  bool select = false;
  String? id;

  LanguageModel({required this.title, this.nativeName, this.id});

  LanguageModel.fromJson(data) {
    title = data['name'];
    id = data['code'];
    nativeName = data['nativeName'];
  }
}
