import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mycarclub/utils/default_logger.dart';
import '/database/functions.dart';
import '/screens/splash/splash_screen.dart';
import '/sl_container.dart';
import '/utils/app_icon_badge_utils.dart';
import '/utils/network_info.dart';
import '/utils/notification_sqflite_helper.dart';

import 'database/app_update/upgrader.dart';
import 'database/my_notification_setup.dart';
import 'myapp.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // timer;
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  await initRepos();
  await Firebase.initializeApp();
  await configureLocalTimeZone();
  TextInput.ensureInitialized();
  await initRepos().then((value) async {
    await sl.get<NetworkInfo>().isConnected;
    await sl.get<NotificationDatabaseHelper>().db();
  });
  await initPlatformState();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  MyNotification().initialize(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  errorLog(
      "notificationAppLaunchDetails : ${notificationAppLaunchDetails?.didNotificationLaunchApp} ${notificationAppLaunchDetails?.notificationResponse} ${notificationAppLaunchDetails?.notificationResponse?.payload}");
  String initialRoute = SplashScreen.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    errorLog("didNotificationLaunchApp : push notification payload : " +
        (notificationAppLaunchDetails?.notificationResponse?.payload ?? ''));
    selectedNotificationPayload =
        notificationAppLaunchDetails?.notificationResponse?.payload;
    selectNotificationStream.add(selectedNotificationPayload);
  }
  runApp(MyCarClub(
      initialRoute: initialRoute,
      notificationAppLaunchDetails: notificationAppLaunchDetails));
}
