import 'dart:async';
import 'dart:io';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import '/database/model/response/base/user_model.dart';
import '/database/model/response/company_info_model.dart';
import '/database/repositories/auth_repo.dart';
import '/myapp.dart';
import '/providers/Cash_wallet_provider.dart';
import '/providers/GalleryProvider.dart';
import '/providers/auth_provider.dart';
import '/providers/commission_wallet_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/event_tickets_provider.dart';
import '/providers/notification_provider.dart';
import '/providers/subscription_provider.dart';
import '/providers/team_view_provider.dart';
import '/providers/voucher_provider.dart';
import '/screens/auth/login_screen.dart';
import '/sl_container.dart';
import '/utils/check_app_update.dart';
import '/utils/toasts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:power_file_view/power_file_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:html/parser.dart';

import '../constants/app_constants.dart';
import '../providers/support_provider.dart';
import '../utils/default_logger.dart';

bool isOnline = false;
String appVersion = '';

String pPTDownloadFilePath = '';

void launchPlayStore() async {
  final playStoreUrl =
      "https://play.google.com/store/apps/details?id=${AppConstants.appID}";

  if (await canLaunch(playStoreUrl)) {
    await launch(playStoreUrl);
  } else {
    throw 'Could not launch Play Store';
  }
}

void launchAppStore() async {
  final appStoreUrl =
      "https://itunes.apple.com/app/your-app-name/id${AppConstants.appAppleStoreId}?mt=8";

  if (await canLaunch(appStoreUrl)) {
    await launch(appStoreUrl);
  } else {
    throw 'Could not launch App Store';
  }
}

//update
updateApp() async {
  infoLog('performing immediateUpdateAllowed ');
  // Get.to(UpdatePage());
  InAppUpdate.performImmediateUpdate()
      .then((value) => errorLog(value.toString()))
      .catchError((e) {
    Fluttertoast.showToast(msg: e.toString());
    return AppUpdateResult.inAppUpdateFailed;
  }).then((value) => warningLog('done'));
}

Future<void> sendWhatsapp({String? number, String? text}) async {
  var whatsappUrl =
      "https://api.whatsapp.com/send?${text != null ? '&text=$text' : ''}";
  await canLaunchUrl(Uri.parse(whatsappUrl))
      ? launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication)
      : print(
          "open WhatsApp app link or do a snack-bar with notification that there is no WhatsApp installed");
}

Future<void> sendTelegram({String? text}) async {
  var telegramUrl = "https://telegram.me/share/url?url=<$text>";
  await canLaunchUrl(Uri.parse(telegramUrl))
      ? launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication)
      : print(
          "open WhatsApp app link or do a snack-bar with notification that there is no Telegram installed");
}

Future<void> launchTheLink(String text) async {
  await canLaunchUrl(Uri.parse(text))
      ? launchUrl(Uri.parse(text), mode: LaunchMode.externalApplication)
      : () {
          Toasts.showErrorNormalToast('Some thing went wrong!');
        };
}

Future<String?> downloadAndSaveFile(String url, String filename) async {
  final ext = url.split('.').last;
  final _directory = await getTemporaryDirectory();
  final downloadFilePath = "${_directory.path}/fileview/$filename.$ext";
  try {
    var response = await Dio().download(url, downloadFilePath,
        onReceiveProgress: (received, total) {
      if (total != -1) {
        print((received / total * 100).toStringAsFixed(0) + "%");
      }
    });
    print("File is saved to $downloadFilePath");
  } on DioError catch (e) {
    print('File download failed ${e.message}');
  }
  return downloadFilePath;
}

Future<void> getPPTDownloadFilePath(String filename) async {
  final _directory = await getTemporaryDirectory();
  pPTDownloadFilePath = "${_directory.path}/fileview/$filename.pdf";
}

Future<void> configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

Future<String?> getDeviceToken({String? username}) async {
  String? _deviceToken;
  _deviceToken = await FirebaseMessaging.instance.getToken();
  // await FirebaseFirestore.instance
  //     .collection('mycarclub')
  //     .doc('tokens')
  //     .collection('allusers')
  //     .doc((username ?? 'unknown ${DateTime.now()}').trim().toLowerCase())
  //     .set({'username': username, 'fcm_token': _deviceToken});
  // if (Platform.isIOS) {
  //   _deviceToken = await FirebaseMessaging.instance.getAPNSToken();
  // } else {
  // }
  warningLog('--------Device Token---------- $_deviceToken');

  return _deviceToken;
}

Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

exitTheApp() async {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else if (Platform.isIOS) {
    exit(0);
  } else {
    print('App exit failed!');
  }
}

String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String parsedString =
      parse(document.body?.text).documentElement?.text ?? '';

  return parsedString;
}

