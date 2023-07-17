class ChatMessage {
  String? id;
  String? type;
  int? timestamp;
  String? room;
  String? from;
  String? text;

  ChatMessage(
      {this.id, this.type, this.timestamp, this.room, this.from, this.text});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    timestamp = json['timestamp'];
    room = json['room'];
    from = json['from'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['timestamp'] = this.timestamp;
    data['room'] = this.room;
    data['from'] = this.from;
    data['text'] = this.text;
    return data;
  }
}
