import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/database/functions.dart';
import '/screens/splash/splash_screen.dart';
import '/sl_container.dart';
import '/utils/app_icon_badge_utils.dart';
import '/utils/default_logger.dart';
import '/utils/network_info.dart';
import '/utils/notification_sqflite_helper.dart';

import 'database/my_notification_setup.dart';
import 'myapp.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

int time = 0;
var timer = Timer.periodic(Duration(seconds: 1), (timer) {
  time++;
});

Future<void> main() async {
  errorLog('time1 $time', 'timer---');
  timer;
  WidgetsFlutterBinding.ensureInitialized();
  await initRepos();
  await Firebase.initializeApp();
  await configureLocalTimeZone();
  await initRepos().then((value) async {
    await sl.get<NetworkInfo>().isConnected;
    await sl.get<NotificationDatabaseHelper>().db();
  });
  await initPlatformState();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
   MyNotification().initialize(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = SplashScreen.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
  }
  errorLog('time2 $time', 'timer---');
  runApp(MyCarClub(
      initialRoute: initialRoute,
      notificationAppLaunchDetails: notificationAppLaunchDetails));
}
