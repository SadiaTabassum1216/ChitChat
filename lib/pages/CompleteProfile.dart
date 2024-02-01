import 'dart:io';

import 'package:chat/models/UIHelper.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo),
                  title: Text("Select from gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take a photo"),
                )
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullName = nameController.text.trim();

    if (fullName == "" || imageFile == "") {
      UIHelper.showAlertDialog(context, "Error", "Please fill all the fields.");
    } else {
      uploadData();
    }
  }


  void uploadData() async {
    UIHelper.showLoading(context, "Finishing Up...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("dp")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    String fullName = nameController.text.trim();
    String dob = dobController.text.trim();

    widget.userModel.fullName = fullName;
    // widget.userModel.dob = dob;
    widget.userModel.profilePic = url;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print("Data updated.");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(userModel:  widget.userModel, firebaseUser:  widget.firebaseUser,);
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Complete Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOption();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name"),
              ),
              SizedBox(
                height: 20,
              ),
              DateTimeField(
                format: DateFormat('yyyy-MM-dd'),
                controller: dobController,
                decoration: InputDecoration(labelText: "Date of Birth"),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime.now(),
                  );
                },
              ),
              SizedBox(
                height: 40,
              ),
              CupertinoButton(
                child: Text("Submit"),
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
