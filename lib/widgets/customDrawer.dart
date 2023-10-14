import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../screens/drawerPages/whats_new_page.dart';
import '/database/model/response/additional/mcc_content_models.dart';
import '../screens/drawerPages/downlines/my_incomes_page.dart';
import '../screens/drawerPages/downlines/team_view/fancy_team_view.dart';
import '../screens/drawerPages/wallets/withdraw_history_page.dart';
import '/screens/drawerPages/download_pages/edcational_downloads_page.dart';
import '../screens/dashboard/company_trade_ideas_page.dart';
import '../screens/drawerPages/downlines/matrix_analyzer .dart';
import '../screens/drawerPages/holding_tank_page.dart';
import '../screens/drawerPages/downlines/geration_member/direct_member_page.dart';
import '../screens/drawerPages/downlines/generation_analyzer.dart';
import '/utils/default_logger.dart';
import '../constants/app_constants.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/notification_provider.dart';
import '/screens/Notification/notification_page.dart';
import '/screens/auth/login_screen.dart';
import '/screens/dashboard/main_page.dart';
import '../screens/drawerPages/wallets/commission_wallet/commission_wallet_page.dart';
import '/screens/drawerPages/download_pages/gallery_main_page.dart';
import '../screens/drawerPages/download_pages/videos/drawer_videos_main_page.dart';
import '/screens/drawerPages/event_tickets/event_tickets_page.dart';
import '/screens/drawerPages/inbox/inbox_screen.dart';
import '/screens/drawerPages/pofile/profile_screen.dart';
import '/screens/drawerPages/subscription/subscription_page.dart';
import '/screens/drawerPages/support_pages/support_Page.dart';
import '../screens/drawerPages/downlines/team_view/my_tree_view.dart';
import '../screens/drawerPages/downlines/trem_member_page.dart';
import '/screens/drawerPages/voucher/voucher_page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/picture_utils.dart';
import '/utils/text.dart';
import '/widgets/scroll_to_top.dart';
import 'package:provider/provider.dart';

