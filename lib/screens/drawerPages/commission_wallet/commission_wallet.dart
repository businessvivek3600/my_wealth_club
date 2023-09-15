import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/commission_wallet_history_model.dart';
import '/providers/auth_provider.dart';
import '/providers/commission_wallet_provider.dart';
import '/screens/drawerPages/commission_wallet/commission_transfer_to_cash_wallet.dart';
import '/screens/drawerPages/commission_wallet/commission_withdraw_request.dart';
import '/sl_container.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/picture_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../../utils/color.dart';

class CommissionWalletPage extends StatefulWidget {
  const CommissionWalletPage({Key? key}) : super(key: key);

  @override
  State<CommissionWalletPage> createState() => _CommissionWalletPageState();
}

class _CommissionWalletPageState extends State<CommissionWalletPage> {
  var currencyIcon = sl.get<AuthProvider>().userData.currency_icon ?? '';
  @override
  void initState() {
    sl.get<CommissionWalletProvider>().getCommissionWallet();
    super.initState();
  }

  @override
  void dispose() {
    sl.get<CommissionWalletProvider>().btn_transfer = false;
    sl.get<CommissionWalletProvider>().btn_withdraw = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<CommissionWalletProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor100,
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: userAppBgImageProvider(context),
                fit: BoxFit.cover,
                opacity: 0.9,
              ),
            ),
            child: CustomScrollView(
              slivers: <Widget>[
                buildSliverAppBar(size, provider),
                (provider.loadingWallet || provider.history.isNotEmpty)
                    ? buildSliverList(provider)
                    : dataNotFound(context),
              ],
            ),
          ),
          bottomNavigationBar: (provider.btn_withdraw || provider.btn_transfer)
              ? buildBottomButtons(context, provider)
              : null,
        );
      },
    );
  }

  SliverToBoxAdapter dataNotFound(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: Get.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //TODO: dataNotFound
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //       horizontal: 30.0),
            //   child: assetLottie(Assets.dataNotFound),
            // ),
            titleLargeText('Records not found', context)
          ],
        ),
      ),
    );
  }

  SliverPadding buildSliverList(CommissionWalletProvider provider) {
    Color textColor = Colors.black;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var history = CommissionWalletHistory();
            var date = '';
            if (!provider.loadingWallet) {
              history = provider.history[index];
              date = DateFormat()
                          .add_yMMMEd()
                          .format(DateTime.parse(history.createdAt ?? '')) ==
                      DateFormat().add_yMMMEd().format(DateTime.now())
                  ? 'Today'
                  : DateFormat().add_yMMMEd().format(
                              DateTime.parse(history.createdAt ?? '')) ==
                          DateFormat().add_yMMMEd().format(
                              DateTime.now().subtract(Duration(days: 1)))
                      ? 'Yesterday'
                      : DateFormat()
                          .add_yMMMEd()
                          .format(DateTime.parse(history.createdAt ?? ''));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  bool sameDay = false;
                  if (!provider.loadingWallet && index != 0) {
                    sameDay = DateFormat()
                            .add_yMMMEd()
                            .format(DateTime.parse(history.createdAt ?? '')) ==
                        DateFormat().add_yMMMEd().format(DateTime.parse(
                            provider.history[index - 1].createdAt ?? ''));
                  }
                  return Row(
                    children: [
                      !provider.loadingWallet
                          ? !sameDay
                              ? Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: appLogoColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: capText(date, context))
                              : Container()
                          : Skeleton(
                              height: 25,
                              width: 100,
                              textColor: appLogoColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                      width10(),
                      if (!sameDay)
                        Expanded(child: Divider(color: Colors.white))
                    ],
                  );
                }),
                height5(),
                CH_CM_Transaction_Tile_Widget(
                  history: history,
                  textColor: textColor,
                  loading: provider.loadingWallet,
                ),
              ],
            );
          }, //ListTile
          childCount: !provider.loadingWallet ? provider.history.length : 11,
        ), //SliverChildBuildDelegate
      ),
    );
  }

  SliverAppBar buildSliverAppBar(Size size, CommissionWalletProvider provider) {
    return SliverAppBar(
      snap: false,
      pinned: true,
      floating: false,
      // expandedHeight: size.height * 0.2,
      // collapsedHeight: size.height * 0.08,
      backgroundColor: mainColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: titleLargeText("Commission", context),
          ),
          !provider.loadingWallet
              ? bodyLargeText(
                  "${currencyIcon}${provider.walletBalance}", context)
              : SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
        ],
      ),
      // flexibleSpace: FlexibleSpaceBar(
      //     centerTitle: true,
      //     title: Column(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: const [
      //         Text("Commission",
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontWeight: FontWeight.bold,
      //               // fontSize: 16.0,
      //             ) //TextStyle
      //             ),
      //         Text("\$4330",
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontWeight: FontWeight.bold,
      //               // fontSize: 16.0,
      //             ) //TextStyle
      //             ),
      //       ],
      //     ), //Text
      //     background: Image.asset("assets/designs/commission.jpg",
      //         fit: BoxFit.cover,
      //         opacity: const AlwaysStoppedAnimation(0.1)) //Images.network
      //     ),
    );
  }

  Padding buildBottomButtons(
      BuildContext context, CommissionWalletProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        // height: 70,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            if (provider.btn_withdraw)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(1)),
                  onPressed: () => checkServiceEnableORDisable(
                      'mobile_is_commission_wallet',
                      () => Get.to(CommissionWithdrawRequestPage())),
                  child: bodyMedText('Withdraw Request', context,
                      textAlign: TextAlign.center),
                ),
              ),
            if (provider.btn_withdraw && provider.btn_transfer) width10(),
            if (provider.btn_transfer)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorGreen.withOpacity(1)),
                  onPressed: () => checkServiceEnableORDisable(
                      'mobile_is_commission_wallet',
                      () => Get.to(CommissionTransferToCashWalletPage())),
                  child: bodyMedText('Transfer To Cash Wallet', context,
                      textAlign: TextAlign.center),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CH_CM_Transaction_Tile_Widget extends StatelessWidget {
  const CH_CM_Transaction_Tile_Widget({
    super.key,
    required this.history,
    required this.textColor,
    required this.loading,
  });

  final CommissionWalletHistory history;
  final Color textColor;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';

    return Container(
      // height: 100,
      width: double.maxFinite,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  !loading
                      ? capText(
                          DateFormat()
                              .add_jm()
                              .format(DateTime.parse(history.createdAt ?? '')),
                          context,
                          color: textColor)
                      : Skeleton(
                          height: 15,
                          width: 50,
                          textColor: Colors.black26,
                          borderRadius: BorderRadius.circular(5),
                        ),
                ],
              ),
              height10(),
              !loading
                  ? capText(parseHtmlString(history.note ?? ''), context,
                      color: textColor)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(
                          height: 15,
                          width: double.maxFinite,
                          textColor: Colors.black26,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height5(),
                        Skeleton(
                          height: 15,
                          width: Get.width / 3,
                          textColor: Colors.black26,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ],
                    ),
            ],
          ),
          const Divider(color: Colors.red),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  assetSvg(
                    Assets.arrowIn,
                    color: Colors.green,
                    width: 13,
                  ),
                  width5(),
                  !loading
                      ? capText(
                          '$currency_icon${double.parse(history.credit ?? '0').toStringAsFixed(1)}',
                          context,
                          color: textColor)
                      : Skeleton(
                          height: 13,
                          width: 30,
                          textColor: Colors.black26,
                          borderRadius: BorderRadius.circular(5),
                        ),
                ],
              ),
              Row(
                children: [
                  assetSvg(
                    Assets.arrowOut,
                    color: Colors.red,
                    width: 13,
                  ),
                  width5(),
                  !loading
                      ? capText(
                          '$currency_icon${double.parse(history.debit ?? '0').toStringAsFixed(1)}',
                          context,
                          color: textColor)
                      : Skeleton(
                          height: 13,
                          width: 30,
                          textColor: Colors.black26,
                          borderRadius: BorderRadius.circular(5),
                        ),
                ],
              ),
              Row(
                children: [
                  assetSvg(
                    Assets.balanceColored,
                    width: 13,
                  ),
                  width5(),
                  !loading
                      ? capText(
                          '$currency_icon${double.parse(history.balance ?? '0').toStringAsFixed(1)}',
                          context,
                          color: textColor)
                      : Skeleton(
                          height: 13,
                          width: 30,
                          textColor: Colors.black26,
                          borderRadius: BorderRadius.circular(5),
                        ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
