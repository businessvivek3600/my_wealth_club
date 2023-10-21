import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mj_image_slider/mj_image_slider.dart';
import 'package:mj_image_slider/mj_options.dart';
import 'package:mycarclub/database/model/response/dashboard_alert_model.dart';
import 'package:mycarclub/utils/color.dart';
import 'package:mycarclub/utils/sizedbox_utils.dart';
import '../../sl_container.dart';
import '../../utils/app_web_view_page.dart';
import '../../utils/default_logger.dart';
import '../tawk_chat_page.dart';
import '/screens/drawerPages/pofile/profile_screen.dart';
import '/providers/dashboard_provider.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class MainPageAlertsSlider extends StatefulWidget {
  const MainPageAlertsSlider({Key? key}) : super(key: key);

  @override
  State<MainPageAlertsSlider> createState() => _MainPageAlertsSliderState();
}

class _MainPageAlertsSliderState extends State<MainPageAlertsSlider> {
  static const String tag = 'MainPageAlertsSlider';
  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, provider, child) {
        return MJImageSlider(
          options: MjOptions(
              onPageChanged: (i) {},
              scrollDirection: Axis.vertical,
              height: 70,
              viewportFraction: 1),
          widgets: [
            ...provider.alerts
                .where((element) => element.status == 1)
                .toList()
                .map(
                  (alert) => Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: capText(alert.info ?? '', context)),
                        ElevatedButton(
                            onPressed: () => _handleAlertAction(alert, context),
                            child: capText(
                                (alert.action ?? '').capitalize!, context)),
                      ],
                    ),
                  ),
                )
                .toList()
          ],
        );
      },
    );
  }

  _handleAlertAction(DashboardAlert alert, BuildContext context) {
    if (alert.type == 'email_verify') {
      Get.to(const ProfileScreen());
    }
    if (alert.type == 'yoti_sign') {
      if (alert.url == null) {
//scaffold messanger with message and a text contact us with rich tex and ontap
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     // shape: RoundedRectangleBorder(
        //     //     borderRadius: BorderRadius.circular(10),
        //     //     side: const BorderSide(color: Colors.red)),
        //     // showCloseIcon: true,
        //     content: RichText(
        //         text: TextSpan(text: 'Document Verification Failed', children: [
        //       TextSpan(
        //           text: 'Contact Us',
        //           style: const TextStyle(
        //               color: Colors.blueAccent,
        //               fontFamily: 'Montserrat',
        //               fontWeight: FontWeight.bold),
        //           recognizer: TapGestureRecognizer()
        //             ..onTap = () => Get.to(TawkChatPage()))
        //     ])),
        //   ));
        //   return;
        // }
        Widget toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: bColor(1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.white),
              width10(),
              RichText(
                  text: TextSpan(
                      text: 'Document Verification Failed!\n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      children: [
                    TextSpan(
                        text: 'Contact Us',
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.to(TawkChatPage()))
                  ]))
            ],
          ),
        );
        var fToast = FToast()..init(context);
        fToast.showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 2),
        );
        return;
      }
      sl<DashBoardProvider>().getCustomerDashboard();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Success',
        desc: 'Document Verified Successfully',
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        autoHide: const Duration(seconds: 2),
        onDismissCallback: (type) {
          Get.back();
        },
      ).show();

      // Get.to(WebViewExample(
      //   url: alert.url!,
      //   showAppBar: '1',
      //   showToast: '0',
      //   allowCopy: false,
      //   conditions: const ['https://mywealthclub.com/verify_document_responce'],
      //   onResponse: (res) async {
      //     successLog('request url matched <res> $res', tag);
      //     Get.back();
      //     var queryParameters = Uri.parse(res).queryParameters;
      //     warningLog(
      //         'queryParameters is $queryParameters  ${queryParameters['success'].runtimeType}',
      //         tag);
      //     bool success = queryParameters['success'] == '1';
      //     if (success) {
      //       await sl<DashBoardProvider>()
      //           .getCustomerDashboard()
      //           .then((value) => AwesomeDialog(
      //                 context: context,
      //                 dialogType: DialogType.success,
      //                 animType: AnimType.bottomSlide,
      //                 title: 'Success',
      //                 desc: 'Document Verified Successfully',
      //                 dismissOnTouchOutside: false,
      //                 dismissOnBackKeyPress: false,
      //                 autoHide: const Duration(seconds: 2),
      //                 onDismissCallback: (type) {
      //                   Get.back();
      //                 },
      //               ).show());
      //     }
      //   },
      // ));
    }
  }
}
