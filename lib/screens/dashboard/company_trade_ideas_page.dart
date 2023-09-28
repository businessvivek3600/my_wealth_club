import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/utils/color.dart';
import '/database/functions.dart';
import '/utils/default_logger.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

class CompanyTradeIdeasPage extends StatefulWidget {
  const CompanyTradeIdeasPage({super.key});

  @override
  State<CompanyTradeIdeasPage> createState() => _CompanyTradeIdeasPageState();
}

class _CompanyTradeIdeasPageState extends State<CompanyTradeIdeasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: titleLargeText('Company Trade Ideas', context,
              color: Colors.white, useGradient: true),
          actions: [assetImages(Assets.appLogo_S, width: 30), width10()],
        ),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 1),
          ),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _TradeTile(index: index);
            },
          ),
        ));
  }
}

class _TradeTile extends StatelessWidget {
  _TradeTile({
    super.key,
    required this.index,
  });
  final int index;
  final controller = FlipCardController();
  flip() {
    controller.flipcard();
  }

  @override
  Widget build(BuildContext context) {
    Color tColor = Colors.black;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Get.to(() => SignalDetail()),
            // onDoubleTap: () => Get.to(() => SignalDetail()),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: FlipCard(
                animationDuration: const Duration(milliseconds: 300),
                axis: FlipAxis.horizontal,
                controller: controller,
                rotateSide: RotateSide.left,
                // enableController: false,
                onTapFlipping: false,
                frontWidget: frontCard(bColor, context, tColor),
                backWidget: backCard(bColor, context, tColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget backCard(Color bColor, BuildContext context, Color tColor) {
    List takeList = ['108.560', '109.566', '110.564', '111.569', '112.562'];
    return Container(
      padding: EdgeInsets.only(left: 8, top: 18, right: 8, bottom: 18),
      width: double.infinity,
      color: bColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bodyLargeText('Take Profits', context,
              color: Color.fromARGB(255, 201, 209, 249),
              useGradient: false,
              fontSize: 20),
          height10(),
          Row(
            children: [
              width20(),
              Expanded(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    ...takeList.map((e) {
                      int i = takeList.indexOf(e);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                                // color: Color.fromARGB(249, 241, 224, 224),
                                border: Border.all(
                                    color: Color.fromARGB(249, 241, 224, 224),
                                    width: 1),
                                borderRadius: BorderRadius.circular(5)),
                            child: bodyLargeText('TP${i + 1}) $e', context,
                                color: Color.fromARGB(249, 241, 224, 224),
                                useGradient: false,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Visibility(
                            visible: i < takeList.length - 1,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: buildArrow(
                                  h: 15,
                                  w: 20,
                                  stroke: 5,
                                  color: Color.fromARGB(255, 55, 252, 62)
                                      .withOpacity(0.2 * (i + 1))),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildArrow(
      {required double h,
      required double w,
      required double stroke,
      Color? color}) {
    return Container(
      height: h,
      // color: redDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipPath(
            clipper: ArrowClipper(w * 0.4, h * 0.8, Edge.RIGHT),
            child: Container(height: h, width: w, color: color ?? Colors.grey),
          ),
        ],
      ),
    );
  }

  Stack frontCard(Color bColor, BuildContext context, Color tColor) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(left: 28, top: 18, right: 18, bottom: 18),
          width: double.infinity,
          decoration: BoxDecoration(color: bColor, boxShadow: [
            // BoxShadow(
            //   color: Colors.white.withOpacity(0.5),
            //   spreadRadius: 10,
            //   blurRadius: 10,
            //   offset: Offset(1, 1), // changes position of shadow
            // ),
          ]),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          titleLargeText('USD/JPY', context,
                              color: tColor, useGradient: true, fontSize: 23),
                          width5(),
                          SpinKitPulse(
                            color: Colors.green,
                            size: 20.0,
                          ),
                        ],
                      ),
                      width5(),
                      titleLargeText('190.000', context, color: appLogoColor),
                    ],
                  ),
                  height10(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          assetImages(Assets.candleStick, width: 15),
                          width5(),
                          capText(
                            formatDate(DateTime.parse('2023-08-05 12:36:67'),
                                    'yyyy-MM-ddTHH:mm:ss.SSS Z') +
                                ' ' +
                                'GMT+1',
                            context,
                            color: Color.fromARGB(255, 169, 175, 179),
                          ),
                        ],
                      ),
                      width10(),
                      Row(
                        children: [
                          Icon(Icons.logout_rounded,
                              color: Color.fromARGB(249, 241, 224, 224),
                              size: 15),
                          width5(),
                          capText(
                            '109.678',
                            context,
                            color: Color.fromARGB(249, 241, 224, 224),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: LayoutBuilder(builder: (context, b) {
            infoLog('b.maxHeight: ${b.maxHeight}');
            Color color1 = Color.fromARGB(255, 19, 176, 4);
            Color color2 = Color.fromARGB(255, 249, 28, 4);
            return Container(
              width: 5,
              decoration: BoxDecoration(
                  color: index % 3 == 0 ? color1 : color2,
                  boxShadow: [
                    BoxShadow(
                      color: index % 3 == 0 ? color1 : color2,
                      spreadRadius: 1,
                      blurRadius: 50,
                      offset: Offset(0, 0.5), // changes position of shadow
                    ),
                  ]),
            );
          }),
        )
      ],
    );
  }
}

class CustomClipPathTopContainerOne extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double cp = 0.03545167;
    double ap = 0.8;

