import 'package:chat/main.dart';
import 'package:chat/models/MessageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/models/ChatRoomModel.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoomModel;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatRoomModel,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  bool isSameDate(DateTime? date1, DateTime? date2) {
    return date1?.year == date2?.year &&
        date1?.month == date2?.month &&
        date1?.day == date2?.day;
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Unknown Date';
    }
    final formatter = DateFormat('MM/dd/yyyy');
    return formatter.format(date);
  }



  void sendMessage() async {
    String message = messageController.text.trim();
    messageController.clear();

    if (message != "") {
      MessageModel newText = MessageModel(
          uuid.v1(), widget.userModel.uid, message, false, DateTime.now());

      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoomModel.chatRoomId)
          .collection("messages")
          .doc(newText.messageId)
          .set(newText.toMap());

      widget.chatRoomModel.lastMessage = message;
      widget.chatRoomModel.lastTextTime =  newText.created;

      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoomModel.chatRoomId)
          .set(widget.chatRoomModel.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.targetUser.profilePic!),
            ),
            SizedBox(width: 10),
            Text(widget.targetUser.fullName.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatRooms")
                    .doc(widget.chatRoomModel.chatRoomId)
                    .collection("messages")
                     .orderBy("created", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot snap = snapshot.data as QuerySnapshot;
                      List<MessageModel> messages = snap.docs.map((doc) =>
                          MessageModel.fromMap(doc.data() as Map<String, dynamic>))
                          .toList();

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMsg = messages[index];
                          MessageModel? previousMsg =
                          index > 0 ? messages[index - 1] : null;

                          bool isCurrentUser = currentMsg.sender == widget.userModel.uid;

                          return Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (previousMsg == null ||
                                  !isSameDate(currentMsg.created, previousMsg.created))
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      formatDate(currentMsg.created),
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    ),
                                  ),
                                ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: isCurrentUser ? 8 : 16,
                                ),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCurrentUser ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  currentMsg.text.toString(),
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("An error Occurred"),
                      );
                    } else if (snapshot.data == null) {
                      return Center(
                        child: Text("Say hi to your new friend!"),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );


  }
}
