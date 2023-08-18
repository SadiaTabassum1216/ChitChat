import 'package:firebase_messaging/firebase_messaging.dart';

class Notification{
 static FirebaseMessaging messaging = FirebaseMessaging.instance;

 String? fcmToken;

 void setupFirebaseMessaging() async {
  fcmToken = await messaging.getToken();
 }

 static Future<void> getFirebaseToken() async{
  await messaging.requestPermission();
  NotificationSettings settings = await messaging.requestPermission(
   alert: true,
   announcement: false,
   badge: true,
   carPlay: false,
   criticalAlert: false,
   provisional: false,
   sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
 }

}
