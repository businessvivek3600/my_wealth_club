import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:local_auth/local_auth.dart';
import '/database/app_update/upgrader.dart';
import '/utils/app_lock_authentication.dart';
import '/database/repositories/auth_repo.dart';
import '/database/repositories/settings_repo.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/screens/app_maintaing_page.dart';
import '/screens/auth/login_screen.dart';
import '/screens/auth/sign_up_screen.dart';
import '/screens/dashboard/main_page.dart';
import '/screens/update_app_page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/network_info.dart';
import '/utils/no_internet_widget.dart';
import 'package:video_player/video_player.dart';
import '../../database/functions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, this.controller}) : super(key: key);
  static const String routeName = '/SplashScreen';
  final VideoPlayerController? controller;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String tag = 'Splash Screen';
  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  int duration = 0;
  int position = 0;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    sl.get<NetworkInfo>().checkConnectivity(context);
    sl.get<AuthProvider>().getSignUpInitialData();
    super.initState();
    initController();
  }

  void initController() {
    _controller = VideoPlayerController.asset('assets/videos/1_1.mp4')
      ..initialize().then((_) {
        _controller.play();

        warningLog('SplashScreen video initialized: ${_controller.value}', tag,
            'initState');
        duration = _controller.value.duration.inMilliseconds;
        // _controller.setVolume(0.0);
      });
    _controller.addListener(_listner);
  }

  void _listner() {
    setState(() {});
    if (_controller.value.hasError) {
      errorLog('video error: ${_controller.value.errorDescription}', tag,
          'initState');
    }
    if (_controller.value.isInitialized) {
      infoLog('video initialized: ${_controller.value}', tag, 'initState');
      duration = _controller.value.duration.inMilliseconds;
      _controller.setVolume(0.0);
    }
    if (_controller.value.position.inMilliseconds >= 2960) {
      checkLogin2();
    }
  }

  checkLogin2() async {
    var authProvider = sl.get<AuthProvider>();
    bool isLogin = authProvider.isLoggedIn();
    if (!isLogin) {
      Get.offAll(LoginScreen());
    } else {
      var user = await authProvider.getUser();
      if (user != null) {
        authProvider.userData = user;
        authProvider.authRepo
            .saveUserToken(await authProvider.authRepo.getUserToken());
        bool isBiometric = sl.get<SettingsRepo>().getBiometric();
        if (isBiometric) {
          AppLockAuthentication.authenticate().then((value) {
            infoLog('authenticate: authStatus: $value', tag, 'checkLogin');
            if (value[0] == AuthStatus.available) {
              if (value[1] == AuthStatus.success) {
                Get.offAll(MainPage());
              } else {
                exitTheApp();
              }
            } else {
              Get.offAll(MainPage());
            }
          });
        } else {
          Get.offAll(MainPage());
        }
      } else {
        logOut(tag);
        Get.offAll(LoginScreen());
        listenDynamicLinks();
      }
    }
  }

  checkAppUpdate() async {
    var hasUpdate = sl.get<AuthRepo>().getAppCanUpdate();
    var canRunApp = sl.get<AuthRepo>().getCanRunApp();

    //method:1 check from package info and call store apis

    //method:2 hit api and check from api

    if (hasUpdate) {
      Get.offAll(UpdatePage(required: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Stack buildBody() {
    return Stack(
      children: [
        Container(
          height: double.maxFinite,
          width: double.maxFinite,
          color: mainColor,
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller))
              : Container(),
        ),
        /*if (position == duration)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: double.maxFinite,
              child: Center(
                child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.white, strokeWidth: 2),
              ),
            ),
          ),*/
        /*      Align(
          alignment: Alignment.bottomCenter,
          child: FilledButton(
              onPressed: _updateInfo?.updateAvailability ==
                      UpdateAvailability.updateAvailable
                  ? () {
                      infoLog('performing immediateUpdateAllowed ');
                      InAppUpdate.performImmediateUpdate().catchError((e) {
                        Fluttertoast.showToast(msg: e.toString());
                        return AppUpdateResult.inAppUpdateFailed;
                      });
                    }
                  : () {},
              child: titleLargeText('Update', context)),
        )*/
      ],
    );
  }

//
  Future<void> listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      try {
        print('----------- branch io data is ${data} -------------');
        print('referring link is --> ' + (data['~referring_link'] ?? ''));
        print('referring link is --> ' + (data['+non_branch_link'] ?? ""));
        if (data['~referring_link'] != null ||
            data['+non_branch_link'] != null) {
          Uri uri =
              Uri.parse(data['~referring_link'] ?? data['+non_branch_link']);
          print(uri.queryParameters);
          var queryParams = uri.queryParameters;
          if (queryParams.entries.isNotEmpty) {
            String? sponsor;
            String? placement;
            queryParams.entries.forEach((element) {
              switch (element.key) {
                case 'sponsor':
                  print('found sponsor : ${element.value}');
                  sponsor = element.value;
                  break;
                case 'placement':
                  print('found placement : ${element.value}');
                  placement = element.value;
                  break;
                default:
                  print('queryParams : ${element}');
                  break;
              }
            });
            if (sponsor != null || placement != null) {
              print(
                  '****** going to sign up page-with data sponsor $sponsor   and  placement $placement  *******');
              Get.to(SignUpScreen(sponsor: sponsor, placement: placement));
            }
          }
        }
/*        print('listenDynamicLinks - DeepLink Data: $data');
        controllerData.sink.add((data.toString()));
        if ((data.containsKey('+clicked_branch_link') &&
            data['+clicked_branch_link'] == true)) {
          print(
              '------------------------------------Link clicked----------------------------------------------');
          print('Custom string: ${data['custom_string']}');
          print('Custom number: ${data['custom_number']}');
          print('Custom bool: ${data['custom_bool']}');
          print('Custom list number: ${data['custom_list_number']}');
          print(
              '------------------------------------------------------------------------------------------------');
          Get.to(SignUpScreen());

          // data['+non_branch_link']
        }*/
      } catch (e) {
        print(
            '------------------------------------------------------ branch error  $e');
      }
    }, onError: (error) {
      print('Init Session error: ${error.toString()}');
    });
  }

  // AppUpdateInfo? _updateInfo;

  // Future<void> checkLogin() async {
  //   await checkFBForAppUpdate().first.then((value) async {
  //     bool canRunApp = sl.get<AuthRepo>().getCanRunApp();
  //     await checkForUpdate().then((value) async {
  //       bool canUpdate = sl.get<AuthRepo>().getAppCanUpdate();
  //       print('SplashScreen app can run $canRunApp &&& has Update $canUpdate');
  //       if (!canRunApp && isOnline) {
  //         Get.offAll(AppUnderMaintenancePage());
  //       } else if (!canRunApp && !isOnline) {
  //         Get.offAll(NoInternetWidget(
  //           btnText: 'Restart',
  //           callback: () => exitTheApp(),
  //         ));
  //       } else {
  //         if (canUpdate) {
  //           Get.offAll(
  //               // Platform.isIOS ?
  //               // UpdateAppPage() :
  //               UpdatePage(required: true));
  //           // updateApp();
  //         } else {
  //           bool isLogin = sl.get<AuthRepo>().isLoggedIn();
  //           if (isLogin) {
  //             await sl.get<AuthProvider>().userInfo().then((value) async {
  //               if (value != null) {
  //                 await _checkBiometrics().then((value) async {
  //                   print(
  //                       '_checkBiometrics $_canCheckBiometrics  ${await auth.canCheckBiometrics}');
  //                   if (_canCheckBiometrics &&
  //                       sl.get<SettingsRepo>().getBiometric()) {
  //                     await _authenticateWithBiometrics().then((value) {
  //                       if (value) {
  //                         sl.get<DashBoardProvider>().getCustomerDashboard();
  //                         Get.offAll(MainPage());
  //                       } else {
  //                         exitTheApp();
  //                       }
  //                     });
  //                   } else {
  //                     Get.offAll(MainPage());
  //                   }
  //                 });
  //               } else {
  //                 Get.offAll(LoginScreen());
  //               }
  //             });
  //           } else {
  //             Get.offAll(LoginScreen());
  //             listenDynamicLinks();
  //           }
  //         }
  //       }
  //     });
  //   });
  // }

  // Future<AppUpdateInfo?> checkForUpdate() async {
  //   AppUpdateInfo? updateInfo;
  //   if (Platform.isAndroid) {
  //     InAppUpdate.checkForUpdate().then((info) {
  //       setState(() {
  //         _updateInfo = info;
  //         updateInfo = info;
  //       });
  //       if (_updateInfo != null) {
  //         sl.get<AuthRepo>().setAppCanUpdate(_updateInfo!.updateAvailability ==
  //             UpdateAvailability.updateAvailable);
  //         successLog(_updateInfo!.toString());
  //       }
  //     }).catchError((e) {
  //       errorLog(e.toString());
  //     });
  //   }
  //   return updateInfo;
  // }
}
