import 'package:chat/main.dart';
import 'package:chat/models/MessageModel.dart';
import 'package:chat/services/encryptions.dart';
import 'package:chat/services/notificatonManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/models/ChatRoomModel.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  void sendMessage() async {
    String message = (messageController.text.trim());
    // String message = encryption.encryptAES(messageController.text.trim());
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
      widget.chatRoomModel.lastTextTime = newText.created;

      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoomModel.chatRoomId)
          .set(widget.chatRoomModel.toMap());
    }
  }

  void updateMessages(messages) async {
    for (var message in messages) {
      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoomModel.chatRoomId)
          .collection("messages")
          .doc(message.messageId)
          .set(message.toMap());
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
                      List<MessageModel> messages = snap.docs
                          .map((doc) => MessageModel.fromMap(
                              doc.data() as Map<String, dynamic>))
                          .toList();

                      for (var message in messages) {
                        if (message.seen == false && message.sender != widget.userModel.uid) {
                          message.seen = true;
                        }
                      }

                      updateMessages(messages);

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMsg = messages[index];
                          // var decryptedText =
                          // encryption.decryptAES(encrypt.Encrypted.fromBase64(currentMsg.text!));
                          var decryptedText = currentMsg.text;

                          bool isCurrentUser =
                              currentMsg.sender == widget.userModel.uid;

                          return Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: isCurrentUser ? 8 : 16,
                                ),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.blue
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  currentMsg.text!,
                                  // decryptedText,
                                  style: TextStyle(
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
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
                        child: Text(
                          "Say hi to your new friend!",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
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
