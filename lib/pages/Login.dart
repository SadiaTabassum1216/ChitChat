import 'package:chat/models/UIHelper.dart';
import 'package:chat/pages/SignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart';
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController c_passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.showAlertDialog(context,"Error", "Please fill all the fields.");
    }  else {
      logIn(email, password);
    }
  }


  void logIn(String email, String password) async {
    UserCredential? credential;

  UIHelper.showLoading(context, "Logging In...");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {

      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "Error", e.message.toString());
      // print(e.code.toString());
    }

    if(credential!=null){
      String uid=credential.user!.uid;

      DocumentSnapshot userData= await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel user= UserModel.fromMap(userData.data() as Map<String, dynamic>);
      // UIHelper.showAlertDialog(context,"Message", "Login Successful.");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(userModel: user, firebaseUser: credential!.user!,);
        }),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Login"),
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
                  height: 30,
                ),
                CupertinoButton(
                  child: Text("Log In"),
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
              Text("Don't have an account?"),
              CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SignUpPage();
                    }),
                  );
                },
                child: Text("Sign Up"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