    // Paint paint = Paint()
    //   ..style = PaintingStyle.fill
    //   ..strokeWidth = 1.0
    //   ..color = Colors.black;

    Path path0 = Path();

    // path0.moveTo(0, h);
    // path0.lineTo(0, h * 0.4890143);

    //
    double y1 = h * cp;
    double y2 = h - (h * cp);
    // path0.moveTo(0, y1);
    path0.moveTo(0, y1);
    path0.moveTo(0, y2);

    //x2
    double x2 = w * ap;
    double y3 = (h - (h * cp) * 2) / 2;
    path0.lineTo(x2, y2);
    path0.lineTo(x2, h);

    path0.lineTo(w, y3);

    path0.lineTo(x2, 0);
    path0.lineTo(x2, y1);
    path0.lineTo(0, y1);

//
    // path0.lineTo(w * 0.8545167, 0);
    // path0.lineTo(w, h * 0.4991714);
    // path0.lineTo(w * 0.8551250, h);
    // path0.lineTo(0, h);
    // path0.lineTo(w * 0.0013417, h);
    // path0.lineTo(0, h);
    path0.close();
    return path0;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class SignalDetail extends StatefulWidget {
  @override
  _SignalDetailState createState() => _SignalDetailState();
}

class _SignalDetailState extends State<SignalDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            assetImages(Assets.eagleAi, width: 30),
            width10(),
            titleLargeText('EAGLE Ai', context,
                color: Colors.white, useGradient: true),
          ],
        ),
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: userAppBgImageProvider(context),
              fit: BoxFit.cover,
              opacity: 1),
        ),
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            color: bColor,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Column(
                    children: [
                      assetImages(Assets.appWebLogo, height: 50),
                      height10(),
                      Row(children: [
                        Expanded(
                            child: Container(color: Colors.white70, height: 1))
                      ]),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          titleLargeText(' USD/JPY', context,
                              useGradient: true, fontSize: 23),
                        ],
                      ),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          assetImages(Assets.candleStick, width: 15),
                          width5(),
                          capText(
                            formatDate(DateTime.parse('2023-08-05 12:36:67'),
                                    'dd MMM yyyy h:m a') +
                                ' ' +
                                '(GMT+1)',
                            context,
                            color: Color.fromARGB(255, 169, 175, 179),
                          ),
                        ],
                      ),
                      height20(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyLargeText('ENTRY:', context, useGradient: false),
                          Row(
                            children: [
                              bodyLargeText('190.000', context,
                                  useGradient: false, color: appLogoColor),
                              width5(),
                              GestureDetector(
                                onTap: () => copyToClipboard('Entry: 190.000'),
                                child: Icon(Icons.copy_all_rounded,
                                    color: Color.fromARGB(249, 241, 224, 224),
                                    size: 15),
                              ),
                            ],
                          ),
                        ],
                      ),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyLargeText('STOP LOSS:', context,
                              useGradient: false),
                          Row(
                            children: [
                              bodyLargeText('108.500', context,
                                  useGradient: false, color: appLogoColor),
                              width5(),
                              GestureDetector(
                                onTap: () =>
                                    copyToClipboard('Stop Loss: 190.000'),
                                child: Icon(Icons.copy_all_rounded,
                                    color: Color.fromARGB(249, 241, 224, 224),
                                    size: 15),
                              ),
                            ],
                          ),
                        ],
                      ),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyLargeText('TAKE PROFIT 1:', context,
                              useGradient: false),
                          Row(
                            children: [
                              bodyLargeText('109.100', context,
                                  useGradient: false, color: appLogoColor),
                              width5(),
                              GestureDetector(
                                onTap: () =>
                                    copyToClipboard('Take Profit : 190.000'),
                                child: Icon(Icons.copy_all_rounded,
                                    color: Color.fromARGB(249, 241, 224, 224),
                                    size: 15),
                              ),
                            ],
                          ),
                        ],
                      ),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyLargeText('TAKE PROFIT 2:', context,
                              useGradient: false),
                          bodyLargeText('109.400', context,
                              useGradient: false, color: appLogoColor),
                        ],
                      ),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyLargeText('TAKE PROFIT 3:', context,
                              useGradient: false),
                          bodyLargeText('109.700', context,
                              useGradient: false, color: appLogoColor),
                        ],
                      ),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyLargeText('TAKE PROFIT 4:', context,
                              useGradient: false),
                          bodyLargeText('110.000', context,
                              useGradient: false, color: appLogoColor),
                        ],
                      ),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyLargeText('TAKE PROFIT 5:', context,
                              useGradient: false),
                          bodyLargeText('110.000', context,
                              useGradient: false, color: appLogoColor),
                        ],
                      ),
                      height10(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          bodyLargeText('STATUS:', context, useGradient: false),
                          bodyLargeText('Active', context,
                              useGradient: false, color: Colors.green),
                        ],
                      ),
                      height30(),
                      bodyMedText('Updates', context,
                          decoration: TextDecoration.underline),
                      height10(),
                      capText('New update from market', context,
                          color: Color.fromARGB(255, 169, 175, 179)),
                    ],
                  ),

                  // up down arrow signal
                  Positioned(
                    child: assetSvg(Assets.arrowOut,
                        color: Colors.green, width: 30),
                    right: 0,
                    top: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
