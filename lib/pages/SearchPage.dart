import 'dart:async';

import 'package:chat/models/UserModel.dart';
import 'package:chat/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/ChatRoomModel.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Timer? _debounceTimer;
  List<UserModel> searchResults = [];
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(() {
      _debounceTimer?.cancel();
      _performSearch();
    });
  }

  void _performSearch() {
    final searchText = searchController.text.trim().toLowerCase();

    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      if (searchText.isNotEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("email", isNotEqualTo: widget.userModel.email)
            .get();

        List<UserModel> allUsers = querySnapshot.docs.map((doc) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          return UserModel.fromMap(userData);
        }).toList();

        List<UserModel> filteredUsers = allUsers.where((user) {
          String userEmailAddress = user.email!.toLowerCase();
          return userEmailAddress.contains(searchText);
        }).toList();

        setState(() {
          searchResults = filteredUsers;
        });
      } else {
        setState(() {
          searchResults.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<ChatRoomModel?> getRoom(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      print("Chatroom exists");
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingRoom;
    } else {
      print("Chatroom does not exist");
      ChatRoomModel newRoom = ChatRoomModel(
          uuid.v1(),
          {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          },
          "",
          DateTime.now());

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(newRoom.chatRoomId)
          .set(newRoom.toMap());

      print("New Chatroom");
      chatRoom = newRoom;
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Page'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                textInputAction: TextInputAction.search,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () async {
                        UserModel searchedUser = searchResults[index];
                        ChatRoomModel? chatRoom = await getRoom(searchedUser);
                        if (chatRoom != null) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ChatRoomPage(
                                targetUser: searchedUser,
                                chatRoomModel: chatRoom,
                                userModel: widget.userModel,
                                firebaseUser: widget.firebaseUser,
                              );
                            }),
                          );
                        }
                      },
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(searchResults[index].profilePic!),
                      ),
                      title: Text(searchResults[index].fullName!),
                      subtitle: Text(searchResults[index].email!),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    );
                  },
                ),
              ),
              // SizedBox(height: 20),
              // CupertinoButton(
              //   onPressed: () {
              //     // You may not need this button, as the search updates continuously.
              //   },
              //   color: Theme.of(context).colorScheme.secondary,
              //   child: Text("Search"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
