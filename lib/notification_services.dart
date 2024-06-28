import 'dart:convert';
//import 'dart:js';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:shivpeeth_erp_system/shivpeeth/shivpeeth_pages/shivpeeth_home/shivpeeth_homework.dart';
import 'package:shivpeeth_erp_system/shivpeeth/shivpeeth_pages/shivpeeth_home/shivpeethnotic.dart';
import 'package:shivpeeth_erp_system/shivpeeth/shivpeeth_pages/shivpeeth_student/shivpeeth_parentview_attendance.dart';

class NotificationServices {
  //final BuildContext context;
  BuildContext? context;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Constructor to initialize notificationServices
  // NotificationServices(this.context)
  //     : flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  void requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
  }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> configure() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Handle messages in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground Message Received: ${message.notification?.body}');
        try {
          Map<String, dynamic> data = message.data;
          print("configure");

          showNotification(data);
          // handleMessage(context, message);
        } catch (e) {
          print('Exception: $e');
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("onMessageOpenedApp: $message");
        Map<String, dynamic> data = message.data;
        //showNotification(data);
        handleNotificationResponse(data);
      });

      // Handle messages when the app is in the background
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    }
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background Message Received: ${message.notification?.body}');

    try {
      Map<String, dynamic> data = message.data;
      print("Backgroundhandle");

      showNotification(data);
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        Map<String, dynamic> data = message.data;
        print("background");
        showNotification(data);
        // handleMessage(context, message);
      } catch (e) {
        print('Exception: $e');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      Map<String, dynamic> data = message.data;
      // Handle when app is in background and user clicks on notification
      handleNotificationResponse(data);
    });
  }

  //handle tap on notification when app is in background or terminated

  Future<void> setupInteractMessage(BuildContext context) async {
    print("helloworld");
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("@@@####hii");
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    Map<String, dynamic> data = message.data;
    var storedata;
    if (data.length > 0) {
      for (dynamic type in data.keys) {
        storedata = (data[type]);
      }
    }
    final body = json.decode(storedata.toString());
    print("###########$body");
    print(body['activity']);
    print(body['id']);
    final String id = body['id'];
    print("###########!!!!!!!!!!!!!!$body");
    if (id == 'notice') {
      if (context != "") {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return WireframeEvents();
          },
        ));
      }
    } else if (id == 'homework') {
      final String activity = body['activity'];

      List<String> separateValues = activity.split(',');
      String value1 = separateValues[0];
      String value2 = separateValues[1];

      if (context != "") {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return Wireframehomework(classid: value1, sectionid: value2);
          },
        ));
      }
    } else if (id == "attendence") {
      final String activity = body['activity'];

      List<String> separateValues = activity.split(',');
      String value1 = separateValues[0];
      String value2 = separateValues[1];

      if (context != "") {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return Wireframe_student_att(classid: value1, sectionid: value2);
          },
        ));
      }
    }
  }

  void initLocalNotifications(RemoteMessage message, BuildContext context) async {
    var androidInitializationSettings =
        AndroidInitializationSettings('@drawable/androidlogo');
    var iosInitializationSettings = DarwinInitializationSettings();

    var initializationSetting =
        InitializationSettings(android: androidInitializationSettings

            //iOS: iosInitializationSettings
            );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload) {
        // handle interaction when app is active for android
        handleMessage(context, message);
      },
      // onDidReceiveBackgroundNotificationResponse: (NotificationResponse? response){
      // handleMessage(context, message);  }
    );
  }

  void handleNotificationResponse(Map<String, dynamic> data) {
    var storedata;
    if (data.length > 0) {
      for (dynamic type in data.keys) {
        storedata = (data[type]);
      }
    }
    final body = json.decode(storedata.toString());

    final String id = body['id'];

    if (id == 'notice') {
      // Navigator.push(context, MaterialPageRoute(
      //   builder: (context) {
      //     return  WireframeEvents();
      //   },
      // ));
    }
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        Map<String, dynamic> data = message.data;
        // initLocalNotifications(message);
        print("initlocal");
        showNotification(data);
      } catch (e) {
        print('Exception: $e');
      }
    });
  }

  void firebaseInitnew(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //              try {
      //   Map<String, dynamic> data = message.data;

      //                   print("initlocalnew");
      //       initLocalNotifications(message,context);

      //      showNotification(data);
      // } catch (e) {
      //   print('Exception: $e');
      // }
      initLocalNotifications(message, context);

      showNotificationnew(message);
    });
  }

  showNotificationnew(RemoteMessage message) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/androidlogo');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse? response) { // Adjusted parameter type

//        handleNotificationResponse(data); // Pass the context here

//   },
// //   onDidReceiveBackgroundNotificationResponse: (NotificationResponse? response){
// // handleNotificationResponse(data); // Pass the context here
// //   }
//     );

    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high channel',
      'Very important notification!!',
      description: 'the first notification',
      importance: Importance.max,
    );
    Map<String, dynamic> data = message.data;
    var storedata;
    if (data.length > 0) {
      for (dynamic type in data.keys) {
        storedata = (data[type]);
      }
    }
    final body = json.decode(storedata.toString());
    final String messagenew = body['message'];
    final String title = body['title'];
    final String id = body['id'];

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      messagenew,
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description),
      ),
    );
  }

  showNotification(Map<String, dynamic> data) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/androidlogo');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? response) {
        // Adjusted parameter type

        handleNotificationResponse(data); // Pass the context here
      },
//   onDidReceiveBackgroundNotificationResponse: (NotificationResponse? response){
// handleNotificationResponse(data); // Pass the context here
//   }
    );

    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high channel',
      'Very important notification!!',
      description: 'the first notification',
      importance: Importance.max,
    );
    var storedata;
    if (data.length > 0) {
      for (dynamic type in data.keys) {
        storedata = (data[type]);
      }
    }
    final body = json.decode(storedata.toString());
    final String message = body['message'];
    final String title = body['title'];
    final String id = body['id'];

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description),
      ),
    );
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
