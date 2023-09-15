import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/database/functions.dart';
import '/database/model/response/subscription_history_model.dart';
import '/providers/auth_provider.dart';
import '/providers/subscription_provider.dart';
import '/screens/drawerPages/subscription/subscription_requests_history_page.dart';
import '/sl_container.dart';
import 'package:provider/provider.dart';

import '../../../constants/assets_constants.dart';
import '../../../utils/color.dart';
import '../../../utils/sizedbox_utils.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/skeleton.dart';
import '../../../utils/text.dart';
import '../../../widgets/SubscriptionPurchaseDialog.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key, this.initPurchaseDialog = false})
      : super(key: key);
  static const String routeName = '/SubscriptionPage';
  final bool initPurchaseDialog;
  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  void initState() {
    sl.get<SubscriptionProvider>().getSubscription(false).then((value) {
      if (widget.initPurchaseDialog) {
        Get.dialog(const SubscriptionPurchaseDialog(),
            barrierColor: Colors.transparent);
      }
    });
    super.initState();
  }

  // @override
  // void dispose() {
  //   var provider = sl.get<SubscriptionProvider>();
  //   provider.selectedTypeKey = null;
  //   provider.selectedPackage = null;
  //   provider.voucherController.clear();
  //   provider.typeController.clear();
  //   super.dispose();
  // }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';

    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          body: Stack(
            children: [
              Container(
                height: double.maxFinite,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: userAppBgImageProvider(context),
                      fit: BoxFit.cover,
                      opacity: 1),
                ),
                child: CustomScrollView(
                  slivers: <Widget>[
                    buildSliverAppBar(size),
                    buildSliverList(provider, currency_icon),
                  ],
                ),
              ),
              // buildPurchaseButton()
            ],
          ),
          bottomNavigationBar: (!provider.loadingSub &&
                  provider.history.isNotEmpty)
              ? Padding(
                  padding:
                      const EdgeInsets.only(bottom: 25.0, left: 16, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () => checkServiceEnableORDisable(
                                    'mobile_is_subscription', () {
                                  Get.dialog(
                                      const SubscriptionPurchaseDialog());
                                }),
                            child: Text('Purchase')),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  Positioned buildPurchaseButton() {
    return Positioned(
        bottom: 30,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Get.dialog(const SubscriptionPurchaseDialog(),
                      // enterBottomSheetDuration: const Duration(milliseconds: 200),
                      // enableDrag: false,
                      barrierColor: Colors.transparent
                      // isDismissible: false,
                      );
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: appLogoColor),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text('Purchase'),
                )),
          ],
        ));
  }

  SliverPadding buildSliverList(
      SubscriptionProvider provider, String currency_icon) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      sliver: (!provider.loadingSub && provider.history.isEmpty)
          ? SliverToBoxAdapter(
              child: SizedBox(
                height: Get.height - kToolbarHeight * 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    titleLargeText(
                        'You have not purchased any subscription.', context,
                        textAlign: TextAlign.center),
                    height10(),
                    bodyLargeText('Please explore our products', context),
                    height10(),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 30),
                            child: ElevatedButton(
                                onPressed: () {
                                  Get.dialog(
                                      const SubscriptionPurchaseDialog());
                                },
                                child: Text('Purchase')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var history = SubscriptionHistory();
                  if (!provider.loadingSub) {
                    history = provider.history[index];
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: !provider.loadingSub
                          ? ExpansionTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  titleLargeText(
                                      '$currency_icon${history.packageAmount}',
                                      context),
                                  width20(),
                                  Expanded(
                                    child: bodyLargeText(
                                      (history.packageName ?? ''),
                                      context,
                                      textAlign: TextAlign.end,
                                      // style: TextStyle(
                                      //     fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  capText(
                                    DateFormat().add_yMMMEd().format(
                                        DateTime.parse(
                                            history.createdAt ?? '')),
                                    context,
                                    textAlign: TextAlign.center,
                                    // style: TextStyle(
                                    //     fontWeight: FontWeight.bold),
                                  ),
                                  width20(),
                                  capText(
                                    DateFormat().add_jm().format(DateTime.parse(
                                        history.createdAt ?? '')),
                                    context,
                                    textAlign: TextAlign.center,
                                    // style: TextStyle(
                                    //     fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              collapsedBackgroundColor: Colors.white24,
                              backgroundColor: Colors.white24,
                              iconColor: Colors.white,
                              textColor: Colors.white,
                              collapsedTextColor: Colors.white54,
                              collapsedIconColor: Colors.white,
                              // initiallyExpanded: true,
                              children: [
                                Container(
                                  // height: 100,
                                  width: double.maxFinite,
                                  padding: EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: bodyLargeText(
                                              '${history.packageName ?? ''}',
                                              context,
                                              // color: index % 2 == 0
                                              //     ? yearlyPackColor
                                              //     : monthlyPackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // titleLargeText('\$35', context),
                                      height5(),
                                      Row(
                                        children: [
                                          capText('Order ID:', context),
                                          width10(),
                                          capText(
                                              history.invoiceId ??
                                                  history.stripeInvNo ??
                                                  '',
                                              context,
                                              fontWeight: FontWeight.bold),
                                        ],
                                      ),
                                      height5(),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: bodyLargeText(
                                              history.paymentType ?? '',
                                              context,
                                              // color: history.packageName != 'Monthly Pack'
                                              //     ? yearlyPackColor
                                              //     : monthlyPackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Skeleton(
                              height: 50,
                              width: double.maxFinite,
                              textColor: Colors.white54,
                            ),
                    ),
                  );
                },
                //     Container(
                //   // height: 150,
                //   width: double.maxFinite,
                //   margin: const EdgeInsets.only(bottom: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.white10,
                //     // border: Border.all(color: Colors.white),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Container(
                //         height: 45,
                //         width: double.maxFinite,
                //         margin: const EdgeInsets.only(bottom: 10),
                //         decoration: BoxDecoration(
                //           color: index % 2 == 0
                //               ? yearlyPackColor.withOpacity(01)
                //               : monthlyPackColor.withOpacity(01),
                //           borderRadius: const BorderRadius.only(
                //             topLeft: Radius.circular(10),
                //             topRight: Radius.circular(10),
                //           ),
                //         ),
                //         child: Center(
                //             child: titleLargeText(
                //                 index % 2 == 0 ? 'Yearly Pack' : 'Monthly Pack',
                //                 context,
                //                 textAlign: TextAlign.center)),
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: <Widget>[
                //                 titleLargeText('\$35', context),
                //               ],
                //             ),
                //             height10(),
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               children: <Widget>[
                //                 capText(
                //                     'Activated on ${index + 1} March 2023 2:00 PM',
                //                     context),
                //               ],
                //             ),
                //             height10(),
                //             bodyLargeText('Wallet', context),
                //             const Divider(color: Colors.amber),
                //             Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 Expanded(
                //                   child: capText(
                //                       '	You received fund from MCC Commission Wallet',
                //                       context),
                //                 ),
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ), //ListTile
                childCount: !provider.loadingSub ? provider.history.length : 10,
              ), //SliverChildBuildDelegate
            ),
    );
  }

  SliverAppBar buildSliverAppBar(Size size) {
    return SliverAppBar(
      snap: false,
      pinned: true,
      floating: false,
      backgroundColor: mainColor,
      expandedHeight: size.height * 0.15,
      // collapsedHeight: size.height * 0.08,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: titleLargeText("My Subscriptions", context), //Text
        //Images.network
      ),
      actions: [
        Row(
          children: [
            SizedBox(
              height: 25,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionRequestsPage(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  // backgroundColor: appLogoColor,
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: appLogoColor)),
                ),
                child: bodyLargeText('History', context,
                    fontWeight: FontWeight.normal),
              ),
            ),
            width10(),
          ],
        ),
      ],
    );
  }
}