Future<void> logOut() async {
  await sl.get<AuthProvider>().clearSharedData();
  await sl.get<AuthProvider>().clear();
  sl.get<AuthProvider>().userData = UserData();
  await sl.get<CashWalletProvider>().clear();
  await sl.get<VoucherProvider>().clear();
  await sl.get<EventTicketsProvider>().clear();
  await sl.get<CommissionWalletProvider>().clear();
  await sl.get<DashBoardProvider>().clear();
  await sl.get<NotificationProvider>();
  await sl.get<SubscriptionProvider>().clear();
  await sl.get<SupportProvider>().clear();
  await sl.get<TeamViewProvider>().clear();
  await sl.get<GalleryProvider>().clear();
  await APICacheManager().emptyCache();
  MyCarClub.navigatorKey.currentState
      ?.pushNamedAndRemoveUntil(LoginScreen.routeName, (r) => false);
}

Stream<bool> checkFBForAppUpdate() async* {
  var hasUpdate = sl.get<AuthRepo>().getAppCanUpdate();
  var canRunApp = sl.get<AuthRepo>().getCanRunApp();
  var dp = sl.get<DashBoardProvider>();
  await checkVersion().then((value) async {
    /*  var versionKey = (Platform.isIOS
        ? AppConstants.testMode
            ? AppConstants.testIosVersionKey
            : AppConstants.iosVersionKey
        : AppConstants.testMode
            ? AppConstants.testAndroidVersionKey
            : AppConstants.androidVersionKey);*/
    // if (isOnline) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    //can run
/*      var runKey =
          AppConstants.testMode ? AppConstants.testCanRun : AppConstants.canRun;
      await firestore
          .collection('mycarclub')
          .doc('runApp')
          .snapshots()
          .listen((event) {
        if (event.data() != null) {
          if ((event.data())!.entries.isNotEmpty) {
            canRunApp = (event.data())!
                .entries
                .firstWhere((element) => element.key == runKey)
                .value;
          }
        }
      });*/

/*    await firestore
        .collection('mycarclub')
        .doc('version')
        .snapshots()
        .listen((event) {
      if (event.data() != null) {
        if ((event.data())!.entries.isNotEmpty) {
          var versionValue = (event.data())!
              .entries
              .firstWhere((element) => element.key == versionKey)
              .value;
          print(
              'compare in old app-version is $appVersion  and new-version is $versionValue  ,  version key is $versionKey    result is ${(versionValue.toString().compareTo(appVersion))}');
          hasUpdate = versionValue.toString().compareTo(appVersion) == 1;
        }
      }
    });*/
    // }
  });

  /// set value on api data basis
  //has update
  if (dp.companyInfo != null) {
    String versionValue = (Platform.isIOS
        ? AppConstants.testMode
            ? dp.companyInfo!.test_ios ?? ''
            : dp.companyInfo!.ios_version ?? ''
        : AppConstants.testMode
            ? dp.companyInfo!.test_android ?? ''
            : dp.companyInfo!.android_version ?? '');
    if (versionValue != '') {
      hasUpdate = versionValue.toString().compareTo(appVersion) == 1;
    }
    print(
        'compare in old app-version is $appVersion  and new-version is $versionValue, result is ${(versionValue.toString().compareTo(appVersion))}');
  }
  //can run
  if (sl.get<DashBoardProvider>().companyInfo != null) {
    canRunApp =
        (sl.get<DashBoardProvider>().companyInfo!.mobileAppDisabled ?? 0)
                .toString() ==
            '0';
  }
  sl.get<AuthRepo>().setCanRunApp(canRunApp);
  sl.get<AuthRepo>().setAppCanUpdate(hasUpdate);
  print('app checkFBForAppUpdate has new update === $hasUpdate');
  print('app checkFBForAppUpdate can run === $canRunApp');
  yield hasUpdate;
}

final _checker = AppVersionChecker();
Future<bool> checkVersion() async {
  bool canUpdate = false;
  try {
    // if (isOnline) {
    /*
        checkAppUpdate(
          context,
          appName: 'My Car Club',
          iosAppId: '123456789',
          androidAppBundleId: AppConstants.appPlayStoreId,
          isDismissible: true,
          customDialog: true,
          customAndroidDialog: AlertDialog(
            title: const Text('Update Available'),
            content: const Text('Please update the app to continue'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  OpenStore.instance.open(
                    androidAppBundleId: AppConstants.appPlayStoreId,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
          customIOSDialog: CupertinoAlertDialog(
            title: const Text('Update Available'),
            content: const Text('Please update the app to continue'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  OpenStore.instance.open(
                    appName: 'My Car Club',
                    appStoreId: '123456789',
                  );
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
*/
    await _checker.checkUpdate().then((value) {
      appVersion = value.currentVersion;
      print(value.currentVersion); //return current app version
      print(value.newVersion); //return the new app version
      print(value.appURL); //return the app url
      print(value.errorMessage);
      print('***************** checkUpdate  completed *******************');
    });
    // }else{
    //   appVersion = value.currentVersion;
    // }
  } catch (e) {
    print('***************** checkUpdate failed $e *******************');
  }
  return canUpdate;
}

