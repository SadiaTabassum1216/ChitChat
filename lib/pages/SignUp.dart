import 'package:chat/models/UserModel.dart';
import 'package:chat/pages/CompleteProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UIHelper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController c_passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String c_password = c_passwordController.text.trim();

    if (email == "" || password == "" || c_password == "") {
      UIHelper.showAlertDialog(context,"Error", "Please fill all the fields.");
    } else if (password != c_password) {
      UIHelper.showAlertDialog(context,"Error", "Passwords do not match.");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoading(context, "Creating New Account...");

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "Error", e.message.toString());
      print(e.code.toString());
    }

    if(credential!=null){
      String uid=credential.user!.uid;
      UserModel newUser= UserModel(
          uid: uid,
          fullName: "",
          email: email,
          profilePic: "");
      await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value) {
        print("New user added.");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return CompleteProfile(userModel: newUser, firebaseUser: credential!.user!,);
          }),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Sign Up"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'images/chat.png',
                  width: 100,
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Chitchat",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email Address"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: c_passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Confirm Password"),
                ),
                SizedBox(
                  height: 30,
                ),
                CupertinoButton(
                  child: Text("Sign Up"),
                  onPressed: () {
                    checkValues();
                    
                  },
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account?"),
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Log in"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
