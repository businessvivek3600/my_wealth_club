import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/load_more_container.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/voucher_model.dart';
import '/providers/auth_provider.dart';
import '/providers/voucher_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../dashboard/main_page.dart';

class GiftVoucherPage extends StatefulWidget {
  const GiftVoucherPage({Key? key}) : super(key: key);

  @override
  State<GiftVoucherPage> createState() => _GiftVoucherPageState();
}

class _GiftVoucherPageState extends State<GiftVoucherPage> {
  var provider = sl.get<VoucherProvider>();
  @override
  void initState() {
    provider.getVoucherList(true).then((value) {
      if (provider.packages.isNotEmpty) {
        provider.setCurrentIndex(0);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    provider.currentIndex = 0;
    provider.totalVouchers = 0;
    provider.voucherPage = 0;
    provider.currentPackage = null;
    provider.packages.clear();
    provider.paymentTypes.clear();
    provider.history.clear();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await provider.getVoucherList(false);
  }

  Future<void> _refresh() async {
    provider.voucherPage = 0;
    await provider.getVoucherList(false);
  }

// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzYTNmOTI0NTNjODViYzEyNjU4ZjNiZSIsInVzZXJuYW1lIjoiSnVkZ2VfQ3JvbmluIiwiaWF0IjoxNjcxNjk3MTcxfQ.hbZLKSsS6Mdj1ndhAf4rm_5we4iWYvKY1VPSo51sQRM
  @override
  Widget build(BuildContext context) {
    return Consumer<VoucherProvider>(
      builder: (context, provider, child) {
        print(
            'gift voucher history length ${provider.history.length}/${provider.totalVouchers}}');
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(
              title: titleLargeText('Vouchers', context, useGradient: true),
              shadowColor: Colors.white),
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: userAppBgImageProvider(context),
                  fit: BoxFit.cover,
                  opacity: 1),
            ),
            child: !provider.loadingVoucher
                ? LoadMoreContainer(
                    finishWhen:
                        provider.history.length >= provider.totalVouchers,
                    onLoadMore: _loadMore,
                    onRefresh: _refresh,
                    builder: (scrollController, status) {
                      return ListView(
                        controller: scrollController,
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        physics: BouncingScrollPhysics(),
                        children: [
                          Container(
                            height: !provider.loadingVoucher &&
                                    provider.packages.isEmpty
                                ? Get.height * 0.3
                                : Get.height * 0.3,
                            width: double.maxFinite,
                            child: (provider.loadingVoucher ||
                                    provider.packages.isNotEmpty)
                                ? Column(
                                    children: [
                                      height10(),
                                      Expanded(child: VoucherCarousel()),
                                      buildVoucherDetailsCard(provider, context)
                                    ],
                                  )
                                : buildNoVouchers(context),
                          ),
                          SizedBox(height: 20),
                          ...provider.history
                              .map((e) => buildVoucher(e, context)),
                          if (provider.history.isEmpty)
                            Divider(color: Colors.white54),
                          if (provider.history.isEmpty)
                            buildEmptyHistory(context),
                        ],
                      );
                    })
                : Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
          // bottomNavigationBar: buildBottomButton(context),
        );
      },
    );
  }