import '../screens/drawerPages/wallets/cash_wallet_page/cash_wallet_page.dart';
import '../screens/drawerPages/payment_methods_page.dart';
import '../screens/drawerPages/download_pages/drawer_video_player_page.dart';
import '../screens/drawerPages/settings_page.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final controller = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> drawerOtherItems = [
      ['Notifications', Assets.notification],
      ['Settings', Assets.settings],
      ['Support', Assets.support],
      ['Logout', Assets.logout],
    ];
    Size size = MediaQuery.of(context).size;
    String inbox = 'Inbox';
    String giftVoucher = 'Gift Voucher';
    String eventTicket = 'Event Ticket';
    String holdingTank = 'Holding Tank';
    String matrixAnalyzer = 'Matrix Analyzer';
    String whatsNew = 'What\'s New';
    return Container(
      color: Colors.blueGrey.shade900,
      height: double.maxFinite,
      width: size.width * 0.8,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Consumer<DashBoardProvider>(
            builder: (context, dashBoardProvider, child) {
              return Column(
                children: [
                  buildHeader(size, context, authProvider),
                  const Divider(color: Colors.white60, height: 0, thickness: 1),
                  // height10(),
                  Expanded(
                    child: ScrollToTop(
                      scrollController: controller,
                      child: SingleChildScrollView(
                        controller: controller,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildMasterClass(context),
                            height5(),
                            buildCompanyTradeIdea(context),
                            height5(),
                            capText('Components', context,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                            height10(),
                            //Inbox
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(inbox);
                                Widget page = const InboxScreen();
                                Get.to(page);
                              },
                              leading: Assets.inbox,
                              title: inbox,
                              width: size.width * 0.7,
                              selected:
                                  dashBoardProvider.selectedDrawerTile == inbox,
                            ),
                            height10(),
                            //holdingTank
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(holdingTank);
                                Widget page = const HoldingTankPage();
                                Get.to(page);
                              },
                              leading: Assets.creditCard,
                              title: holdingTank,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  holdingTank,
                            ),
                            height10(),

                            //downlines
                            buildDownlinesExpansionTile(
                                size, dashBoardProvider),
                            height10(),

                            //Matrix-Analyzer
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(matrixAnalyzer);
                                Widget page = const MatrixAnalyzerPage();
                                Get.to(page);
                              },
                              leading: Assets.analyzer,
                              title: matrixAnalyzer,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  matrixAnalyzer,
                            ),
                            height10(),

                            // Subscription
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile('Subscription');
                                Widget page = const SubscriptionPage();
                                Get.to(page);
                              },
                              leading: Assets.subscription,
                              title: 'Subscription',
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  'Subscription',
                            ),
                            height10(),

                            //Gift Voucher
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(giftVoucher);
                                Widget page = const GiftVoucherPage();
                                Get.to(page);
                              },
                              leading: Assets.gift,
                              title: giftVoucher,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  giftVoucher,
                            ),
                            height10(),

                            //Event Ticket
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(eventTicket);
                                Widget page = const EventTicketsPage();
                                Get.to(page);
                              },
                              leading: Assets.eventTicket,
                              title: eventTicket,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  eventTicket,
                            ),
                            height10(),
                            //Downloads
                            buildDownloadExpansionTile(size, dashBoardProvider),
                            height10(),

                            //Wallets
                            buildWalletsExpansionTile(size, dashBoardProvider),
                            height10(),

                            capText('User', context,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                            height10(),
                            buildProfileExpansionTile(size, dashBoardProvider),
                            height10(),

                            //Others
                            capText('Others', context,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                            height10(),
                            ...drawerOtherItems.map((e) => buildOthersTile(
                                e, context, size, dashBoardProvider)),

                            // whatsNew
                            DrawerTileItem(
                              onTap: () {
                                dashBoardProvider.setDrawerTile(whatsNew);
                                Widget page = const WhatsNewPage();
                                Get.to(page);
                              },
                              leading: Assets.pages,
                              title: whatsNew,
                              width: size.width * 0.7,
                              selected: dashBoardProvider.selectedDrawerTile ==
                                  whatsNew,
                              trailing: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: capText('New', context,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 7),
                              ),
                            ),
                            height10(),

                            buildAppPagesExpansionTile(
                                size, dashBoardProvider, authProvider),
                            height10(),
                            buildFooter(size, context, dashBoardProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  GestureDetector buildCompanyTradeIdea(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
        Get.to(CompanyTradeIdeasPage());
      },
      child: Row(
        children: [
          titleLargeText(
            'Company Trade Ideas',
            context,
            color: Colors.white70,
            useGradient: true,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
          width5(),
          assetLottie(Assets.tradingSignals, width: 50),
        ],
      ),
    );
  }

  Column buildMasterClass(BuildContext context) {
    double imageWidth = 30;
    double maxWidth = 100;
    double minWidth = 100;
    return Column(
      children: [
        Row(
          children: [
            assetImages(Assets.classPng, width: 20),
            width5(),
            bodyLargeText('Master Classes', context,
                color: Colors.white70, fontWeight: FontWeight.bold),
          ],
        ),
        height10(),
        Container(
          // height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              width20(),
              //
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.to(DrawerVideosMainPage());
                },
                child: Container(
                  constraints:
                      BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: appLogoColor.withOpacity(0.8)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      assetImages(Assets.videoPng, height: imageWidth),
                      height5(),
                      capText('Educational\nVideos', context,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
              ),
              //
              width10(),
              //
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.to(DowanloadsMainPage());
                },
                child: Container(
                  constraints:
                      BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: appLogoColor.withOpacity(0.8)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      assetImages(Assets.downloadsPng, height: imageWidth),
                      height5(),
                      capText('Educational Downloads', context,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column buildOthersTile(
    List<dynamic> e,
    BuildContext context,
    // AuthProvider authProvider,
    Size size,
    DashBoardProvider dashBoardProvider,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            DrawerTileItem(
              onTap: () {
                // HapticFeedback.vibrate();
                if (e[0] == 'Logout') {
                  AwesomeDialog(
                    dialogType: DialogType.question,
                    dismissOnBackKeyPress: false,
                    dismissOnTouchOutside: false,
                    title: 'Do you really want to logout?',
                    context: context,
                    btnCancelText: 'No',
                    btnOkText: 'Yes Sure!',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () async {
                      await logOut('log-out button')
                          .then((value) => Get.offAll(LoginScreen()));
                    },
                    reverseBtnOrder: true,
                  ).show();
                } else if (e[0] == 'Notifications') {
                  Get.to(NotificationPage());
                } else if (e[0] == 'Settings') {
                  Get.to(SettingsPage());
                } else if (e[0] == 'Support') {
                  Get.to(SupportPage());
                }
              },
              leading: e[1],
              title: e[0],
              width: size.width * 0.7,
              selected: dashBoardProvider.selectedDrawerTile == e[0],
            ),
            if (e[0] == 'Notifications' &&
                Provider.of<NotificationProvider>(context, listen: true)
                        .totalUnread >
                    0)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    child: capText(
                      '${Provider.of<NotificationProvider>(context, listen: true).totalUnread}',
                      context,
                    ),
                  ),
                ),
              ),
          ],
        ),
        height10(),
      ],
    );
  }

  Column buildComponentsTile(List<dynamic> e, BuildContext context, Size size,
      DashBoardProvider dashBoardProvider) {
    return Column(
      children: [
        DrawerTileItem(
          onTap: () {
            Widget page = const Scaffold();
            switch (e[0]) {
              case 'Inbox':
                page = const InboxScreen();
                break;

              case 'Gift Voucher':
                page = const GiftVoucherPage();
                break;
              case 'Event Ticket':
                page = const EventTicketsPage();
                break;
              default:
                page = Scaffold(
                    backgroundColor: mainColor,
                    body: Center(
                        child: bodyLargeText('This is Default Page', context,
                            color: Colors.white)));
                break;
            }
            Get.to(page);
          },
          leading: e[1],
          title: e[0],
          width: size.width * 0.7,
          selected: dashBoardProvider.selectedDrawerTile == e[0],
        ),
        height10(),
      ],
    );
  }

  Widget buildDownlinesExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String teamMemeber = 'Team Member';
    const String teamView = 'Team View';
    const String generationTreeView = 'Generation Tree View';
    const String generationAnalyzer = 'Generation Analyzer';
    const String directMember = 'Direct Member';
    const String inactiveAnalyzer = 'Inactive Member';

    return expansionTile(
      title: 'My Downlines',
      headerAsset: Assets.downline,
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == teamMemeber ||
          dashBoardProvider.selectedDrawerTile == teamView ||
          dashBoardProvider.selectedDrawerTile == generationTreeView ||
          dashBoardProvider.selectedDrawerTile == directMember ||
          dashBoardProvider.selectedDrawerTile == generationAnalyzer ||
          dashBoardProvider.selectedDrawerTile == inactiveAnalyzer,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Column(
            children: [
              ...[
                teamMemeber,
                directMember,
                teamView,
                generationTreeView,
                generationAnalyzer,
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = const Scaffold(backgroundColor: mainColor);
                      switch (e) {
                        case teamMemeber:
                          page = const TeamMemberPage();
                          break;
                        case teamView:
                          page = FancyTreeView();
                          break;
                        case generationTreeView:
                          page = MyTreeViewPage();
                          break;

                        case directMember:
                          page = DirectMembersPage();
                          break;
                        case generationAnalyzer:
                          page = const GenerationAnalyzerPage();
                          break;

                        case inactiveAnalyzer:

                        default:
                          page = buildDefaultPage();
                          break;
                      }
                      // Get.back();
                      Get.to(page);
                    },
                    leading: e == teamMemeber
                        ? Assets.teamMember
                        : e == teamView
                            ? Assets.teamView
                            : e == generationTreeView
                                ? Assets.downline
                                : e == directMember
                                    ? Assets.layer
                                    : e == generationAnalyzer
                                        ? Assets.layer
                                        : Assets.analyzer,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildWalletsExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String myIncomes = 'My Incomes';
    const String cashWallet = 'Cash Wallet';
    const String commissionWallet = 'Commission Wallet';
    const String withdrawals = 'Withdrawals';
    return expansionTile(
      title: 'Wallets',
      headerAsset: Assets.cashWallet,
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == cashWallet ||
          dashBoardProvider.selectedDrawerTile == commissionWallet ||
          dashBoardProvider.selectedDrawerTile == withdrawals ||
          dashBoardProvider.selectedDrawerTile == myIncomes,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: Column(
            children: [
              ...[myIncomes, cashWallet, commissionWallet, withdrawals].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = buildDefaultPage();
                      switch (e) {
                        case myIncomes:
                          page = const MyIncomesPage();
                          break;
                        case cashWallet:
                          page = CashWalletPage();
                          break;
                        case commissionWallet:
                          page = CommissionWalletPage();
                          break;
                        case withdrawals:
                          page = const WithdrawRequestHistoryPage();
                          break;

                        default:
                          page = Scaffold(
                            backgroundColor: mainColor,
                            body: Center(
                              child: bodyLargeText(
                                  'This is Default Page', context,
                                  color: Colors.white),
                            ),
                          );
                          break;
                      }
                      // Get.back();
                      Get.to(page);
                    },
                    leading: e == cashWallet
                        ? Assets.cashWallet
                        : e == commissionWallet
                            ? Assets.commissionWallet
                            : Assets.withdraw,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfileExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String profile = 'Profile';
    const String paymentMethods = 'Payment Methods';

    return expansionTile(
      headerAsset: Assets.personalInfo,
      title: 'Personal Information',
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == profile ||
          dashBoardProvider.selectedDrawerTile == paymentMethods,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              ...[profile, paymentMethods].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = const Scaffold(backgroundColor: mainColor);
                      switch (e) {
                        case profile:
                          page = ProfileScreen();
                          break;
                        case paymentMethods:
                          page = PaymentMethodsPage();
                          break;

                        default:
                          page = buildDefaultPage();
                          break;
                      }
                      Get.to(page);
                    },
                    leading: e == profile ? Assets.profile : Assets.bank,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAppPagesExpansionTile(Size size,
      DashBoardProvider dashBoardProvider, AuthProvider authProvider) {
    const String privacyPolicy = 'Privacy Policy';
    const String termsAndConditions = 'Terms & Conditions';
    const String cancellationPolicy = 'Cancellation Policy';
    const String returnPolicy = 'Return Policy';
    const String aboutUs = 'About Us';
    List<Cancellation> pages = authProvider.link_pages
        .where((element) =>
            element.headlines != null && element.headlines!.isNotEmpty)
        .toList();

    return expansionTile(
      title: 'App Pages',
      headerAsset: Assets.pages,
      initiallyExpanded:
          dashBoardProvider.selectedDrawerTile == privacyPolicy ||
              dashBoardProvider.selectedDrawerTile == termsAndConditions ||
              dashBoardProvider.selectedDrawerTile == cancellationPolicy ||
              dashBoardProvider.selectedDrawerTile == returnPolicy ||
              dashBoardProvider.selectedDrawerTile == aboutUs,
      children: [
        //Link pages
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(children: [
            ...pages.map((e) {
              var page = e;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: DrawerTileItem(
                  onTap: () async {
                    Get.to(HtmlPreviewPage(
                        title: e.headlines ?? '',
                        message: e.details ?? '',
                        file_url: ''));
                  },
                  leading: Assets.pages,
                  title: e.headlines ?? '',
                  width: size.width * 0.7,
                  selected: dashBoardProvider.selectedDrawerTile ==
                      (e.headlines ?? ''),
                  opacity: 0.7,
                ),
              );
            })
          ]),
        ),
        // one - one pages

/*
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              ...[
                privacyPolicy,
                termsAndConditions,
                cancellationPolicy,
                returnPolicy,
                aboutUs
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () async {
                      Widget page = buildDefaultPage();
                      // await future(1000);
                      if (e == privacyPolicy &&
                          authProvider.mwc_content.privacy != null) {
                        Get.to(HtmlPreviewPage(
                          title: parseHtmlString(
                              authProvider.mwc_content.privacy!.headlines ??
                                  ""),
                          message:
                              authProvider.mwc_content.privacy!.details ?? "",
                          file_url:
                              authProvider.mwc_content.privacy!.image ?? "",
                        ));
                      } else if (e == termsAndConditions &&
                          authProvider.mwc_content.termCondition != null) {
                        Get.to(HtmlPreviewPage(
                          title: parseHtmlString(authProvider
                                  .mwc_content.termCondition!.headlines ??
                              ""),
                          message:
                              authProvider.mwc_content.termCondition!.details ??
                                  "",
                          file_url:
                              authProvider.mwc_content.termCondition!.image ??
                                  "",
                        ));
                      } else if (e == cancellationPolicy &&
                          authProvider.mwc_content.cancellation != null) {
                        Get.to(HtmlPreviewPage(
                          title: parseHtmlString(authProvider
                                  .mwc_content.cancellation!.headlines ??
                              ""),
                          message:
                              authProvider.mwc_content.cancellation!.details ??
                                  "",
                          file_url:
                              authProvider.mwc_content.cancellation!.image ??
                                  "",
                        ));
                      } else if (e == returnPolicy &&
                          authProvider.mwc_content.returnPolicy != null) {
                        Get.to(HtmlPreviewPage(
                            title: parseHtmlString(authProvider
                                    .mwc_content.returnPolicy!.headlines ??
                                ""),
                            message: authProvider
                                    .mwc_content.returnPolicy!.details ??
                                "",
                            file_url:
                                authProvider.mwc_content.returnPolicy!.image ??
                                    ''));
                      } else if (e == aboutUs &&
                          authProvider.mwc_content.returnPolicy != null) {
                        Get.to(HtmlPreviewPage(
                            title: parseHtmlString(authProvider
                                    .mwc_content.returnPolicy!.headlines ??
                                ""),
                            message: aboutUsHtml,
                            file_url:
                                authProvider.mwc_content.returnPolicy!.image ??
                                    ''));
                      }
                    },
                    leading: e == privacyPolicy
                        ? Assets.privacyPolicy
                        : e == termsAndConditions
                            ? Assets.termsAndCondition
                            : e == cancellationPolicy
                                ? Assets.cancellationPolicy
                                : e == returnPolicy
                                    ? Assets.returnPolicy
                                    : Assets.aboutUs,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
  */
      ],
    );
  }

  Widget buildDownloadExpansionTile(
      Size size, DashBoardProvider dashBoardProvider) {
    const String pdf = 'PDF';
    const String ppt = 'PPT';
    const String promotionalVideo = 'Promotional Video';
    const String gallery = 'Gallery';
    const String academicVideos = 'Academic Videos';
    const String introVideo = 'Intro Video';

    return expansionTile(
      title: 'Downloads',
      headerAsset: Assets.download,
      initiallyExpanded: dashBoardProvider.selectedDrawerTile == pdf ||
          dashBoardProvider.selectedDrawerTile == ppt ||
          dashBoardProvider.selectedDrawerTile == promotionalVideo ||
          dashBoardProvider.selectedDrawerTile == gallery ||
          dashBoardProvider.selectedDrawerTile == academicVideos ||
          dashBoardProvider.selectedDrawerTile == introVideo,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            // color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              ...[
                pdf,
                ppt,
                gallery,
                promotionalVideo,
                introVideo,
                academicVideos,
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DrawerTileItem(
                    onTap: () {
                      Widget page = const Scaffold(backgroundColor: mainColor);
                      switch (e) {
                        case pdf:
                          page = MainPage();
                          launchTheLink(dashBoardProvider.pdfLink ?? '');
                          break;
                        case ppt:
                          page = MainPage();
                          launchTheLink(dashBoardProvider.pptLink ?? '');
                          break;
                        case gallery:
                          page = GalleryMainPage();
                          break;
                        case promotionalVideo:
                          page = DrawerVideoScreen(
                              url: dashBoardProvider.promotionalVideoLink ?? '',
                              title: promotionalVideo);
                          break;
                        case introVideo:
                          page = DrawerVideoScreen(
                              url: dashBoardProvider.introVideoLink ?? '',
                              title: introVideo);
                          break;
                        case academicVideos:
                          page = DrawerVideosMainPage();
                          break;
                        default:
                          page = buildDefaultPage();
                          break;
                      }
                      Get.to(page);
                    },
                    leading: e == pdf
                        ? Assets.pdf
                        : e == ppt
                            ? Assets.ppt
                            : e == gallery
                                ? Assets.gallery
                                : e == promotionalVideo
                                    ? Assets.video
                                    : e == introVideo
                                        ? Assets.video
                                        : Assets.video,
                    title: e,
                    width: size.width * 0.7,
                    selected: dashBoardProvider.selectedDrawerTile == e,
                    opacity: 0.9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container buildFooter(
      Size size, BuildContext context, DashBoardProvider dashBoardProvider) {
    return Container(
      height: 20 + size.height * 0.13,
      // color: Colors.white38,
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () =>
                    launchTheLink(sl.get<AuthProvider>().privacy ?? ""),
                child: bodyMedText('Privacy Policy', context,
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    )),
              ),
            ],
          ),
          height10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => launchTheLink(sl.get<AuthProvider>().term ?? ""),
                child: bodyMedText('Terms & Conditions', context,
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    )),
              ),
            ],
          ),*/
          Row(
            children: [
              Spacer(flex: 1),
              Expanded(
                  flex: 3,
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
                        "${AppConstants.packageID}_app_dash_logo",
                        stalePeriod: const Duration(days: 30))),
                  )),
              Spacer(flex: 1)
            ],
          ),
          height10(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              bodyMedText(
                'Version $appVersion',
                context,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildHeader(
      Size size, BuildContext context, AuthProvider authProvider) {
    return Container(
      height: 100,
      // color: CupertinoColors.white,

      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: titleLargeText(
                        (authProvider.userData.customerName ?? 'Unknown')
                            // 'Jury John'
                            .capitalize!,
                        context,
                        color: Colors.white,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                height5(),
                Row(
                  children: [
                    Expanded(
                      child: capText(
                          '(${authProvider.userData.username ?? 'Unknown'})',
                          context,
                          color: Colors.white70,
                          textAlign: TextAlign.start,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PopupMenuButton(
          //   surfaceTintColor: Colors.transparent,
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //   icon: assetSvg(Assets.popupButton0, color: Colors.white),
          //   onSelected: (val) {
          //     Get.back();
          //     Get.to(ProfileScreen());
          //   },
          //   itemBuilder: (BuildContext context) {
          //     return [
          //       PopupMenuItem(
          //         child: Text('Profile'),
          //         value: 'Profile',
          //       ),
          //       const PopupMenuItem(
          //         child: Text('Commission Withdrawal'),
          //         value: 'Commission Withdrawal',
          //       ),
          //     ];
          //   },
          // ),
        ],
      ),
    );
  }

//default components

  Widget expansionTile(
      {String title = '',
      required String headerAsset,
      required List<Widget> children,
      bool initiallyExpanded = false}) {
    return Theme(
        data: Theme.of(context).copyWith(
            listTileTheme: ListTileTheme.of(context).copyWith(dense: true)),
        child: ExpansionTile(
          title: Row(
            children: [
              assetSvg(headerAsset, color: Colors.white, width: 15),
              width10(),
              Expanded(
                  child: bodyMedText(
                title,
                context,
                maxLines: 1,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                useGradient: true,
              )),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          collapsedBackgroundColor: Colors.white.withOpacity(0.03),
          backgroundColor: Colors.blueGrey.withOpacity(0.15),
          iconColor: Colors.white,
          textColor: Colors.white,
          collapsedTextColor: Colors.white70,
          collapsedIconColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          initiallyExpanded: initiallyExpanded,
          children: children,
        ));
  }

  Scaffold buildDefaultPage() {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        title: titleLargeText('My Car Club', context,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            useGradient: true),
        centerTitle: true,
      ),
      body: Center(
        child: bodyLargeText('Comming soon...', context, color: Colors.white),
      ),
    );
  }
}

class DrawerTileItem extends StatefulWidget {
  const DrawerTileItem({
    super.key,
    this.onTap,
    required this.leading,
    required this.title,
    required this.selected,
    required this.width,
    this.trailing,
    this.trailingOnTap,
    this.opacity = 1,
  });

  final void Function()? onTap;
  final String leading;
  final String title;
  final bool selected;
  final double width;
  final Widget? trailing;
  final VoidCallback? trailingOnTap;
  final double opacity;
  @override
  State<DrawerTileItem> createState() => _DrawerTileItemState();
}

class _DrawerTileItemState extends State<DrawerTileItem>
    with SingleTickerProviderStateMixin {
  // late AnimationController animationController;
  // late Animation animation;
  @override
  void initState() {
    // animationController = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 1000));
    // animation = Tween<double>(begin: 0, end: widget.width).animate(
    //     CurvedAnimation(
    //         parent: animationController, curve: Curves.fastLinearToSlowEaseIn));

    // animationController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    // animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bound) {
      infoLog(bound.maxWidth.toString());
      return InkWell(
        onTap: () {
          Provider.of<DashBoardProvider>(context, listen: false)
              .setDrawerTile(widget.title);
          // animationController.forward();
          // setState(() {});
          widget.trailingOnTap != null
              ? widget.trailingOnTap!()
              : widget.onTap != null
                  ? widget.onTap!()
                  : null;
        },
        splashColor: Colors.red,
        child: Stack(
          children: [
            Container(
              // height: 35,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  assetSvg(widget.leading, color: Colors.white, width: 15),
                  width10(),
                  Expanded(
                    child: bodyMedText(
                      widget.title,
                      context,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      useGradient: true,
                      opacity: widget.selected ? 1 : widget.opacity,
                      // maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.trailing != null) width10(),
                  if (widget.trailing != null) widget.trailing!
                ],
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                padding: const EdgeInsets.all(10),
                width: widget.selected ? bound.maxWidth : 0,
                // height: 35,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.fastLinearToSlowEaseIn,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05 * 5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

const String aboutUsHtml = (r'''

<section class="p-y-5 pb-0">
<div class="container">
<div class="row">
<div class="col-lg-5 col-md-5 col-sm-5 col-xs-12 p-2">
<img style="margin-top:15%;" src="https://mycarclub.com/assets/website-panel/img/ilu.png" width="100%" alt="">
</div>
<div style="margin-top:5%;" class="col-lg-7 col-md-7 col-sm-7 col-xs-12 p-2">
<p style="font-weight:bold;font-size:20px;color: #f26822;">ABOUT</p>
<p style="font-size:medium;text-align: justify;">If you're passionate about cars, then you've come to the right place! MyCarClub.com is a tight-knit community of car enthusiasts who come together to share their love for anything on wheels. You receive weekly newsletter on the latest motor releases, events, exhibitions and more.<br><br>
We believe that cars aren't just machines, they're a way of life. From muscle cars to exotic rides, we're always eager to hear the stories behind each member's unique ride. Whether you're an expert, enthusiast or simply love the thrill of a good drive, there's something for everyone in our club.<br></p>

</div>
<div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 p-2">
<p style="font-size:medium;text-align: justify;"> Our inclusive and supportive community is all about coming together to celebrate everything that makes cars so special. We believe in supporting each other through the highs and lows of car ownership, and we're always happy to offer advice on how to get the most out of your ride. We also present you the opportunity to drive a top class luxury car and make monthly income through our marketing plan.</p>
<p style="font-size:medium;">So whether you're into classic cars, performance vehicles, or simply love the thrill of hitting the open road, we'd love for you to join our community.
</p>
</div>
</div>
</div>
</section>
<section class="p-y-5 pb-0" style="padding: 10px;">
<div class="container">
<div class="row">
<div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 p-2 text-center">
<img src="https://mycarclub.com/assets/website-panel/img/car-keys.png" style="max-width: 100%;">
</div>
</div>
</div>
</section>
<section class="p-y-5 pb-0" style="background-color: #ebebeb8f; padding: 10px;">
<div class="container">
<div class="row">
<div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 p-2">
<p style="font-weight:bold;font-size:20px;color: #f26822;">START</p>
<p style="font-size:medium; text-align: justify;">Starting your My Car Club membership can be a fun and exciting endeavour. You can avail all the amazing offers, discounts and activity invites through a few simple clicks. My Car Club offers a subscription-based model where members could choose either a monthly or yearly subscription. There is a one-time joining fee of €149, at present you get €50 Founder’s discount making it affectively €99 only. The monthly membership is only €29 while you save one month’s subscription fee by paying for a year. When you choose yearly membership, you pay only €319 instead of €348. </p>
<p style="font-size:medium; text-align: justify;">By following these steps, you can establish you My Car Club membership that will provide you and your fellow enthusiasts with enjoyable and memorable experiences along with an abundance of benefits.</p>
</div>
</div>
</div>
</section>
<section class="p-y-5 pb-0" style="padding: 10px;">
<div class="container">
<div class="row">
<div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 p-2 text-center">
<img src="https://mycarclub.com/assets/website-panel/img/12wa.png" style="max-width: 60%;">
</div>
</div>
</div>
</section>
<section class="p-y-5 pb-0" style="background-color: #e2e2e2fa; padding: 10px;">
<div class="container">
<div class="row">
<div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 p-2" style="background-color: #e2e2e2fa;">
<p style="font-weight:bold;font-size:20px;color: #f26822;">BUSINESS OPPORTUNITY</p>
<p style="font-size:medium; text-align: justify;">We are building an active community of car enthusiasts where you can network with people from different walks of life. You get to meet gearheads, wizards, experts, professionals, and fans of the automotive industry. My Car Club gives you huge rewards for networking too. From being able to drive a latest luxury car to even getting monthly residual income – it is all within your reach with My Car Club. More information on the reward programme is accessible for paying members.</p>
</div>
</div>
</div>
</section>
<section class="p-y-5 pb-0">
<div class="container">
<div class="row">
<div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 p-2">
<h1 style="font-weight:bold;font-size:25px;color: #f26822;">EXCLUSIVE CAR CLUB AND A GROUP OF CAR</h1>
<p style="font-size:medium;">Enthusiasts who love everything about the automotive world.</p>
</div>
<div class="col-lg-6 col-md-6 col-sm-6 col-xs-12 p-2">
<p style="font-weight:bold;font-size:20px;color: #f26822;">Mission</p>
<p style="font-size:medium;text-align: justify;">The mission of a MyCarClub is to provide members with a unique, exclusive, and unparalleled experience to its members. We aim to offer a wide range of benefits to individual needs and desires so our goal is to ensure each customer has a safe and enjoyable experience that leaves them coming back for more.</p>
</div>
<div class="col-lg-6 col-md-6 col-sm-6 col-xs-12 p-2">
<p style="font-weight:bold;font-size:20px;color: #f26822;">Vision</p>
<p style="font-size:medium;text-align: justify;">Our vision is to provide an exceptional level of personalized service, allowing members to explore new vehicles and discover new engaging opportunities. We strive to exceed expectations with every aspect of our service, from the quality of our vehicles to the attention to detail in our customer service. </p>
</div>
</div>
</div>
</section>

<section class="p-y-5 pb-0" style="padding: 5px; background-color: #ebebeb8f;">
<div class="container">
<div class="row">
<div class="col-lg-7 col-md-7 col-sm-7 col-xs-12 p-2 ">
<h2 class="elementor-heading-title elementor-size-default" style="font-weight:bold;font-size:20px;color: #f26822;">WELCOME TO MY CAR CLUB</h2>
<p style="font-size:medium; color: #000;text-align: justify;">Once you become a part of this exclusive membership club, you shall have access to all major events organised by us, such as follows:<br>
1. We organize a scenic drives: We plan scenic routes through the countryside and national parks where the My Car Club members can drive and appreciate the beautiful scenery. You can also hold a photo contest for the members and give prizes for the best pictures.<br>
2. We host car shows: We invite car enthusiasts from different locations to showcase their cars and compete in various categories. We also set up food and music for fun-filled days.<br>
3. Road rallies: We plan road rallies where My Car Club members can race against each other while solving puzzles and riddles along the route.<br>
4. Car maintenance workshops: We host regular workshops on car maintenance where members can learn about basic car maintenance tips and tricks.<br>
5. Car detailing demos: We invite professionals to showcase how to detail a car properly. This can be helpful for car enthusiasts who want to learn more about cleaning and detailing their cars.<br>
6. Garage tour: We organize garage tours where members can visit local garages and see cool car collections.</p>
</div>
<div class="col-lg-5 col-md-5 col-sm-5 col-xs-12 p-2 ">
<img src="https://mycarclub.com/assets/website-panel/img/lobbyimage_2-min-removebg-preview.png" style="margin-top:15%;" class="attachment-large size-large" alt="" loading="lazy" sizes="(max-width: 590px) 100vw, 590px">
</div>
</div>
</div>
</section>
<div class="container">
<div class="row">
<div style="margin-top:5%;" class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
<h1 style="font-weight:bold;font-size:20px;color: #f26822;">JOIN US</h1>
<p style="font-size:medium;">Come join the world’s most exclusive car club today and experience a lifestyle like no other! Drive your dream cars and be part of a select group of people who share a passion for cars.</p>
<a href="https://mycarclub.com/membership"><button class="button12 buttonr">MEMBERSHIP</button></a>
</div>
</div>
</div>
<br><br>
<section class="p-y-5 pb-0" style="padding: 5px; background-color: #e2e2e2fa;">
<div class="container">
<div class="row">
<div class="col-lg-5 col-md-5 col-sm-5 col-xs-12 p-2 ">
<img src="https://mycarclub.com/assets/website-panel/img/mcd.png" style="margin-top:15%;" class="attachment-large size-large" alt="" loading="lazy" sizes="(max-width: 590px) 100vw, 590px">
</div>
<div class="col-lg-7 col-md-7 col-sm-7 col-xs-12 p-2 ">
<h2 class="elementor-heading-title elementor-size-default" style="font-weight:bold;font-size:20px;color: #f26822;">WHY US</h2>
<p style="font-size:medium; color: #000;text-align: justify;">As a car enthusiast club, there are several benefits that members can derive from being part of My Car Club community. Some of these benefits include:
<br>
1. Knowledge sharing: Being part of this community allows you to interact with like-minded people who share your passion for automobiles. This opens up the opportunity to share knowledge and learn from others. You will have access to information, tips, and advice from seasoned professionals and experienced car enthusiasts.<br>
2. Networking: My Car Club provides a platform for members to network and make connections with people who work within the automotive industry. This can be particularly fun and helpful for new car enthusiasts who are unfamiliar with the ins and outs of car culture.<br>
3. Hands-on learning: We organise experiences where members are given the opportunity to work on cars and participate in activities such as track days or autocross. This allows members to gain hands-on experience with different types of vehicles and learn from experienced enthusiasts.<br>
4. Access to exclusive events: Car enthusiast clubs often organise events that are limited to members. This could include car shows, rallies, and cruises.
</p>
</div>
</div>
</div>
</section>
<div class="row-video">
<div class="container">

<div class="row equalize sm-equalize-auto">
<div class="col-md-6" style="margin-top: 5%;">
<div class="themesflat-spacer clearfix" data-desktop="33" data-mobi="0" data-smobi="0" style="height:33px"></div>
<div class="themesflat-headings style-1 clearfix">
<h2 style="font-weight: bold;font-size: 15px;text-decoration:underline;color: #f26822;" class="heading letter-spacing--09px clearfix">SUPPORT</h2><br>
<div class="sep clearfix"></div>
<p style="font-size:medium;text-align: justify;">Our support team is available by phone, email and live chat, so you’ll always have someone to talk to – in your language – whenever the markets are open. You can also reach My Car Club on Facebook, our Customer Support representatives monitor and respond to comments on social media on a daily basis.</p>
</div>

<div class="themesflat-spacer clearfix" data-desktop="20" data-mobi="20" data-smobi="20" style="height:20px"></div>
<h3 class="title-video"></h3>
<div class="themesflat-spacer clearfix" data-desktop="21" data-mobi="20" data-smobi="20" style="height:21px"></div>
<a href="#" class="themesflat-button blue"></a>
<div class="themesflat-spacer clearfix" data-desktop="28" data-mobi="60" data-smobi="60" style="height:28px"></div>
</div>

<div class="col-md-6 half-background ">
<div class="img-single margin-top--60">
<img src="https://mycarclub.com/assets/website-panel/img/sup.png" alt="Image" style="max-width: 80%;">
</div>

<div class="themesflat-icon style-1 clearfix background">

</div>

</div>

</div>

</div>
</div>
<section class="p-y-5 pb-0">

</section>
''');
