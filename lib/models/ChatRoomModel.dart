class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? lastTextTime;
  bool? isNotificationSent;

  ChatRoomModel(this.chatRoomId, this.participants, this.lastMessage , this.lastTextTime, this.isNotificationSent);

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map["chatRoomId"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    lastTextTime = map["lastTextTime"].toDate();
    isNotificationSent= map["isNotificationSent"];
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "participants": participants,
      "lastMessage": lastMessage,
      "lastTextTime": lastTextTime,
      "isNotificationSent": isNotificationSent,
    };
  }
}
