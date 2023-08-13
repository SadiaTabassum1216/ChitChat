import 'package:chat/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireBaseHelper{
  static Future<UserModel?> getUserById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docSnap= await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if(docSnap.data()!=null){
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }
}