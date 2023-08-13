class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? created;


  MessageModel(this.messageId,this.sender, this.text, this.seen, this.created);

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageId"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    created = map["created"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageId": messageId,
      "sender": sender,
      "text": text,
      "seen": seen,
      "created": created,
    };
  }
}