  Column buildEmptyHistory(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: Get.height * 0.2, child: assetLottie(Assets.emptyCards)),
        bodyLargeText("You don't have any voucher yet.", context,
            textAlign: TextAlign.center),
      ],
    );
  }

  Container buildVoucherDetailsCard(
      VoucherProvider provider, BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              // border: Border.all(),
              borderRadius: BorderRadius.circular(5),
              // color: Colors.white,
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black12,
              //     blurRadius: 5,
              //     spreadRadius: 1,
              //   )
              // ],
            ),
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                UiCategoryTitleContainer(
                    child: bodyLargeText('My Vouchers', context,
                        color: Colors.white)),
                width10(),
                bodyLargeText('(', context, color: Colors.white),
                bodyLargeText(
                    '${provider.history.where((element) => element.usedBy == null).length}',
                    context,
                    color: Colors.orange),
                bodyLargeText(')', context, color: Colors.white),
              ],
            ),
          ),
          width10(),
          GestureDetector(
            onTap: () => checkServiceEnableORDisable(
                'mobile_is_voucher', () => buildShowModalBottomSheet(context)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                  ]),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.add,
                  //   size: 18,
                  //   weight: 20,
                  //   color: appLogoColor,
                  // ),
                  // width5(),
                  bodyMedText('Get It Now', context,
                      color: appLogoColor, fontWeight: FontWeight.bold),
                ],
              ),
              // style: ElevatedButton.styleFrom(
              //     elevation: 10,
              //     shadowColor: Colors.black54,
              //     backgroundColor: purpleDark,
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(50))),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVoucher(VoucherModel e, BuildContext context) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';

    bool used = e.usedBy != null;
    Color textColor = !used ? Colors.black : Colors.black54;

    Color primaryColor1 = used ? Color(0xfff1e3d3) : Color(0xffcbf3f0);
    Color appLogoColor2 = used ? Color(0xffd88c9a) : Color(0xff368f8b);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
      child: CouponCard(
          height: 130,
          backgroundColor: primaryColor1,
          clockwise: true,
          curvePosition: 120,
          curveRadius: 30,
          curveAxis: Axis.vertical,
          borderRadius: 10,
          firstChild: Container(
            decoration: BoxDecoration(color: appLogoColor2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.packageName ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))),
                  ),
                ),
                const Divider(color: Colors.white54, height: 0),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                          onPressed: !used
                              ? () {
                                  Clipboard.setData(
                                          ClipboardData(text: e.epin ?? ''))
                                      .then((value) => Fluttertoast.showToast(
                                          msg: 'Voucher code copied!'));
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              disabledBackgroundColor: primaryColor1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: capText(
                                      !used ? "REDEEM" : 'REDEEMED', context,
                                      color: appLogoColor2,
                                      fontWeight: FontWeight.bold,
                                      textAlign: TextAlign.center)),
                              // width10(),
                              Icon(Icons.copy_rounded,
                                  size: 15, color: appLogoColor2)
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          secondChild: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voucher Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.epin ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          color: appLogoColor2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    capText('Used By:', context, color: textColor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          capText(e.usedBy ?? 'Not Yet', context,
                              color: e.usedBy != null ? bColor() : textColor,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.bold),
                          if (e.updatedAt != null)
                            capText(
                                DateFormat()
                                    .add_yMMMd()
                                    .add_jm()
                                    .format(DateTime.parse(e.updatedAt ?? '')),
                                context,
                                fontWeight: FontWeight.w500,
                                fontSize: 9,
                                color: textColor),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    capText('Created At: ', context,
                        color: textColor, fontSize: 10),
                    if (e.createdAt != null)
                      capText(
                          DateFormat()
                              .add_yMMMd()
                              .format(DateTime.parse(e.createdAt ?? "")),
                          context,
                          color: textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500),
                  ],
                ),
                Spacer(),
              ],
            ),
          )),
    );
  }

  Padding buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            Expanded(
              child: Builder(builder: (context) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(),
                  onPressed: () => buildShowModalBottomSheet(context),
                  child: bodyMedText('Create New Voucher', context,
                      textAlign: TextAlign.center),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.white24,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (context) => CreateVoucherDialogWidget());
  }

  Column buildNoVouchers(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Expanded(child: assetSvg(Assets.gift, color: Colors.white)),
        Expanded(
          child: Center(
            child: titleLargeText('No Active Vouchers', context),
          ),
        ),
      ],
    );
  }
}

class VoucherCarousel extends StatelessWidget {
  VoucherCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VoucherProvider>(
      builder: (context, provider, child) {
        return CarouselSlider(
            carouselController: provider.carouselController,
            items: <Widget>[
              if (!provider.loadingVoucher)
                ...provider.packages.map((package) => GestureDetector(
                    onTap: () {
                      // provider.buyEventTicketsRequest(e.id ?? '');
                      // Get.to(BuyEventTicket(event: e));
                    },
                    child: ClipRRect(
                        // width: 300,
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(children: [
                          CachedNetworkImage(
                            imageUrl: package.giftImg ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => SizedBox(
                                height: 150,
                                width: 100,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: appLogoColor.withOpacity(0.5)))),
                            errorWidget: (context, url, error) => SizedBox(
                              height: 250,
                              width: 150,
                              child:
                                  assetImages(Assets.noImage, fit: BoxFit.fill),
                            ),
                            cacheManager: CacheManager(Config(
                                "${AppConstants.packageID}_${package.giftImg ?? 'package.giftImg${package.name ?? ''}'}",
                                stalePeriod: const Duration(days: 7))),
                          ),
                        ])))),
              if (provider.loadingVoucher)
                ...[1, 2, 3, 4, 5, 6].map((e) => Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Skeleton(
                        width: 150,
                        textColor: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10))))
            ],
            options: CarouselOptions(
                height: 180,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: false,
                reverse: false,
                autoPlay: false,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                // enlargeFactor: 0.3,
                // onPageChanged: callbackFunction,
                scrollDirection: Axis.horizontal,
                onPageChanged: (page, reason) {
                  print(page);
                  provider.setCurrentIndex(page);
                },
                onScrolled: (page) {
                  // print(page);
                }));
      },
    );
  }
}