String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();

  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    // If the date matches today, return the time in "jm" format
    return formatDate(dateTime, "jm");
  } else if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day - 1) {
    // If the date matches yesterday, return "Yesterday"
    return "Yesterday";
  } else {
    // For other dates, return the date in "dd/MM/yyyy" format
    return formatDate(dateTime, "dd/MM/yyyy");
  }
}

String formatDate(DateTime dateTime, String format) {
  // Use intl package for date formatting
  final formatter = DateFormat(format);
  return formatter.format(dateTime);
}

Future<bool> setupAppRating(int hours) async {
  bool showRating = false;
  var dt = DateTime.now();
  var prefs = await SharedPreferences.getInstance();
  String? scheduledDate = prefs.getString(SPConstants.ratingScheduleDate);
  if (scheduledDate == null) {
    showRating = false;
    await prefs.setString(SPConstants.ratingScheduleDate,
        dt.add(Duration(hours: hours)).toIso8601String());
    print(
        'user was not scheduled to rate  ${scheduledDate} show rating $showRating');
  } else if (DateTime.parse(scheduledDate).isBefore(dt)) {
    showRating = true;
    await prefs.setString(SPConstants.ratingScheduleDate,
        dt.add(Duration(hours: hours)).toIso8601String());
    print(
        'user is now mature to rate the app ${scheduledDate} show rating $showRating');
  } else {
    showRating = false;
    print(
        'user is not mature to rate the app ${scheduledDate} show rating $showRating');
  }
  return showRating;
}

void checkServiceEnableORDisable(String serviceKey, VoidCallback callback) {
  CompanyInfoModel? company = sl.get<AuthProvider>().companyInfo;
  bool perForm = false;
  String? alert;
  String? key;
  if (company != null) {
    switch (serviceKey) {
      case 'mobile_is_subscription':
        perForm = company.mobileIsSubscription != null &&
            company.mobileIsSubscription == "1";
        alert = "Subscription is temporary disabled.";

        key = serviceKey;
        break;
      case 'mobile_is_cash_wallet':
        perForm = company.mobileIsCashWallet != null &&
            company.mobileIsCashWallet == "1";
        alert = "Cash wallet is temporary disabled.";
        key = serviceKey;
        break;
      case 'mobile_is_commission_wallet':
        perForm = company.mobileIsCommissionWallet != null &&
            company.mobileIsCommissionWallet == "1";
        alert = "Commission wallet is temporary disabled.";
        key = serviceKey;
        break;
      case 'mobile_is_voucher':
        perForm =
            company.mobileIsVoucher != null && company.mobileIsVoucher == "1";
        alert = "Vouchers are temporary disabled.";
        key = serviceKey;
        break;
      case 'mobile_is_event':
        perForm = company.mobileIsEvent != null && company.mobileIsEvent == "1";
        alert = "Events are temporary disabled.";
        key = serviceKey;
        break;
      case 'mobile_chat_disabled':
        perForm = company.mobileChatDisabled != null &&
            company.mobileChatDisabled != "0";
        alert = "New Chat is temporary disabled.";
        key = serviceKey;
        break;
      default:
        perForm = true;
        key = serviceKey;
        break;
    }
  }
  print('checkServiceEnableORDisable $key ${company?.mobileIsSubscription}');
  if (!perForm) {
    Fluttertoast.showToast(msg: alert ?? '');
    return;
  }
  callback();
}

String createDeepLink({String? sponsor, String? placement}) {
  Uri url = Uri.parse(
      'https://tycbm.app.link/signup/?${sponsor != null ? 'sponsor=$sponsor' : ''}${placement != null ? '&' : ''}${placement != null ? 'placement=$placement' : ''}');
  var msg =
      'Hi 👋 ,\nStarting your My Car Club membership can be a fun and exciting endeavour.\nMyCarClub.com is a tight-knit community of car enthusiasts who come together to share their love for anything on wheels.\nYou get to meet gearheads, wizards, experts, professionals, and fans of the automotive industry.\n\n Click the below link to join \n${(url.toString())}';
  return msg;
}

// bool isPageInStack(String pageName) {
//   final List<Route> routes = Navigator.of(Get.context!).widget.pages.first.name;
//   for (final Route route in routes) {
//     if (route.settings.name == pageName) {
//       return true;
//     }
//   }
//   return false;
// }

List<T> getFirstFourElements<T>(List<T> list) {
  if (list.length >= 4) {
    return list.sublist(0, 4);
  } else {
    return list;
  }
}

Future<dynamic> future(int ms,
    [FutureOr<dynamic> Function()? computation]) async {
  return await Future.delayed(Duration(milliseconds: ms));
}

class NoDoubleDecimalFormatter extends TextInputFormatter {
  NoDoubleDecimalFormatter({this.allowOneDecimal = 0});
  final int allowOneDecimal;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Check if the new value contains more than one decimal point
    final decimalCount = newValue.text.split('.').length - 1;
    if (decimalCount > allowOneDecimal) {
      // Return the old value to prevent the double decimal input
      return oldValue;
    }

    return newValue;
  }
}
