import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mj_image_slider/mj_image_slider.dart';
import 'package:mj_image_slider/mj_options.dart';
import 'package:mycarclub/screens/drawerPages/pofile/profile_screen.dart';
import '/providers/dashboard_provider.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class MainPageRequiredActionSlider extends StatefulWidget {
  const MainPageRequiredActionSlider({Key? key}) : super(key: key);

  @override
  State<MainPageRequiredActionSlider> createState() =>
      _MainPageRequiredActionSliderState();
}

class _MainPageRequiredActionSliderState
    extends State<MainPageRequiredActionSlider> {
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
                .map(
                  (alert) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: capText(alert.info ?? '', context)),
                        ElevatedButton(
                            onPressed: () =>
                                _handleAlertAction(alert.action ?? '', context),
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

  _handleAlertAction(String s, BuildContext context) {
    if (s == 'verify email') {
      Get.to(ProfileScreen());
    }
  }
}