class CreateVoucherDialogWidget extends StatefulWidget {
  const CreateVoucherDialogWidget({Key? key}) : super(key: key);

  @override
  State<CreateVoucherDialogWidget> createState() =>
      _CreateVoucherDialogWidgetState();
}

class _CreateVoucherDialogWidgetState extends State<CreateVoucherDialogWidget> {
  TextEditingController countController = TextEditingController(text: '1');

  int quantity = 1;
  String? paymentMode;
  String? cryptoType;
  decrement() => setState(() => quantity--);
  increment() => setState(() => quantity++);
  @override
  Widget build(BuildContext context) {
    return Consumer<VoucherProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
              color: mainColor,
              image: DecorationImage(
                  image: userAppBgImageProvider(context),
                  fit: BoxFit.cover,
                  opacity: 1),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20))),
          padding: EdgeInsets.symmetric(vertical: 10),
          margin: EdgeInsets.only(top: kToolbarHeight * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              height5(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 3,
                      width: 30,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2)))
                ],
              ),
              height20(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    SizedBox(
                      height: 150,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (provider.currentPackage != null)
                              CachedNetworkImage(
                                imageUrl:
                                    provider.currentPackage!.giftImg ?? '',
                                placeholder: (context, url) => SizedBox(
                                    height: 50,
                                    width: 100,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            color: appLogoColor
                                                .withOpacity(0.5)))),
                                errorWidget: (context, url, error) =>
                                    assetImages(Assets.noImage),
                                cacheManager: CacheManager(Config(
                                  "${AppConstants.packageID}_${e}",
                                  stalePeriod: const Duration(days: 7),
                                  //one week cache period
                                )),
                              ),
                          ]),
                    ),
                    height20(),

                    height10(),

                    //payment mode
                    titleLargeText('Payment Methods', context,
                        color: Colors.white, fontWeight: FontWeight.w500),
                    height5(),
                    Wrap(
                      spacing: 10,
                      children: [
                        ...provider.paymentTypes.entries.map(
                          (type) => ChoiceChip(
                            pressElevation: 5.0,
                            selectedColor: appLogoColor,
                            backgroundColor: Colors.grey[100],
                            label: Text(
                              type.value is String ? type.value : type.key,
                              style: TextStyle(
                                  color: paymentMode == type.key
                                      ? Colors.white
                                      : null),
                            ),
                            selected: paymentMode == type.key,
                            onSelected: (bool selected) {
                              setState(() {
                                paymentMode = selected ? type.key : null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    height10(),
                    //crypto type
                    if (paymentMode == 'Crypto')
                      Builder(builder: (context) {
                        var cryptoTypes = provider.paymentTypes.entries
                            .firstWhere((element) => element.key == 'Crypto')
                            .value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Column(
                            children: [
                              titleLargeText('Crypto Type', context,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                              height5(),
                              Wrap(
                                spacing: 10,
                                children: [
                                  ...cryptoTypes.entries.map(
                                    (type) => ChoiceChip(
                                      pressElevation: 5.0,
                                      selectedColor: greenLight,
                                      backgroundColor: Colors.grey[100],
                                      label: Text(
                                        type.value,
                                        style: TextStyle(
                                            color: cryptoType == type.key
                                                ? Colors.white
                                                : null),
                                      ),
                                      selected: cryptoType == type.key,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          cryptoType =
                                              selected ? type.key : null;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                    //coupon code
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: provider.voucherCodeController,
                                readOnly: provider.couponVerified != null,
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    hintText: 'Enter MCC Coupon Code',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5)),
                                    suffixIcon:
                                        buildCouponFieldSuffix(provider)),
                              ),
                            ),
                          ],
                        ),
                        height10(5),
                        if (provider.couponVerified != null)
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: 'Coupon Applied: ',
                                style: TextStyle(color: Colors.green)),
                            TextSpan(
                                text: provider.voucherCodeController.text,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ])),
                        height10(16),
                      ],
                    ),

                    //discount note
                    if (provider.discount_note != null)
                      Column(
                        children: [
                          capText(
                            provider.discount_note!,
                            context,
                            useGradient: true,
                            fontWeight: FontWeight.w500,
                            textAlign: TextAlign.center,
                          ),
                          height10(16),
                        ],
                      ),

                    // bodyLargeText('Package Type', context,
                    //     color: Colors.black, fontWeight: FontWeight.w500),
                    // height5(),
                    // Row(
                    //   children: [
                    //     Expanded(child: FormField<String>(
                    //       builder: (FormFieldState<String> state) {
                    //         return InputDecorator(
                    //           decoration: InputDecoration(
                    //             border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(5.0),
                    //                 borderSide:
                    //                     BorderSide(color: Colors.black)),
                    //             enabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(5.0),
                    //                 borderSide:
                    //                     BorderSide(color: Colors.black)),
                    //             focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(5.0),
                    //                 borderSide:
                    //                     BorderSide(color: Colors.black)),
                    //             disabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(5.0),
                    //                 borderSide:
                    //                     BorderSide(color: Colors.black)),
                    //           ),
                    //           isEmpty: selectedType == '',
                    //           child: DropdownButtonHideUnderline(
                    //             child: provider.packageTypes.entries.isNotEmpty
                    //                 ? DropdownButton<String>(
                    //                     value: selectedType == ''
                    //                         ? provider
                    //                             .packageTypes.entries.first.key
                    //                         : selectedType,
                    //                     isDense: true,
                    //                     hint: Text('Select type'),
                    //                     alignment:
                    //                         AlignmentDirectional.bottomCenter,
                    //                     onChanged: (String? newValue) {
                    //                       setState(() {
                    //                         selectedType = newValue!;
                    //                         state.didChange(newValue);
                    //                       });
                    //                     },
                    //                     items: <DropdownMenuItem<String>>[
                    //                       ...provider.packageTypes.entries
                    //                           .toList()
                    //                           .map<DropdownMenuItem<String>>(
                    //                               (type) {
                    //                         return DropdownMenuItem<String>(
                    //                           value: type.key,
                    //                           child: Text(
                    //                             type.value,
                    //                             style: TextStyle(
                    //                                 color: Colors.black),
                    //                           ),
                    //                           onTap: () {
                    //                             setState(() {
                    //                               selectedType = type.key;
                    //                             });
                    //                           },
                    //                         );
                    //                       }).toList(),
                    //                     ],
                    //                     borderRadius: BorderRadius.circular(15),
                    //                     iconEnabledColor: Colors.black,
                    //                     style: TextStyle(color: Colors.black),
                    //                     menuMaxHeight: double.maxFinite,
                    //                     dropdownColor: Colors.white,
                    //                     focusColor: Colors.transparent,
                    //                     elevation: 10,
                    //                   )
                    //                 : Container(),
                    //           ),
                    //         );
                    //       },
                    //     )),
                    //   ],
                    // ),
                    // height5(),
                    // bodyLargeText('Joining Package', context,
                    //     color: Colors.black, fontWeight: FontWeight.w500),
                    // height5(),
                    // Row(
                    //   children: [
                    //     Expanded(child: Builder(builder: (context) {
                    //       print(' selected type = $selectedType');
                    //       print(' selected package = $selectedPackage');
                    //       List<VoucherPackageTypeModel> packages =
                    //           selectedType == '1'
                    //               ? provider.package1
                    //               : selectedType == '2'
                    //                   ? provider.package2
                    //                   : [];
                    //       return FormField<String>(
                    //         builder: (FormFieldState<String> state) {
                    //           return InputDecorator(
                    //             decoration: InputDecoration(
                    //               border: OutlineInputBorder(
                    //                   borderRadius: BorderRadius.circular(5.0),
                    //                   borderSide:
                    //                       BorderSide(color: Colors.black)),
                    //               enabledBorder: OutlineInputBorder(
                    //                   borderRadius: BorderRadius.circular(5.0),
                    //                   borderSide:
                    //                       BorderSide(color: Colors.black)),
                    //               focusedBorder: OutlineInputBorder(
                    //                   borderRadius: BorderRadius.circular(5.0),
                    //                   borderSide:
                    //                       BorderSide(color: Colors.black)),
                    //               disabledBorder: OutlineInputBorder(
                    //                   borderRadius: BorderRadius.circular(5.0),
                    //                   borderSide:
                    //                       BorderSide(color: Colors.black)),
                    //             ),
                    //             isEmpty: selectedPackage == '',
                    //             child: DropdownButtonHideUnderline(
                    //               child: packages.isNotEmpty
                    //                   ? DropdownButton<String>(
                    //                       // selectedPackage == ''
                    //                       //   ? packages.first.id
                    //                       //   :
                    //                       value: selectedPackage,
                    //                       isDense: true,
                    //                       hint: Text('Select type'),
                    //                       alignment:
                    //                           AlignmentDirectional.bottomCenter,
                    //                       onChanged: (String? newValue) {
                    //                         setState(() {
                    //                           selectedPackage = newValue!;
                    //                           state.didChange(newValue);
                    //                         });
                    //                       },
                    //                       items: <DropdownMenuItem<String>>[
                    //                         ...packages
                    //                             .map<DropdownMenuItem<String>>(
                    //                                 (type) {
                    //                           return DropdownMenuItem<String>(
                    //                             value: type.id,
                    //                             child: Text(
                    //                               type.name ?? '',
                    //                               style: TextStyle(
                    //                                   color: Colors.black),
                    //                             ),
                    //                             onTap: () {
                    //                               setState(() {
                    //                                 selectedPackage = type.id;
                    //                               });
                    //                             },
                    //                           );
                    //                         }).toList(),
                    //                       ],
                    //                       borderRadius:
                    //                           BorderRadius.circular(15),
                    //                       iconEnabledColor: Colors.black,
                    //                       style: TextStyle(color: Colors.black),
                    //                       menuMaxHeight: double.maxFinite,
                    //                       dropdownColor: Colors.white,
                    //                       focusColor: Colors.transparent,
                    //                       elevation: 10,
                    //                     )
                    //                   : Container(),
                    //             ),
                    //           );
                    //         },
                    //       );
                    //     })),
                    //   ],
                    // ),
                  ],
                ),
              ),
              height10(),

              //button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              // backgroundColor: redLight,
                              disabledBackgroundColor: Colors.grey,
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          onPressed: paymentMode != null &&
                                  provider.loadingVerifyCoupon == false &&
                                  (paymentMode == 'Crypto'
                                      ? cryptoType != null
                                      : true)
                              ? () => provider.createVoucherSubmit(
                                  payment_type: paymentMode == 'Crypto'
                                      ? cryptoType!
                                      : paymentMode!,
                                  package_id:
                                      provider.currentPackage!.packageId!,
                                  sale_type: provider.currentPackage!.saleType!)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                                paymentMode == 'Card' || paymentMode == 'Crypto'
                                    ? 'Proceed'
                                    : paymentMode != null
                                        ? 'Make Payment'
                                        : 'Select Payment Mode'),
                          )),
                    ))
                  ],
                ),
              ),
              height30(),
            ],
          ),
        );
      },
    );
  }

  AnimatedContainer buildCouponFieldSuffix(VoucherProvider provider) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: provider.loadingVerifyCoupon ? 60 : 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
            colors: textGradiantColors.map((e) => e.withOpacity(0.4)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: TextButton(
        onPressed: provider.loadingVerifyCoupon
            ? null
            : () => _handleCoupuon(provider),
        child: provider.loadingVerifyCoupon
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)),
                  ),
                ],
              )
            : Text(
                provider.couponVerified == null ? 'Check' : 'Clear',
                style: TextStyle(color: Colors.white),
              ),
      ),
    );
  }

  _handleCoupuon(VoucherProvider provider) {
    FocusScope.of(context).unfocus();
    bool couponAdded = provider.couponVerified != null;
    if (couponAdded) {
      provider.voucherCodeController.clear();
      provider.couponVerified = null;
    } else {
      if (provider.voucherCodeController.text.isNotEmpty) {
        if (provider.packages.isNotEmpty) {
          provider.verifyCoupon(provider.voucherCodeController.text);
        } else {
          Fluttertoast.showToast(msg: 'Please select a subscription pack');
        }
      } else {
        Fluttertoast.showToast(msg: 'Please enter coupon code');
      }
    }
    setState(() {});
  }
}

class TicketPassClipper extends CustomClipper<Path> {
  TicketPassClipper({this.position, this.holeRadius = 16});

  double? position;
  final double holeRadius;

  @override
  Path getClip(Size size) {
    position ??= size.width - 16;
    if (position! > size.width) {
      throw Exception('position is greater than width.');
    }
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, (position! - holeRadius))
      ..arcToPoint(
        Offset(size.width, position!),
        clockwise: false,
        radius: const Radius.circular(2),
      )
      // ..lineTo(size.width, size.height)

      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - (size.height - position!))
      ..arcToPoint(
        Offset(0, position! - holeRadius),
        clockwise: false,
        radius: const Radius.circular(1),
      )
      ..lineTo(0, size.height - (size.height - position!));
    // path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => oldClipper != this;
}
