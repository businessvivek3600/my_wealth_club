import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/user_model.dart';
import '/providers/dashboard_provider.dart';
import '/providers/team_view_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class TeamMemberPage extends StatefulWidget {
  const TeamMemberPage({Key? key}) : super(key: key);

  @override
  State<TeamMemberPage> createState() => _TeamMemberPageState();
}

class _TeamMemberPageState extends State<TeamMemberPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  var provider = sl.get<TeamViewProvider>();
  late ScrollController _scrollController;
  @override
  void initState() {
    provider.teamMemberPage = 0;
    provider.getCustomerTeam();
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() => _loadMore(sl.get<TeamViewProvider>()));
  }

  @override
  void dispose() {
    provider.loadingTeamMembers = false;
    provider.customerTeamMembers.clear();
    _scrollController.removeListener(() => _loadMore(provider));
    provider.teamMemberPage = 0;
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _loadMore(TeamViewProvider provider) async {
    if (_scrollController.position.pixels ==
            (_scrollController.position.maxScrollExtent) &&
        _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        !provider.loadingTeamMembers) {
      bool isFinished =
          provider.customerTeamMembers.length == provider.totalTeamMembers;
      if (isFinished) {
        Fluttertoast.showToast(msg: "No more data");
        return false;
      }
      print("Team Members ,onLoadMore");
      await provider.getDirectMembers();
    }
    return true;
  }

  Future<void> _refresh() async {
    print("Team members ,onRefresh");
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    provider.directMemberPage = 0;
    await provider.getDirectMembers();
  }

  @override
  Widget build(BuildContext context) {
    // sl.get<TeamViewProvider>().getCustomerTeam();
    return Scaffold(
      key: globalKey,
      backgroundColor: mainColor,
      appBar: AppBar(
          title: titleLargeText('Team Members', context, useGradient: true)),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: userAppBgImageProvider(context),
              fit: BoxFit.cover,
              opacity: 1),
        ),
        child: Consumer<TeamViewProvider>(
            builder: (context, teamViewProvider, child) {
          return (teamViewProvider.loadingTeamMembers ||
                  teamViewProvider.customerTeamMembers.isNotEmpty)
              ? RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(8),
                    children: [
                      ...teamViewProvider.customerTeamMembers
                          .map((e) => buildMember(e)),
                      if (provider.loadingTeamMembers)
                        Container(
                            padding: const EdgeInsets.all(20),
                            height: provider.customerTeamMembers.length == 0
                                ? Get.height -
                                    kToolbarHeight -
                                    kBottomNavigationBarHeight
                                : 100,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white))),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ///TODO: teamMembersLottie
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          assetLottie(Assets.teamMembersLottie, width: 200),
                        ],
                      ),
                      titleLargeText(
                          'Create your own team & join more people to enlarge your team.',
                          context,
                          color: Colors.white,
                          textAlign: TextAlign.center),
                      height20(),
                      buildTeamBuildingReferralLink(context)
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Widget buildTeamBuildingReferralLink(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashBoardProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: titleLargeText('Refer and invite: ', context,
                      color: appLogoColor))
            ]),
            height10(),
            Row(children: [
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
                                dashBoardProvider.teamBuildingUrl, context,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () async => await Clipboard.setData(
                                ClipboardData(
                                    text: dashBoardProvider.teamBuildingUrl))
                            .then((_) => ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    content: Text('Link copied  to clipboard.'),
                                    backgroundColor: appLogoColor))),
                        icon: Icon(Icons.copy, color: Colors.white, size: 15),
                      )
                    ],
                  ),
                ),
              )
            ]),
            height20(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      sendWhatsapp(text: dashBoardProvider.teamBuildingUrl);
                    },
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child:
                          assetSvg(Assets.whatsappColored, fit: BoxFit.cover),
                    )),
                width30(),
                GestureDetector(
                    onTap: () {
                      sendTelegram(text: dashBoardProvider.teamBuildingUrl);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            assetSvg(Assets.telegramColored, fit: BoxFit.cover),
                      ),
                    )),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildMember(UserData e) {
    Color tColor = Colors.white;
    return Container(
      decoration:
          BoxDecoration(color: bColor, borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bodyLargeText(
                        ('${e.customerName ?? ""}').capitalize!, context,
                        color: tColor),
                    capText('( ${e.username ?? ""} )', context,
                        color: tColor, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: (e.status == '1'
                            ? Colors.green
                            : e.status == '2'
                                ? Colors.red
                                : Colors.amber)
                        .withOpacity(0.5)),
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: capText(
                    e.status == '1'
                        ? 'Active'
                        : e.status == '2'
                            ? 'Deactive'
                            : 'Not-Active',
                    context,
                    color: Colors.white,
                    // color: e.status == '1'
                    //     ? Colors.green
                    //     : e.status == '2'
                    //         ? Colors.red
                    //         : Colors.amber,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
          /*height5(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              bodyLargeText('Reference ID:', context, color: Colors.black),
              bodyLargeText('${e.directSponserUsername ?? ''}', context,
                  color: Colors.blue),
            ],
          ),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              capText('Rank:', context, color: tColor.withOpacity(0.5)),
              capText(e.rankName ?? 'N/A', context, color: Colors.deepOrange),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              capText('Joined on:', context, color: tColor.withOpacity(0.5)),
              capText(
                  DateFormat()
                      .add_yMMMMd()
                      .format(DateTime.parse(e.createdAt ?? '')),
                  context,
                  color: tColor.withOpacity(0.5),
                  fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }
}
