import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../constants/app_constants.dart';
import '../../test_youtube.dart';
import '../../utils/theme.dart';
import '/constants/assets_constants.dart';
import '/database/model/response/cusomer_rewards_model.dart';
import '/database/model/response/get_active_log_model.dart';
import '/main.dart';
import '/myapp.dart';
import '/providers/GalleryProvider.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/notification_provider.dart';
import '/providers/subscription_provider.dart';
import '/screens/dashboard/CardFeature/CreditCardPurchaseWidget.dart';
import '/screens/dashboard/commisstion_activity_details.dart';
import '/screens/drawerPages/subscription/subscription_page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import '/utils/toasts.dart';
import '/widgets/GalleryImagesPreviewDilaog.dart';
import '/widgets/app_rating_dialog.dart';
import '/widgets/customDrawer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../database/functions.dart';
import '../../database/my_notification_setup.dart';
import '../../providers/Cash_wallet_provider.dart';
import '../../utils/picture_utils.dart';
import '../../utils/skeleton.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  static const String routeName = '/MainPage';
  GlobalKey<ScaffoldState> dashScaffoldKey = GlobalKey();
  @override
  State<MainPage> createState() => _MainPageState();
}

ValueNotifier<int> showDashPopUP = ValueNotifier(0);
ValueNotifier<bool> canShowNextDashPopUPBool = ValueNotifier(false);

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin, RouteAware {
  OverlayEntry? overlayEntry;
  int currentPage = 0;
  AnimationController? animationController;
  Animation<double>? animation;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var dashboardProvider = sl.get<DashBoardProvider>();
  var galleryProvider = sl.get<GalleryProvider>();
  var authProvider = sl.get<AuthProvider>();

  @override
  void initState() {
    errorLog('time6 $time', 'timer---');
    dashboardProvider.getDownloadsData();
    dashboardProvider
        .getCustomerDashboard()
        .then((value) => showDashboardInitialPopUp(dashboardProvider, context));
    sl.get<NotificationProvider>().getUnRead();
    sl.get<SubscriptionProvider>().getSubscription();
    authProvider.getSignUpInitialData();
    sl.get<CashWalletProvider>().getCoinPaymentFundRequest(false);
    galleryProvider.getGalleryData(false);
    galleryProvider.getVideos(false);
    canShowNextDashPopUPBool.addListener(() {});
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setupAppRating(7 * 24).then((value) {
        if (value) {
          rateApp();
        }
      });
    });
  }

  appRating() async {}

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _onRefresh() async {
    appRating();
    dashboardProvider.getDownloadsData();
    await dashboardProvider.getCustomerDashboard();
    // .then((value) => showDashboardInitialPopUp(dashboardProvider, context));
    sl.get<NotificationProvider>().getUnRead();
    sl.get<SubscriptionProvider>().getSubscription();
    galleryProvider.getGalleryData(false);
    galleryProvider.getVideos(false);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(size);
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<DashBoardProvider>(
          builder: (context, dashBoardProvider, child) {
            ///TODO:SHOW POP UP
            return GestureDetector(
              onTap: () {
                primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: widget.dashScaffoldKey,
                backgroundColor: Colors.transparent,
                drawer: CustomDrawer(),
                body: Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: userAppBgImageProvider(context),
                        fit: BoxFit.cover,
                        opacity: 1),
                  ),
                  child: Stack(
                    children: [
                      SafeArea(
                        child: Column(
                          children: [
                            buildAppLogo(dashBoardProvider),
                            Expanded(
                              child: SmartRefresher(
                                enablePullDown: true,
                                enablePullUp: false,
                                controller: _refreshController,
                                header: MaterialClassicHeader(),
                                onRefresh: _onRefresh,
                                // footer:null,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      height10(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildTeamBuildingReferralLink(
                                              context, dashBoardProvider),
                                          height10(),
                                          _buildPlaceholderIdField(
                                              context, dashBoardProvider),
                                          height20(),
                                          // buildQRCodeContainer(
                                          //     dashBoardProvider),

                                          //platinum member logo
                                          // GestureDetector(
                                          //   onTap: () =>
                                          //       Get.to(YoutubePlayerDemoApp()),
                                          //   child: buildPlatinumMemberLogo(
                                          //       dashBoardProvider),
                                          // ),
                                          buildSubscriptionStatusBar(
                                              context, dashBoardProvider),
                                          height30(),
                                        ],
                                      ),
                                      buildSubscriptionHistory(
                                          context, size, dashBoardProvider),
                                      height20(),
                                      buildCardFeatureListview(
                                          context, size, dashBoardProvider),
                                      buildCommissionActivity(
                                          context, size, dashBoardProvider),
                                      height20(),
                                      ...buildTargetProgressCards(
                                          dashBoardProvider),
                                      ...buildTiers(context, dashBoardProvider),
                                      height100(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildDrawerMenuButton(dashBoardProvider),
                      buildSQRCodeContainer(dashBoardProvider),
                    ],
                  ),
                ),
                floatingActionButton: authProvider.userData.kyc != '1'
                    ? buildKYCButton(dashBoardProvider)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget buildPlatinumMemberLogo(DashBoardProvider dashBoardProvider) {
    return authProvider.userData.anualMembership == 1
        ? Column(
            children: [
              height5(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // color: Colors.red,
                    width: Get.width / 2.5,
                    height: 50,
                    child: buildCachedNetworkImage(
                        dashBoardProvider.platinumMemberImage ?? '',
                        pw: Get.width / 2.5,
                        ph: 50,
                        fit: BoxFit.contain,
                        placeholderImg: Assets.appWebLogoWhite,
                        cacheFileName: 'platinum_member_image'),
                  ),
                ],
              ),
            ],
          )
        : Container();
  }

  void showDashboardInitialPopUp(
      DashBoardProvider dashBoardProvider, BuildContext context) {
    /*   errorLog(
        '--------- ${dashBoardProvider.companyInfo!.popupImg} ${dashBoardProvider.companyInfo!.popupImage}');
    errorLog(
        '--------- ${(dashBoardProvider.companyInfo?.popupImage != '' && dashBoardProvider.companyInfo?.popupImage != null && dashBoardProvider.companyInfo?.popupImg != '1')}');
    errorLog(
        'images are ---${dashBoardProvider.companyInfo!.popupImage!.map((e) => (dashBoardProvider.companyInfo!.popup_url ?? "") + (e['file_name'] ?? '')).toList()}');
*/
    if (canShowNextDashPopUPBool.value == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (dashBoardProvider.companyInfo?.popupImage != '' &&
            dashBoardProvider.companyInfo?.popupImage != null &&
            dashBoardProvider.companyInfo?.popupImg != '0') {
          canShowNextDashPopUPBool.value = true;
          /* dashboardDialog(
              image:
                  // 'https://mycarclub.com/assets/images/ticket-img/international-conventional-egypt-2023-usd.jpg',
                  dashBoardProvider.companyInfo!.popupImage!,
              context: context);*/
          errorLog(
              'images are ---${dashBoardProvider.companyInfo!.popupImage!.map((e) => (dashBoardProvider.companyInfo!.popup_url ?? "") + (e['file_name'] ?? '')).toList()}');
          var images = dashBoardProvider.companyInfo!.popupImage!
              .map((e) =>
                  (dashBoardProvider.companyInfo!.popup_url ?? "") +
                  (e['file_name'] ?? ''))
              .toList();
          // images=[...images,...images,...images];
          showDialog<void>(
            context: context,
            // barrierColor: Colors.black.withOpacity(0.4),
            barrierDismissible: false,
            useRootNavigator: false,
            builder: (BuildContext dialogContext) {
              return GalleryDetailsImagePopup(
                  currentIndex: 0, images: images, showCancel: true);
            },
          );
          canShowNextDashPopUPBool.value = true;
        }
      });
    }
  }

  FloatingActionButton buildKYCButton(DashBoardProvider dashBoardProvider) {
    return FloatingActionButton.extended(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: appLogoColor),
          borderRadius: BorderRadius.circular(30)),
      onPressed: () => launchTheLink(dashBoardProvider.kycUrl ?? ''),
      label: Text(
        'Verify KYC',
        style: TextStyle(color: appLogoColor),
      ),
    );
  }

  PreferredSize buildAppLogo(DashBoardProvider dashBoardProvider) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Column(
        children: [
          SizedBox(height: 10),
          Container(
              width: Get.width * 0.6,
              child: CachedNetworkImage(
                  imageUrl: dashBoardProvider.logoUrl ?? '',
                  placeholder: (context, url) => SizedBox(
                      height: 70,
                      width: 50,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Colors.transparent))),
                  errorWidget: (context, url, error) => SizedBox(
                      height: 70, child: assetImages(Assets.appWebLogoWhite)),
                  cacheManager: CacheManager(Config(
                    "${AppConstants.appID}_app_dash_logo",
                    stalePeriod: const Duration(days: 30),
                  )))),
        ],
      ),
    );
  }

  Positioned buildDrawerMenuButton(DashBoardProvider dashBoardProvider) {
    return Positioned(
      top: kToolbarHeight / 2 + 35,
      left: 16,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => widget.dashScaffoldKey.currentState?.openDrawer(),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  gradient: buildButtonGradient(), shape: BoxShape.circle),
              child: Center(
                child: assetSvg(Assets.squareMenu, color: Colors.white),
              ),
            ),
          ),
          if (Provider.of<NotificationProvider>(context, listen: true)
                  .totalUnread >
              0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                decoration:
                    BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                width: 8,
                height: 8,
              ),
            ),
        ],
      ),
    );
  }

  Positioned buildSQRCodeContainer(DashBoardProvider dashBoardProvider) {
    return Positioned(
      top: kToolbarHeight / 2 + 35,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: GestureDetector(
          onTap: () {
            Dialog QRCodeDialog = Dialog(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white
                          // color: Color(appLogoColor.value).withOpacity(01),
                          ),
                      padding: EdgeInsets.all(10),
                      child: Hero(
                        tag: 'qr_code',
                        child: buildQRCodeContainer(
                          dashBoardProvider,
                          showLogo: true,
                          dataModuleShape: QrDataModuleShape.circle,
                          size: Size(200, 200),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
            showDialog(context: context, builder: (_) => QRCodeDialog);
          },
          child: Hero(
            tag: 'qr_code',
            child: buildQRCodeContainer(dashBoardProvider,
                size: Size(40, 40), logoS: Size(10, 10)),
          ),
        ),
      ),
    );
  }

  Positioned buildDashboardAppLogo(DashBoardProvider dashBoardProvider) {
    return Positioned(
      top: kToolbarHeight / 2 + 16,
      right: 0,
      left: 0,
      child: Container(
        height: 50,
        width: Get.width * 0.7,
        decoration: const BoxDecoration(color: mainColor),
        child: Center(
          child: Image.file(File(dashBoardProvider.appLogoFilePath!)),
        ),
      ),
    );
  }

  Positioned buildUserIdTile(AuthProvider authProvider, BuildContext context) {
    var id = authProvider.userData.customerId ?? '';
    return Positioned(
      top: kToolbarHeight / 2 + 16,
      right: 16,
      child: GestureDetector(
        onDoubleTap: () async => Clipboard.setData(ClipboardData(text: id))
          ..then((_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Id copied  to clipboard.'),
              ))),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 10),
          // width: 40,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: bodyMedText(id, context,
                color: mainColor,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget buildCommissionActivity(
      BuildContext context, Size size, DashBoardProvider dashBoardProvider) {
    return !dashBoardProvider.loadingDash &&
            dashBoardProvider.activities.isNotEmpty
        ? Column(
            children: [
              height30(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UiCategoryTitleContainer(
                      child: bodyLargeText('COMMISSION ACTIVITY', context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(CommissionActivityDetailsPage(
                            activities: dashBoardProvider.activities));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            bodyMedText(
                              'View All',
                              context,
                            ),
                            Icon(Icons.keyboard_arrow_right_rounded,
                                color: Colors.white)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              height20(),
              Card(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white24,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: CommissionActivityHistoryList(
                      activities:
                          getFirstFourElements(dashboardProvider.activities))),
              /*Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: size.height *
                        0.09 *
                        (dashBoardProvider.activities.length < 4
                            ? dashBoardProvider.activities.length
                            : 4) +
                    36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: dashBoardProvider.activities.length > 4
                          ? 4
                          : dashBoardProvider.activities.length,
                      itemBuilder: (context, i) {
                        var activity = dashBoardProvider.activities[i];
                        bool isLast = (dashBoardProvider.activities.length > 4
                                ? i < 3
                                : (dashBoardProvider.activities.length - 1) <
                                    3) &&
                            (dashBoardProvider.activities.length - 1 != i);
                        return SizedBox(
                          height: size.height * 0.09,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  !dashBoardProvider.loadingDash
                                      ? Container(
                                          width: 45,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color:
                                                appLogoColor.withOpacity(0.2),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: capText(
                                                    '${DateFormat('MMM dd yyyy').format(DateTime.parse(activity.createdAt ?? ''))}',
                                                    context,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Skeleton(
                                          width: 45,
                                          height: 45,
                                          style: SkeletonStyle.circle,
                                          textColor: Colors.white70,
                                        ),
                                  if (isLast)
                                    Expanded(
                                      child: LayoutBuilder(
                                          builder: (context, constraints) {
                                        var dh = 3.0;
                                        var dg = 1.0;
                                        var count =
                                            constraints.maxHeight ~/ (dh + dg);

                                        return Column(
                                          children: [
                                            for (int i = 0; i < count; i++)
                                              Container(
                                                height: dh,
                                                width: 3,
                                                color: i % 2 == 0
                                                    ? Colors.transparent
                                                    : Colors.red,
                                              ),
                                          ],
                                        );
                                      }),
                                    ),
                                ],
                              ),
                              width10(),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    dashBoardProvider.loadingDash
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Skeleton(
                                                height: 15,
                                                textColor: Colors.white70,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              height5(),
                                              Skeleton(
                                                height: 15,
                                                width: 100,
                                                textColor: Colors.white70,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ],
                                          )
                                        : Expanded(
                                            child: bodyLargeText(
                                              parseHtmlString(
                                                  activity.note ?? ''),
                                              context,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.normal,
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                    height20(),
                                  ],
                                ),
                              ),
                              width10(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  dashBoardProvider.loadingDash
                                      ? Skeleton(
                                          height: 20,
                                          width: 50,
                                          textColor: Colors.white70,
                                          style: SkeletonStyle.box,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        )
                                      : Builder(builder: (context) {
                                          bool credited = double.parse(
                                                  activity.credit ?? '0') >
                                              double.parse(
                                                  activity.debit ?? '0');
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: credited
                                                  ? Colors.green[500]
                                                  : Colors.red[500]!,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            child: bodyMedText(
                                              credited ? 'Credit' : 'Debit',
                                              context,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        }),
                                  height10(),
                                  capText(
                                    '${DateFormat().add_jm().format(DateTime.parse(activity.createdAt ?? ''))}',
                                    context,
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ),*/
            ],
          )
        : SizedBox();
  }

  Column buildSubscriptionHistory(
      BuildContext context, Size size, DashBoardProvider dashBoardProvider) {
    String currency_icon = sl.get<AuthProvider>().userData.currency_icon ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiCategoryTitleContainer(
            child: bodyLargeText('SUBSCRIPTION HISTORY', context)),
        SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (!dashBoardProvider.loadingDash &&
                        !dashBoardProvider.hasSubscription)
                    ? Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            bodyLargeText(
                                "You don't have any subscription yet.", context,
                                color: appLogoColor,
                                useGradient: false,
                                fontSize: 17,
                                textAlign: TextAlign.center),
                            GestureDetector(
                              onTap: () => Get.to(SubscriptionPage()),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: appLogoColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: bodyMedText(
                                  'Add Subscriptions',
                                  context,
                                  color: Colors.white,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        children: [
                          if (!dashBoardProvider.loadingDash &&
                              dashBoardProvider.hasSubscription)
                            ...dashBoardProvider.subscriptionPacks
                                .map((pack) => Container(
                                      width: size.width * 0.4,
                                      margin: EdgeInsets.only(
                                          right: pack != 4 ? 10 : 0),
                                      child: Container(
                                        width: size.width * 0.5,
                                        margin: EdgeInsets.only(
                                            top: size.height * 0.02),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          // gradient: LinearGradient(
                                          //     colors: [
                                          //       pack.status == '1'
                                          //           ? appLogoColor
                                          //           : Colors.white,
                                          //       Colors.blue[100]!,
                                          //       Colors.white.withOpacity(0.5),
                                          //     ],
                                          //     begin: Alignment.topLeft,
                                          //     end: Alignment.bottomRight),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(100),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                spreadRadius: 5,
                                                blurRadius: 5)
                                          ],
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: appLogoColor
                                                    .withOpacity(0.7),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    spreadRadius: 5,
                                                    blurRadius: 15,
                                                  )
                                                ],
                                              ),
                                              padding: EdgeInsets.all(10),
                                              child: titleLargeText(
                                                  '$currency_icon${pack.payableAmt ?? ''}',
                                                  context,
                                                  color: Colors.white,
                                                  useGradient: false),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                titleLargeText(
                                                    pack.packageName ?? '',
                                                    context,
                                                    color: Colors.black,
                                                    textAlign: TextAlign.center,
                                                    useGradient: false),
                                                height5(),
                                                bodyLargeText(
                                                    pack.paymentType ?? '',
                                                    context,
                                                    color: Colors.black,
                                                    textAlign: TextAlign.center,
                                                    useGradient: false),
                                              ],
                                            ),
                                            capText(
                                                '${DateFormat().add_yMMMEd().add_jm().format(DateTime.parse(pack.createdAt ?? ''))}',
                                                context,
                                                color: Colors.black,
                                                textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          if (dashBoardProvider.loadingDash)
                            ...[1, 2, 3, 4].map(
                              (e) => Container(
                                width: size.width * 0.8,
                                margin: EdgeInsets.only(right: e != 4 ? 10 : 0),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: size.height * 0.07),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Skeleton(
                                          width: size.width * 0.8,
                                          textColor: Colors.white70,
                                          height: double.maxFinite,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: size.height * 0.02,
                                      left: 0,
                                      right: 0,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: size.height * 0.1,
                                          width: size.width * 0.3,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black,
                                                    spreadRadius: 0,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 0))
                                              ]),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Container buildSubscriptionStatusBar(
      BuildContext context, DashBoardProvider dashBoardProvider) {
    return (dashBoardProvider.loadingDash || dashBoardProvider.subscriptionVal)
        ? Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(left: 8, right: 8, top: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white10),
            child: !dashBoardProvider.loadingDash
                ? Column(
                    children: [
                      if (dashBoardProvider.subscriptionVal)
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: bodyLargeText(
                                    'Your Monthly package will be expired after ${dashBoardProvider.sub_expire_days} Day, please upgrade subscription',
                                    context,
                                  ),
                                ),
                              ],
                            ),
                            height10(),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FAProgressBar(
                                    currentValue:
                                        dashBoardProvider.subs_per.toDouble(),
                                    size: 20,
                                    maxValue: 100,
                                    changeColorValue: 100,
                                    changeProgressColor: appLogoColor,
                                    backgroundColor: Colors.white30,
                                    progressColor: appLogoColor,
                                    animatedDuration:
                                        const Duration(milliseconds: 300),
                                    direction: Axis.horizontal,
                                    verticalDirection: VerticalDirection.down,
                                    displayText: '',
                                    formatValueFixed: 1,
                                    displayTextStyle: TextStyle(
                                        fontSize: 0, color: Colors.white),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      capText(
                                          '${dashBoardProvider.subs_per.toDouble().toStringAsFixed(1)} %',
                                          context),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(
                          height: 10,
                          width: double.maxFinite,
                          textColor: Colors.white70,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height10(),
                        Skeleton(
                          height: 10,
                          width: Get.width * 0.3,
                          textColor: Colors.white70,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height10(),
                        Skeleton(
                          height: 20,
                          width: double.maxFinite,
                          textColor: appLogoColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ),
          )
        : Container();
  }

  Container buildQRCodeContainer(DashBoardProvider dashBoardProvider,
      {Size? size,
      Size? logoS,
      bool showLogo = true,
      QrDataModuleShape dataModuleShape = QrDataModuleShape.circle,
      Color? color}) {
    return Container(
      height: size?.height,
      width: size?.width,
      padding: size != null ? null : const EdgeInsets.symmetric(horizontal: 50),
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: !dashBoardProvider.loadingDash ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 3000),
            curve: Curves.fastOutSlowIn,
            child: QrImage(
              data: dashBoardProvider.promotionString,
              version: QrVersions.auto,
              gapless: false,
              foregroundColor: color ?? Colors.white,
              padding: EdgeInsets.zero,
              // embeddedImage:
              //     assetImageProvider(Assets.appLogo_S, fit: BoxFit.contain),
              // embeddedImageStyle: QrEmbeddedImageStyle(size: Size(40, 40)),
              dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: dataModuleShape, color: Colors.red),
            ),
          ),
          if (dashBoardProvider.loadingDash)
            Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                    opacity: dashBoardProvider.loadingDash ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 3000),
                    curve: Curves.fastOutSlowIn,
                    child: Skeleton(textColor: Colors.white38))),
          if (!dashBoardProvider.loadingDash && showLogo)
            Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: !dashBoardProvider.loadingDash ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 3000),
                  curve: Curves.fastOutSlowIn,
                  child: Center(
                    child: Container(
                        width: logoS?.width ?? 40,
                        height: logoS?.height ?? 40,
                        padding: logoS == null ? EdgeInsets.all(5) : null,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child:
                            assetImages(Assets.appLogo_S, fit: BoxFit.contain)),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIdField(
      BuildContext context, DashBoardProvider dashBoardProvider) {
    return MainPagePlacementIdWidget();
  }

  Widget _buildTeamBuildingReferralLink(
      BuildContext context, DashBoardProvider dashBoardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UiCategoryTitleContainer(
                child: bodyLargeText('Direct Referral Link', context)),
            width5(),
            GestureDetector(
                onTap: dashBoardProvider.loadingDash
                    ? null
                    : () => Share.share(createDeepLink(
                        sponsor: authProvider.userData.username)),
                child: SizedBox(
                    width: 30,
                    height: 30,
                    child: assetSvg(Assets.share, color: Colors.white))),
          ],
        ),
        height10(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: [
                      Expanded(
                        child: dashBoardProvider.loadingDash
                            ? Skeleton(
                                height: 16,
                                style: SkeletonStyle.text,
                                textColor: Colors.white38)
                            : capText(
                                dashBoardProvider.teamBuildingUrl,
                                context,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.white,
                                maxLines: 1,
                              ),
                      ),
                      IconButton(
                        onPressed: dashBoardProvider.loadingDash
                            ? null
                            : () async => await Clipboard.setData(ClipboardData(
                                    text: dashBoardProvider.teamBuildingUrl))
                                .then((_) => Toasts.showFToast(
                                    context, 'Link copied to clipboard.',
                                    icon: Icons.copy,
                                    bgColor: appLogoColor.withOpacity(0.9))),
                        icon: Icon(Icons.copy, color: Colors.white, size: 15),
                      )
                    ],
                  ),
                ),
              ),
              width10(),
              GestureDetector(
                  onTap: dashBoardProvider.loadingDash
                      ? null
                      : () =>
                          sendWhatsapp(text: dashBoardProvider.teamBuildingUrl),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: assetSvg(Assets.whatsappColored, fit: BoxFit.cover),
                  )),
              width10(),
              GestureDetector(
                  onTap: dashBoardProvider.loadingDash
                      ? null
                      : () =>
                          sendTelegram(text: dashBoardProvider.teamBuildingUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Container(
                      width: 40,
                      height: 40,
                      child:
                          assetSvg(Assets.telegramColored, fit: BoxFit.cover),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  buildTiers(BuildContext context, DashBoardProvider dashBoardProvider) {
    final List<double> data = [10, 15, 7, 20, 12];
    return [
      ...dashBoardProvider.customerReward.map((e) {
        int rId = int.parse(e.id ?? '0');
        int pair = int.parse(e.pair ?? '0');
        int sumPair = int.parse(e.sumPair ?? '0');
        int members = 0;
        bool completed = false;
        bool active = false;
        bool notCompleted = false;
        if (rId == 1) {
          if (dashboardProvider.get_active_member1 > sumPair) {
            completed = true;
            members = pair;
          } else {
            if (dashboardProvider.get_active_member1 < sumPair &&
                dashboardProvider.get_active_member1 >= (sumPair - pair)) {
              active = true;
              members = dashboardProvider.get_active_member1 - (sumPair - pair);
            }
          }
        } else if (rId == 2) {
          if (dashboardProvider.get_active_member2 > sumPair) {
            completed = true;
            members = pair;
          } else {
            if (dashboardProvider.get_active_member2 < sumPair &&
                dashboardProvider.get_active_member2 >= (sumPair - pair)) {
              active = true;
              members = dashboardProvider.get_active_member2 - (sumPair - pair);
            }
          }
        } else {
          if (dashboardProvider.get_active_member3 > sumPair) {
            completed = true;
            members = pair;
          } else {
            if (dashboardProvider.get_active_member3 < sumPair &&
                dashboardProvider.get_active_member3 >= (sumPair - pair)) {
              active = true;
              members = dashboardProvider.get_active_member3 - (sumPair - pair);
            }
          }
        }
        double per = ((members / pair) * 100);
        return active || completed
            ? DashBoardCustomerRewardTile(
                customerReward: e,
                completed: completed,
                active: active,
                sumPair: sumPair,
                members: members,
                per: per,
                data: data)
            : Container();
      })
    ];
  }

  buildTargetProgressCards(DashBoardProvider dashBoardProvider) {
    return [
      ...[
        [
          dashBoardProvider.achievedReward != null
              ? dashBoardProvider.achievedReward!.image
              : 'https://mycarclub.com/assets/customer-panel/img/reward/not-achieved.png',
          'Achieved',
          dashBoardProvider.hasRewardsAchieved,
        ],
        [
          dashBoardProvider.nextReward != null
              ? dashBoardProvider.nextReward!.image
              : '',
          'Next Target',
          dashBoardProvider.hasNextReward,
        ],
      ].map(
        (e) => MainPageRewardImageCard(
            url: e[0].toString(),
            title: e[1].toString(),
            dashBoardProvider: dashBoardProvider,
            show: e[2] as bool),
      ),
    ];
  }

  buildCardFeatureListview(
      BuildContext context, Size size, DashBoardProvider dashBoardProvider) {
    return Container(
      height: size.height * 0.3,
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiCategoryTitleContainer(
              child: bodyLargeText('Buy Credit Cards'.toUpperCase(), context)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              children: [
                if (!dashboardProvider.loadingDash)
                  ...dashboardProvider.cards.map(
                    (card) => buildMainPageCardImageWidget(
                        context, size, dashBoardProvider, card),
                  ),
              ],
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }

  buildMainPageCardImageWidget(BuildContext context, Size size,
      DashBoardProvider dashBoardProvider, Map<String, dynamic> card) {
    final size = MediaQuery.of(context).size;
    double offset = 2;
    return GestureDetector(
      onTap: () => Get.to(CreditCardPurchaseScreen(card: card)),
      child: Stack(
        children: [
          Container(
            width: size.width * 0.8,
            margin: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: buildCachedNetworkImage(
                card['image'],
                pw: size.width * 0.8,
                ph: double.maxFinite,
                errorBgColor: Colors.white70,
                placeholderBgColor: Colors.white70,
                errorStackChild: Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        bodyLargeText(
                          card['name'],
                          context,
                          color: Colors.white,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: <Shadow>[
                              Shadow(
                                  offset: Offset(offset, offset),
                                  blurRadius: 8.0,
                                  color: Color.fromARGB(0, 0, 0, 0)),
                              Shadow(
                                  offset: Offset(offset, offset),
                                  blurRadius: 10.0,
                                  color: appLogoColor),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ),
          Positioned(
              right: card['name'] == 'Visa Card' ? null : 40,
              left: card['name'] == 'Visa Card' ? 30 : null,
              bottom: card['name'] == 'Visa Card' ? 5 : null,
              top: card['name'] == 'Visa Card' ? null : 60,
              child: titleLargeText(card['c_name'], context,
                  textAlign: TextAlign.start)),
          if (card['qr_code'] != null)
            Positioned(
                left: 30,
                bottom: 60,
                child: SizedBox(
                    height: 60,
                    width: 60,
                    child: buildCachedNetworkImage(card['qr_code'])))
        ],
      ),
    );
  }
}

class UiCategoryTitleContainer extends StatelessWidget {
  const UiCategoryTitleContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bound) {
      return Stack(
        children: [
          Container(
              height: 40,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    Colors.white12,
                    Colors.transparent
                  ],
                      stops: [
                    0.2,
                    1
                  ], // Add color stops (0.2 = 20% of the container, 1.0 = 100% of the container)
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [child])),
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
                color: appLogoColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                )),
          ),
        ],
      );
    });
  }
}

