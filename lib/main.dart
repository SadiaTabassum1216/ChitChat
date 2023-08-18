import 'package:chat/models/UserModel.dart';
import 'package:chat/models/fireBaseHelper.dart';
import 'package:chat/pages/CompleteProfile.dart';
import 'package:chat/pages/HomePage.dart';
import 'package:chat/pages/Login.dart';
import 'package:chat/pages/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? current = FirebaseAuth.instance.currentUser;

  if (current != null) {
    //Logged in
    UserModel? userModel = await FireBaseHelper.getUserById(current.uid);
    // print(current);
    if (userModel != null) {
      runApp(MyAppLoggedIn(
        userModel: userModel,
        fireBaseUser: current,
      ));
    } else {
      runApp(const MyApp());
    }
  } else {
    //Not Logged In
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: LoginPage());
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User fireBaseUser;
  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.fireBaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: HomePage(
          userModel: userModel,
          firebaseUser: fireBaseUser,
        ));
  }
}
