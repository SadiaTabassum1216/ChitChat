class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? lastTextTime;

  ChatRoomModel(this.chatRoomId, this.participants, this.lastMessage , this.lastTextTime);

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map["chatRoomId"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    lastTextTime = map["lastTextTime"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "participants": participants,
      "lastMessage": lastMessage,
      "lastTextTime": lastTextTime,
    };
  }
}