class MainPagePlacementIdWidget extends StatefulWidget {
  const MainPagePlacementIdWidget({
    super.key,
  });

  @override
  State<MainPagePlacementIdWidget> createState() =>
      _MainPagePlacementIdWidgetState();
}

class _MainPagePlacementIdWidgetState extends State<MainPagePlacementIdWidget> {
  FocusNode _focusNode = FocusNode();
  var dashboardProvider = sl.get<DashBoardProvider>();
  var authProvider = sl.get<AuthProvider>();
  @override
  void initState() {
    dashboardProvider.placementIdController.text =
        dashboardProvider.placementUrl;
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UiCategoryTitleContainer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bodyLargeText(
                      provider.editingMode
                          ? 'Change Placement ID'
                          : 'Placement Link',
                      context),
                  width5(),
                  GestureDetector(
                      onTap: dashboardProvider.loadingDash
                          ? null
                          : () => Share.share(createDeepLink(
                              sponsor: authProvider.userData.username,
                              placement:
                                  authProvider.userData.placementUsername)),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: assetSvg(Assets.share, color: Colors.white))),
                ],
              ),
            ),
            height10(),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    enabled: (provider.submittingPlacementId ==
                            ButtonLoadingState.idle ||
                        provider.submittingPlacementId ==
                            ButtonLoadingState.failed),
                    readOnly: !provider.editingMode,
                    controller: provider.placementIdController,
                    focusNode: _focusNode,
                    style: GoogleFonts.ubuntu(
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                color: provider.editingMode
                                    ? Colors.white
                                    : Colors.white)),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      filled: false,
                      hintText: 'Enter Placement ID',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white54, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      suffixIcon: IconButton(
                        onPressed: () async => await Clipboard.setData(
                                ClipboardData(text: provider.placementUrl))
                            .then((_) => Toasts.showFToast(
                                context, 'Link copied to clipboard.',
                                icon: Icons.copy,
                                bgColor: appLogoColor.withOpacity(0.9))),
                        icon: Icon(
                          Icons.copy,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        provider.changed =
                            sl.get<AuthProvider>().userData.placementUsername !=
                                provider.placementIdController.text;
                      });
                    },
                  )),
                  if (provider.editingMode)
                    FloatingActionButton(
                      backgroundColor:
                          provider.changed ? Colors.white : Colors.white70,
                      onPressed: provider.submittingPlacementId !=
                              ButtonLoadingState.loading
                          // &&
                          //     provider.changed
                          ? () {
                              provider.changePlacement();
                            }
                          : null,
                      child: provider.submittingPlacementId ==
                              ButtonLoadingState.loading
                          ? SizedBox(
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CircularProgressIndicator(
                                    color: Colors.blue),
                              ),
                            )
                          : provider.submittingPlacementId ==
                                  ButtonLoadingState.failed
                              ? Icon(Icons.report_gmailerrorred_rounded,
                                  color: Colors.red)
                              : provider.submittingPlacementId ==
                                      ButtonLoadingState.completed
                                  ? Icon(Icons.file_download_done,
                                      color: Colors.green)
                                  : Icon(Icons.done, color: Colors.blueAccent),
                    ),
                  Row(
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () {
                          toggleEditingMode(provider);
                        },
                        child: provider.editingMode
                            ? Icon(Icons.clear, color: Colors.red)
                            : Icon(Icons.edit, color: Colors.blue),
                      ),
                    ],
                  ),
                  if (!provider.editingMode && provider.placementUrl.isNotEmpty)
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              sendWhatsapp(
                                text: provider.placementUrl,
                              );
                            },
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: assetSvg(Assets.whatsappColored,
                                  fit: BoxFit.cover),
                            )),
                        width10(),
                        GestureDetector(
                            onTap: () {
                              // print('this is telegram');
                              sendTelegram(
                                text: provider.placementUrl,
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: assetSvg(Assets.telegramColored,
                                    fit: BoxFit.cover),
                              ),
                            )),
                      ],
                    )
                ],
              ),
            ),
            if (!provider.editingMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    height5(),
                    Row(
                      children: [
                        capText(
                          'Placement Id:',
                          context,
                          style: GoogleFonts.ubuntu(
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Colors.white70, fontSize: 12)),
                        ),
                        width10(),
                        Expanded(
                          child: capText(
                            authProvider.userData.placementUsername ?? '',
                            context,
                            style: GoogleFonts.ubuntu(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (provider.editingMode && provider.errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    height5(),
                    capText(provider.errorText, context,
                        color: provider.submittingPlacementId ==
                                ButtonLoadingState.completed
                            ? Colors.green
                            : Colors.red),
                  ],
                ),
              )
          ],
        );
      },
    );
  }

  toggleEditingMode(DashBoardProvider provider) {
    setState(() {
      provider.submittingPlacementId = ButtonLoadingState.idle;
      provider.errorText = '';
      provider.editingMode = !provider.editingMode;
      if (provider.editingMode) {
        provider.changed = false;
        provider.placementIdController.text =
            sl.get<AuthProvider>().userData.placementUsername ?? '';
      } else {
        provider.placementIdController.text = provider.placementUrl;
      }
    });
  }
}

