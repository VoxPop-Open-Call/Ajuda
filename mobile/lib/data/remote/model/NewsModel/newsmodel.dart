class NewsModel {
  String? id;
  String? title;
  String? subject;
  String? description;
  String? image;
  String? articleUrl;
  String? time;

  NewsModel({
    this.id,
    this.title,
    this.subject,
    this.description,
    this.image,
    this.articleUrl,
    this.time,
  });

  NewsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    subject = json['subject'];
    image = json['imageUrl'];
    articleUrl = json['articleUrl'];
    time = json['date'];
  }
}
