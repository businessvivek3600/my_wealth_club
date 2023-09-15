import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/subscription_provider.dart';
import '/screens/card_form/card_form_widget.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import 'app_secondry_webView.dart';

class SubscriptionPurchaseDialog extends StatefulWidget {
  const SubscriptionPurchaseDialog({
    super.key,
  });

  @override
  State<SubscriptionPurchaseDialog> createState() =>
      _SubscriptionPurchaseDialogState();
}

class _SubscriptionPurchaseDialogState extends State<SubscriptionPurchaseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  TextEditingController typeController = TextEditingController();
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    var provider = sl.get<SubscriptionProvider>();
    provider.selectedTypeKey = null;
    provider.selectedPackage = null;
    provider.voucherController.clear();
    provider.typeController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 30, vertical: Get.height * 0.2),
            decoration: BoxDecoration(
              // color: appLogoColor.withOpacity(0.8),
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                CupertinoIcons.clear_circled_solid,
                                // color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        height5(),
                        bodyLargeText('Payment Type', context,
                            color: Colors.black, fontWeight: FontWeight.w500),
                        height5(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                controller: provider.typeController,
                                onTap: () {
                                  Get.dialog(
                                    // SelectPaymentMethodDialog(),
                                    buildDraggableScrollableSheet(provider),
                                    barrierColor: Colors.transparent,
                                  );
                                },
                                enabled: true,
                                cursorColor: Colors.black,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    hintText: 'Select method',
                                    hintStyle: TextStyle(color: Colors.black),
                                    helperText: provider.selectedTypeKey ==
                                            'MCC Commission Wallet'
                                        ? '${provider.typeController.text}: $currency_icon${provider.commissionMBal.toStringAsFixed(2)}'
                                        : provider.selectedTypeKey ==
                                                'NG Commission Wallet'
                                            ? '${provider.typeController.text}: $currency_icon${provider.commissionNBal.toStringAsFixed(2)}'
                                            : provider.selectedTypeKey ==
                                                    'Amgen Wallet'
                                                ? '${provider.typeController.text}: $currency_icon${provider.amgenBal.toStringAsFixed(2)}'
                                                : provider.selectedTypeKey ==
                                                        'NG Cash Wallet'
                                                    ? '${provider.typeController.text}: $currency_icon${provider.cashNBal.toStringAsFixed(2)}'
                                                    : null,
                                    helperStyle: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(5)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(5)),
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_circle_outlined,
                                      color: Colors.black,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (provider.selectedTypeKey == 'E-Pin')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  controller: provider.voucherController,
                                  enabled: true,
                                  cursorColor: Colors.black,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'Enter voucher code',
                                    hintStyle: TextStyle(color: Colors.black),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          height10(16),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 16),
                      physics: BouncingScrollPhysics(),
                      children: [
                        ...provider.packages.map(
                          (package) => GestureDetector(
                            onTap: () {
                              provider.selectedPackage = package;
                              AwesomeDialog(
                                dialogType: DialogType.info,
                                dismissOnBackKeyPress: false,
                                dismissOnTouchOutside: false,
                                animType: AnimType.bottomSlide,
                                title: 'Do you want to add subscription?',
                                context: context,
                                btnCancelText: 'No',
                                btnOkText: 'Yes Sure!',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {
                                  print(provider.selectedTypeKey);
                                  primaryFocus?.unfocus();
                                  provider.buySubscription(package);
                                },
                                reverseBtnOrder: true,
                              ).show();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: CachedNetworkImage(
                                imageUrl: package.image ?? '',
                                placeholder: (context, url) => SizedBox(
                                  height: 50,
                                  width: 150,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: appLogoColor.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    width: 180,
                                    child: assetImages(Assets.appWebLogo)),
                                cacheManager: CacheManager(Config(
                                  "${AppConstants.appID}_${package.name}",
                                  stalePeriod: const Duration(days: 7),
                                  //one week cache period
                                )),
                              ),
                              // child: Image.network(package.image ?? ''),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

DraggableScrollableSheet buildDraggableScrollableSheet(
    SubscriptionProvider provider) {
  return DraggableScrollableSheet(
    maxChildSize: 0.9,
    minChildSize: 0.3,
    initialChildSize: 0.7,
    builder: (BuildContext context, ScrollController scrollController) {
      return Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(top: kToolbarHeight),
          decoration: BoxDecoration(
              // color: Color(0xff0d193e),
              color: defaultBottomSheetColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
          child: Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(top: 30, bottom: 20),
                controller: scrollController,
                itemCount: provider.paymentTypes.entries.toList().length,
                itemBuilder: (BuildContext context, int index) {
                  var type = provider.paymentTypes.entries.toList()[index];
                  return ListTile(
                      onTap: () {
                        Get.back();
                        provider.setSelectedTypeKey(type.key);
                        provider.typeController.text = type.value;
                        print(provider.selectedTypeKey);
                        if (type.key != 'E-Pin') {
                          provider.voucherController.clear();
                        }
                      },
                      title: bodyLargeText(type.value, context));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 3,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class SelectPaymentMethodDialog extends StatelessWidget {
  const SelectPaymentMethodDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: kToolbarHeight),
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: mainColor,
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10),
          // controller: scrollController,
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                title: titleLargeText('Payment Method $index', context));
          },
        ),
      ),
    );
  }
}