class DashBoardCustomerRewardTile extends StatefulWidget {
  const DashBoardCustomerRewardTile({
    super.key,
    required this.completed,
    required this.active,
    required this.sumPair,
    required this.members,
    required this.per,
    required this.data,
    required this.customerReward,
  });

  final bool completed;
  final CustomerReward customerReward;
  final bool active;
  final int sumPair;
  final int members;
  final double per;
  final List<double> data;

  @override
  State<DashBoardCustomerRewardTile> createState() =>
      _DashBoardCustomerRewardTileState();
}

class _DashBoardCustomerRewardTileState
    extends State<DashBoardCustomerRewardTile> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    print(
        '${widget.completed} ${widget.active} ${widget.sumPair} ${widget.members}');
    return Consumer<DashBoardProvider>(
      builder: (context, dashBoardProvider, child) {
        return GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Card(
            elevation: 10,
            color: widget.completed
                ? Colors.greenAccent.withOpacity(0.1)
                : widget.active
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dashBoardProvider.loadingDash
                      ? Skeleton(
                          textColor: Colors.white70,
                          height: 15,
                          width: 120,
                          borderRadius: BorderRadius.circular(3),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            bodyLargeText(
                                '${widget.customerReward.name}', context),
                          ],
                        ),
                  height20(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          capText(
                              'Active Member: ${!dashBoardProvider.loadingDash ? (widget.completed ? widget.sumPair :
                                  // widget.active ? dashBoardProvider.get_active_member :
                                  widget.members) : ''}',
                              context),
                          if (dashBoardProvider.loadingDash)
                            Skeleton(
                              height: 10,
                              width: 20,
                              textColor: Colors.white70,
                              borderRadius: BorderRadius.circular(1),
                            )
                        ],
                      ),
                      Row(
                        children: [
                          capText(
                              'Target Member:  ${!dashBoardProvider.loadingDash ? widget.customerReward.sumPair ?? '' : ''}',
                              context),
                          if (dashBoardProvider.loadingDash)
                            Skeleton(
                              height: 10,
                              width: 20,
                              textColor: Colors.white70,
                              borderRadius: BorderRadius.circular(1),
                            )
                        ],
                      ),
                    ],
                  ),
                  height5(),
                  SizedBox(
                    height: 20,
                    child: dashBoardProvider.loadingDash
                        ? Skeleton(
                            textColor: appLogoColor.withOpacity(0.4),
                            width: double.maxFinite,
                            borderRadius: BorderRadius.circular(5))
                        : LiquidLinearProgressIndicator(
                            value: widget.per >= 100
                                ? widget.per
                                : widget.per / 100,
                            valueColor: AlwaysStoppedAnimation(widget.completed
                                ? Colors.greenAccent.withOpacity(0.7)
                                : widget.active
                                    ? appLogoColor.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.2)),
                            backgroundColor: Colors.white38,
                            borderColor: Colors.white38,
                            borderWidth: 0.0,
                            borderRadius: 5.0,
                            direction: Axis.horizontal,
                            center: capText(
                                "${widget.per.toStringAsFixed(1)}%", context),
                          ),
                  ),
                  Visibility(
                    visible: expanded &&
                        dashBoardProvider.get_active_Leg.isNotEmpty &&
                        (widget.completed || widget.active),
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 200,
                      // child: BarChartRace(data: widget.data),
                      child: BarChartWidget(
                        legs: dashBoardProvider.get_active_Leg,
                        customerReward: widget.customerReward,
                        color: widget.completed
                            ? Colors.greenAccent
                            : appLogoColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BarChartWidget extends StatefulWidget {
  const BarChartWidget(
      {Key? key,
      required this.legs,
      required this.customerReward,
      required this.color})
      : super(key: key);
  final List<GetActiveLegModel> legs;
  final CustomerReward customerReward;
  final Color color;

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  late List<GetActiveLegModel> _chartData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _chartData = widget.legs;
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int condition = int.parse(widget.customerReward.requireCondition ?? '0');
    return SfCartesianChart(
      tooltipBehavior: _tooltipBehavior,
      series: <ChartSeries>[
        BarSeries<GetActiveLegModel, String>(
          name: widget.customerReward.name ?? '',
          dataSource: _chartData,
          xValueMapper: (GetActiveLegModel gal, index) => gal.username,
          yValueMapper: (GetActiveLegModel gal, _) {
            int members = int.parse(gal.activeMember ?? '0');
            return members > condition ? condition : members;
          },
          color: widget.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: Colors.white, fontSize: 12),
            angle: 0,
          ),
          enableTooltip: true,
          isVisible: true,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(3),
            bottomRight: Radius.circular(3),
          ),
        )
      ],
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: 'Legs',
          textStyle: TextStyle(color: Colors.white, fontSize: 9),
        ),
        labelStyle: TextStyle(color: Colors.white, fontSize: 0),
        isVisible: false,
        labelRotation: 45,
        interval: 1,
        majorGridLines: MajorGridLines(color: Colors.transparent),
        minorGridLines: MinorGridLines(color: Colors.transparent),
        axisLine: AxisLine(width: 0, color: Colors.transparent),
      ),
      primaryYAxis: NumericAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        labelStyle: TextStyle(color: Colors.white),
        majorGridLines: MajorGridLines(color: Colors.transparent),
        minorGridLines: MinorGridLines(color: Colors.transparent),
        axisLine: AxisLine(width: 0, color: Colors.transparent),
      ),
      isTransposed: true,
    );
  }
}

