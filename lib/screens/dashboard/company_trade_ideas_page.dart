import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '/database/model/response/trade_idea_model.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../sl_container.dart';
import '../../widgets/load_more_container.dart';
import '/constants/assets_constants.dart';
import '/utils/color.dart';
import '/database/functions.dart';
import '/utils/default_logger.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

class CompanyTradeIdeasPage extends StatefulWidget {
  const CompanyTradeIdeasPage({super.key});
  static const String routeName = '/company_trade_ideas_page';

  @override
  State<CompanyTradeIdeasPage> createState() => _CompanyTradeIdeasPageState();
}

class _CompanyTradeIdeasPageState extends State<CompanyTradeIdeasPage> {
  var provider = sl.get<DashBoardProvider>();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.getTradeIdea(true);
      //timer
      timer = Timer.periodic(Duration(seconds: 30), (Timer t) {
        provider.tradeIdeaPage = 0;
        provider.getTradeIdea(false);
      });

      // check if there is any arguments
      final args = ModalRoute.of(context)!.settings.arguments;
      successLog('arguments--> $args ${args.runtimeType}');
      if (args != null && args is String && args.isNotEmpty) {
        Map<String, dynamic> data = jsonDecode(args);
        var signal_id = data['signal_id'];
        if (signal_id != null) {
          Get.to(() =>
              SignalDetail(trade: TradeIdeaModel(id: signal_id), init: true));
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    provider.tradeIdeaPage = 0;
    provider.tradeIdeas.clear();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardProvider>(builder: (context, provider, _) {
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
            child: LoadMoreContainer(
                // height: 200,
                finishWhen:
                    provider.tradeIdeas.length == provider.totalTradeIdeas,
                onLoadMore: _loadMore,
                onRefresh: _refresh,
                builder: (scrollController, status) {
                  if (status == LoadMoreStatus.error) {
                    return Container(
                      height: 50,
                      child: Center(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: appLogoColor,
                                width: 1,
                                style: BorderStyle.solid),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          onPressed: () => _refresh(),
                          child: bodyLargeText('Retry', context),
                        ),
                      ),
                    );
                  }
                  return ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      ...provider.tradeIdeas
                          .map((trade) => _TradeTile(trade: trade)),
                      if (provider.loadingTradeIdeas)
                        Container(
                            padding: const EdgeInsets.all(20),
                            height: provider.tradeIdeas.length == 0
                                ? Get.height -
                                    kToolbarHeight -
                                    kBottomNavigationBarHeight
                                : 100,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white))),
                    ],
                  );
                }),
          ));
    });
  }

  Future<void> _loadMore() async {
    await provider.getTradeIdea();
  }

  Future<void> _refresh() async {
    provider.tradeIdeaPage = 0;
    await provider.getTradeIdea();
  }
}

class _TradeTile extends StatelessWidget {
  _TradeTile({
    super.key,
    required this.trade,
  });
  final TradeIdeaModel trade;
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
            onTap: () => Get.to(() => SignalDetail(trade: trade)),
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
                frontWidget: frontCard(trade, bColor(), context, tColor),
                backWidget: backCard(bColor(), context, tColor),
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

