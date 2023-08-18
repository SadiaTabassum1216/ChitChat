import 'package:chat/models/ChatRoomModel.dart';
import 'package:chat/models/fireBaseHelper.dart';
import 'package:chat/pages/ChatRoomPage.dart';
import 'package:chat/pages/Login.dart';
import 'package:chat/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/UserModel.dart';

import '../models/MessageModel.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(CupertinoIcons.home),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                widget.userModel.profilePic.toString()),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SearchPage(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser,
                    );
                  }),
                );
              },
              icon: Icon(Icons.search)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "logout") {
                FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "logout",
                child: Text("Logout"),
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
        ],
        // IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
      ),
      body: Center(
          child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatRooms")
              .where("participants.${widget.userModel.uid}", isEqualTo: true)
              // .orderBy("lastTextTime", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot snap = snapshot.data as QuerySnapshot;

                return ListView.builder(
                  itemCount: snap.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoom = ChatRoomModel.fromMap(
                        snap.docs[index].data() as Map<String, dynamic>);

                    Map<String, dynamic> participants = chatRoom.participants!;

                    List<String> participantKeys = participants.keys.toList();

                    participantKeys.remove(widget.userModel.uid);

                    return FutureBuilder(
                      future: FireBaseHelper.getUserById(participantKeys[0]),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                       // blurRadius: 5,
                                      // offset: Offset(0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                          targetUser: targetUser,
                                          chatRoomModel: chatRoom,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser);
                                    }));
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetUser.profilePic.toString()),
                                  ),
                                  title: Text(
                                    targetUser.fullName.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: (chatRoom.lastMessage.toString() != "")
                                      ? Text(chatRoom.lastMessage.toString())
                                      : Text("Say hi to your new friend!", style: TextStyle(
                                  color:  Colors.blue,
                                ),),

                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("An error occurred."),
                );
              } else {
                return Center(
                  child: Text("No Chats!"),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: FloatingActionButton(
            onPressed: () {}, child: Icon(Icons.add_comment_rounded)),
      ),
    );
  }
}