class MainPageRewardImageCard extends StatelessWidget {
  const MainPageRewardImageCard({
    super.key,
    required this.url,
    required this.title,
    required this.dashBoardProvider,
    required this.show,
  });

  final String url;
  final String title;
  final DashBoardProvider dashBoardProvider;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: !dashBoardProvider.loadingDash ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 3000),
          curve: Curves.fastOutSlowIn,
          child: Visibility(
            visible: dashBoardProvider.loadingDash ||
                (!dashBoardProvider.loadingDash && show) ||
                (!dashBoardProvider.loadingDash && title == 'Achieved'),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              height: 250,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: assetImageProvider('archived.gif'),
                    fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  height10(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(00.7),
                          offset: Offset(1, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  if (!dashBoardProvider.loadingDash)
                    Expanded(
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: url,
                          placeholder: (context, url) => SizedBox(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: appLogoColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              assetImages(Assets.noImage),
                          cacheManager: CacheManager(Config(
                              "${AppConstants.appID}_$title",
                              stalePeriod: const Duration(days: 7))),
                        ),
                        // child: Image.network(url),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: AnimatedOpacity(
                opacity: dashBoardProvider.loadingDash ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 3000),
                curve: Curves.fastOutSlowIn,
                child: Skeleton(
                  height: 250,
                  width: double.maxFinite,
                  textColor: Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationExample extends StatefulWidget {
  @override
  _NotificationExampleState createState() => _NotificationExampleState();
}

class _NotificationExampleState extends State<NotificationExample> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> showNotification(int id, String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id', // Replace with your channel ID
      'Channel name', // Replace with your channel name
      channelDescription:
          'Channel description', // Replace with your channel description
      importance: Importance.max,
      priority: Priority.high,
    );
/*
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);*/
    showCustomizedNotification('_title', '_body', 'payload', '_image',
        flutterLocalNotificationsPlugin);
    // await flutterLocalNotificationsPlugin.show(
    //   id,
    //   title,
    //   body,
    //   platformChannelSpecifics,
    //   payload: 'payload', // Replace with your payload data if needed
    //    // Use a unique threadIdentifier for each notification
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Generate multiple notifications with unique threadIdentifier
          for (int i = 1; i <= 5; i++) {
            showNotification(i, 'Notification $i', 'This is notification $i');
          }
        },
        child: Text('Show Notifications'),
      ),
    );
  }
}