  Stack frontCard(
      TradeIdeaModel trade, Color bColor, BuildContext context, Color tColor) {
    bool isBuy = (trade.direction ?? '').toLowerCase() == 'buy';
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
                          titleLargeText(trade.market ?? '', context,
                              color: tColor, useGradient: true, fontSize: 23),
                          width5(),
                          SpinKitPulse(
                            color: Colors.green,
                            size: 20.0,
                          ),
                        ],
                      ),
                      width5(),
                      titleLargeText(
                          double.parse(trade.entry ?? '0').toStringAsFixed(2),
                          context,
                          color: appLogoColor),
                    ],
                  ),
                  height10(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (trade.date != null && trade.time != null)
                        Row(
                          children: [
                            assetImages(Assets.candleStick, width: 15),
                            width5(),
                            capText(
                              formatDate(
                                      DateTime.parse(
                                          trade.date! + ' ' + trade.time!),
                                      'dd MMM yyyy hh:mm:ss a') +
                                  '  ' +
                                  '(GMT+1)',
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
                            double.parse(trade.stopLoss ?? '0')
                                .toStringAsFixed(2),
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
            infoLog('b.maxHeight: ${b.maxHeight} $isBuy');
            Color color1 = Color.fromARGB(255, 19, 176, 4);
            Color color2 = Color.fromARGB(255, 249, 28, 4);
            return Container(
              width: 5,
              decoration:
                  BoxDecoration(color: isBuy ? color1 : color2, boxShadow: [
                BoxShadow(
                  color: isBuy ? color1 : color2,
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
  SignalDetail({super.key, required this.trade, this.init = false});
  final TradeIdeaModel trade;
  final bool init;
  @override
  _SignalDetailState createState() => _SignalDetailState();
}

class _SignalDetailState extends State<SignalDetail> {
  late TradeIdeaModel trade;
  var provider = sl.get<DashBoardProvider>();
  late Timer timer;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    trade = widget.trade;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
      timer = Timer.periodic(Duration(seconds: 10), (Timer t) async {
        if (isOnline) {
          var _trade = await provider.tradeIdeasDetails(widget.trade.id ?? '');
          if (_trade != null) {
            setState(() {
              trade = _trade;
            });
          }
        }
      });
    });
  }

  void init() async {
    if (widget.init) {
      setState(() {
        loading = true;
      });
      var _trade = await provider.tradeIdeasDetails(widget.trade.id ?? '');
      if (_trade != null) {
        trade = _trade;
      }
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool active = trade.status == '1';
    bool isBuy = (trade.direction ?? '').toLowerCase() == 'buy';
    bool deleted = trade.isDeleted != null && trade.isDeleted!;
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
            color: bColor(),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: deleted || loading ? 300 : null,
              padding: EdgeInsets.all(16.0),
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : deleted && !loading
                      ? Center(
                          child: bodyLargeText(
                              'This trade has been deleted or removed.',
                              context))
                      : buildSignalDetails(context, active, isBuy),
            ),
          ),
        ),
      ),
    );
  }

  Stack buildSignalDetails(BuildContext context, bool active, bool isBuy) {
    return Stack(
      children: [
        Column(
          children: [
            assetImages(Assets.appWebLogo, height: 50),
            height10(),
            Row(children: [
              Expanded(child: Container(color: Colors.white70, height: 1))
            ]),
            height10(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                titleLargeText(trade.market ?? '', context,
                    useGradient: true, fontSize: 23),
              ],
            ),
            height10(),
            if (trade.date != null && trade.time != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  assetImages(Assets.candleStick, width: 15),
                  width5(),
                  capText(
                    formatDate(DateTime.parse(trade.date! + ' ' + trade.time!),
                            'dd MMM yyyy hh:mm:ss a') +
                        '  ' +
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
                    bodyLargeText(
                        (double.tryParse(trade.entry ?? '0') ?? 0)
                            .toStringAsFixed(2),
                        context,
                        useGradient: false,
                        color: appLogoColor),
                    width5(),
                    GestureDetector(
                      onTap: () => copyToClipboard(
                          'Entry: ${(double.tryParse(trade.entry ?? '0') ?? 0).toStringAsFixed(2)}'),
                      child: Icon(Icons.copy_all_rounded,
                          color: Color.fromARGB(249, 241, 224, 224), size: 15),
                    ),
                  ],
                ),
              ],
            ),
            height10(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                bodyLargeText('STOP LOSS:', context, useGradient: false),
                Row(
                  children: [
                    bodyLargeText(
                        (double.tryParse(trade.stopLoss ?? '0') ?? 0)
                            .toStringAsFixed(2),
                        context,
                        useGradient: false,
                        color: appLogoColor),
                    width5(),
                    GestureDetector(
                      onTap: () => copyToClipboard(
                          'Stop Loss: ${(double.tryParse(trade.stopLoss ?? '0') ?? 0).toStringAsFixed(2)}'),
                      child: Icon(Icons.copy_all_rounded,
                          color: Color.fromARGB(249, 241, 224, 224), size: 15),
                    ),
                  ],
                ),
              ],
            ),
            height10(),
            if (trade.tP1 != null && trade.tP1!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bodyLargeText('TAKE PROFIT 1:', context, useGradient: false),
                  Row(
                    children: [
                      bodyLargeText(
                          (double.tryParse(trade.tP1 ?? '0') ?? 0)
                              .toStringAsFixed(2),
                          context,
                          useGradient: false,
                          color: appLogoColor),
                      width5(),
                      GestureDetector(
                        onTap: () => copyToClipboard(
                            'Take Profit : ${(double.tryParse(trade.tP1 ?? '0') ?? 0).toStringAsFixed(2)}'),
                        child: Icon(Icons.copy_all_rounded,
                            color: Color.fromARGB(249, 241, 224, 224),
                            size: 15),
                      ),
                    ],
                  ),
                ],
              ),
            height10(),
            if (trade.tP2 != null && trade.tP2!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bodyLargeText('TAKE PROFIT 2:', context, useGradient: false),
                  bodyLargeText(
                      (double.tryParse(trade.tP2 ?? '0') ?? 0)
                          .toStringAsFixed(2),
                      context,
                      useGradient: false,
                      color: appLogoColor),
                ],
              ),
            height10(),
            if (trade.tP3 != null && trade.tP3!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bodyLargeText('TAKE PROFIT 3:', context, useGradient: false),
                  bodyLargeText(
                      (double.tryParse(trade.tP3 ?? '0') ?? 0)
                          .toStringAsFixed(2),
                      context,
                      useGradient: false,
                      color: appLogoColor),
                ],
              ),
            height10(),
            // if (trade.tP4 != null &&
            //     trade.tP4!.isNotEmpty)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       bodyLargeText('TAKE PROFIT 4:', context,
            //           useGradient: false),
            //       bodyLargeText(
            //           double.parse(trade.tP4 ?? '0')
            //               .toStringAsFixed(2),
            //           context,
            //           useGradient: false,
            //           color: appLogoColor),
            //     ],
            //   ),
            // height10(),
            // if (trade.tP5 != null &&
            //     trade.tP5!.isNotEmpty)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       bodyLargeText('TAKE PROFIT 5:', context,
            //           useGradient: false),
            //       bodyLargeText(
            //           double.parse(trade.tP5 ?? '0')
            //               .toStringAsFixed(2),
            //           context,
            //           useGradient: false,
            //           color: appLogoColor),
            //     ],
            //   ),

            //
            height10(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                bodyLargeText('STATUS:', context, useGradient: false),
                bodyLargeText(active ? 'Active' : 'De-Active', context,
                    useGradient: false,
                    color: active ? Colors.green : Colors.red),
              ],
            ),
            height30(),
            bodyMedText('Updates', context,
                decoration: TextDecoration.underline),
            height10(),
            capText(trade.updates ?? '', context,
                color: Color.fromARGB(255, 169, 175, 179)),
          ],
        ),

        // up down arrow signal
        Positioned(
          child: assetSvg(isBuy ? Assets.arrowOut : Assets.arrowIn,
              color: isBuy ? Colors.green : Colors.red, width: 30),
          right: 0,
          top: 0,
        ),
      ],
    );
  }
}
