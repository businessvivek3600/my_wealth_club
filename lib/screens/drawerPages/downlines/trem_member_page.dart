import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  @override
  void initState() {
    sl.get<TeamViewProvider>().getCustomerTeam();
    super.initState();
  }

  @override
  void dispose() {
    sl.get<TeamViewProvider>().loadingTeamMembers = false;
    sl.get<TeamViewProvider>().customerTeamMembers.clear();
    super.dispose();
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
            return !teamViewProvider.loadingTeamMembers
                ? (teamViewProvider.loadingTeamMembers ||
                        teamViewProvider.customerTeamMembers.isNotEmpty)
                    ? ListView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.all(8),
                        children: [
                          ...teamViewProvider.customerTeamMembers
                              .map((e) => buildMember(e))
                        ],
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
                                assetLottie(Assets.teamMembersLottie,
                                    width: 200),
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
                      )
                : Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
          },
        ),
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
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
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
                        color: Colors.black),
                    capText('( ${e.username ?? ""} )', context,
                        color: Colors.black, fontWeight: FontWeight.bold),
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
                        .withOpacity(1)),
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
              capText('Rank:', context, color: Colors.black),
              capText(e.rankName ?? 'N/A', context, color: Colors.deepOrange),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              capText('Joined on:', context, color: Colors.black),
              capText(
                  DateFormat()
                      .add_yMMMMd()
                      .format(DateTime.parse(e.createdAt ?? '')),
                  context,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }
}
