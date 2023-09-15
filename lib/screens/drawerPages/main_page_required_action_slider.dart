import 'package:flutter/material.dart';
import 'package:mj_image_slider/mj_image_slider.dart';
import 'package:mj_image_slider/mj_options.dart';
import '/database/functions.dart';
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
              height: 100,
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
                    child: Column(
                      children: [
                        bodyLargeText(alert.text ?? '', context),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            ElevatedButton(
                                onPressed: () =>
                                    launchTheLink(alert.link ?? ''),
                                child: Text('Verify'))
                          ],
                        ),
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
}
