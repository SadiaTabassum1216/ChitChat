import 'package:flutter/material.dart';

class UIHelper {
  static void showLoading(BuildContext context, String title) {
    AlertDialog loading = AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 30,
            ),
            Text(title)
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return loading;
        });
  }

  static void showAlertDialog(
      BuildContext context, String title, String message) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
