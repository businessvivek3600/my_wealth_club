import 'dart:async';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/database/model/body/login_model.dart';
import '/myapp.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/screens/auth/forgot_password.dart';
import '/screens/auth/sign_up_screen.dart';
import '/sl_container.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import '/utils/toasts.dart';
import 'package:provider/provider.dart';

import '../../utils/color.dart';
import '../../utils/picture_utils.dart';
import '../dashboard/main_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String routeName = '/LoginScreen';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController = TextEditingController(text: '');
  // TextEditingController(text: 'vivekmalik2466m');
  // TextEditingController(text: 'BIZZ3800074');
  TextEditingController _passwordController = TextEditingController(text: '');
  // TextEditingController(text: 'India@151');
  bool isFinished = false;
  bool showPassword = false;
  @override
  void initState() {
    sl.get<AuthProvider>().getSignUpInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Center(
        child: Scaffold(
          body: Container(
            height: height,
            width: double.maxFinite,
            color: mainColor,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 350,
                            // constraints: BoxConstraints(maxWidth: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                height100(height * 0.1),
                                buildHeader(height, context),
                                height100(height * 0.05),
                                buildForm(height),
                                height10(),
                                Column(
                                  children: [
                                    Stack(
                                      children: [
                                        buildLoginButton2(context),
                                        if (sl
                                                    .get<AuthProvider>()
                                                    .companyInfo !=
                                                null &&
                                            sl
                                                    .get<AuthProvider>()
                                                    .companyInfo!
                                                    .mobileIsLogin ==
                                                '0')
                                          Container(
                                              color: Colors.transparent,
                                              width: double.maxFinite,
                                              height: 50)
                                      ],
                                    ),
                                    height10(),
                                    if (sl.get<AuthProvider>().companyInfo !=
                                            null &&
                                        sl
                                                .get<AuthProvider>()
                                                .companyInfo!
                                                .mobileIsLogin ==
                                            '0')
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.info_outline,
                                              color: Colors.amber, size: 15),
                                          width5(7),
                                          capText(
                                              'Login process is temporary disabled.',
                                              context,
                                              color: Colors.grey[400])
                                        ],
                                      )
                                  ],
                                ),
                                height10(),
                                height10(),
                                height10(),
                                height10(),
                                buildSignUpButton(),
                                // height20(height * 0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  ActionSlider buildLoginButton2(BuildContext context) {
    double iconSize = 40;
    return ActionSlider.standard(
      sliderBehavior: SliderBehavior.stretch,
      rolling: true,
      height: iconSize + 10,
      child: bodyLargeText('SWIPE TO LOGIN', context, color: Colors.black,useGradient: false),
      backgroundColor: Colors.white,
      toggleColor: appLogoColor.withOpacity(0.8),
      iconAlignment: Alignment.center,
      loadingIcon: SizedBox(
          width: iconSize,
          child: Center(
              child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.0, color: Colors.white)))),
      successIcon: SizedBox(
          width: iconSize,
          child: Center(child: Icon(Icons.check_rounded, color: Colors.white))),
      failureIcon: SizedBox(
          width: iconSize,
          child: Center(
              child: Icon(Icons.warning_amber_rounded, color: Colors.red))),
      icon: SizedBox(
          width: iconSize,
          child: Center(
              child:
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white))),
      action: (controller) async {
        if (_formKey.currentState?.validate() ?? false) {
          controller.loading(); //starts loading animation
          try {
            await sl
                .get<AuthProvider>()
                .login(LoginModel(
                    username: _userNameController.text,
                    password: _passwordController.text,
                    device_id: ''))
                .then((value) {
              if (value) {
                controller.success();
                sl.get<DashBoardProvider>().getCustomerDashboard();
                Future.delayed(
                    Duration(milliseconds: 2000), () => Get.offAll(MainPage()));
              } else {
                controller.failure();
              }
            });
          } catch (e) {
            Toasts.showErrorNormalToast('Something went wrong!');
            controller.failure();
          }
          //starts success animation
          await Future.delayed(const Duration(seconds: 1));
          controller.reset(); //resets the slider
        }
      },
    );
  }


  Row buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(text: "Don't have an account? ", children: [
            TextSpan(
                text: 'Sign Up',
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.to(SignUpScreen()),
                style: TextStyle(
                    color: appLogoColor, fontWeight: FontWeight.bold)),
          ]),
        ),
      ],
    );
  }

  Widget buildForm(double height) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                titleLargeText('Login', context, fontSize: 32),
                height5(height * 0.01),
                capText('Please sign in to continue.', context,
                    fontSize: 15,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold),
                height20(height * 0.05),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _userNameController,
                        enabled: true,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(hintText: 'Username'),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                height10(height * 0.02),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        enabled: true,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                            hintText: 'Password',
                            suffixIcon: GestureDetector(
                                onTap: () {
                                  primaryFocus?.unfocus();
                                  setState(() => showPassword = !showPassword);
                                },
                                child: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off_rounded,
                                  color: Colors.white,
                                ))),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                height20(height * 0.01),
                // buildCaptcha(),
                // height20(height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => MyCarClub.navigatorKey.currentState
                          ?.pushNamed(ForgotPasswordScreen.routeName),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: capText('Forgot Password?', context,
                            color: appLogoColor),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Column buildHeader(double height, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: assetImages(
            Assets.appWebLogoWhite,
            width: double.maxFinite,
            height: height * 0.1,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path()
      ..addOval(Rect.fromPoints(Offset(0, 0), Offset(60, 60)))
      ..addOval(Rect.fromLTWH(0, size.height - 50, 100, 50))
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: 20))
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    throw false;
  }
}
