import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_color_utils/flutter_color_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/team_view_provider.dart';
import '/screens/drawerPages/team_view/app.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/no_internet_widget.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../database/model/response/team_downline_user_model.dart';

class TeamViewPage extends StatefulWidget {
  const TeamViewPage({Key? key}) : super(key: key);

  @override
  State<TeamViewPage> createState() => _TeamViewPageState();
}

class _TeamViewPageState extends State<TeamViewPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  final AutoScrollController scrollController = AutoScrollController();
  @override
  void initState() {
    super.initState();
    sl
        .get<TeamViewProvider>()
        .getDownLines(1, sl.get<AuthProvider>().userData.username ?? '');
  }

  @override
  void dispose() {
    sl.get<TeamViewProvider>().initialLoading = true;
    sl.get<TeamViewProvider>().tree.children.clear();
    sl.get<TeamViewProvider>().widthLevel = 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: titleLargeText('Team View', context,useGradient: true),
          shadowColor: Colors.white),
      body: isOnline
          // ? Consumer<TeamViewProvider>(
          //     builder: (context, teamViewProvider, child) {
          //       print(
          //           '${teamViewProvider.loadingId}   ${teamViewProvider.loadingLevel}');
          //
          //       return !teamViewProvider.initialLoading
          //           ? (teamViewProvider.initialLoading ||
          //                   teamViewProvider.teams.isNotEmpty)
          //               ? buildListView(teamViewProvider)
          //               : buildEmptyList(context)
          //           : Center(
          //               child: CircularProgressIndicator(),
          //             );
          //       return !teamViewProvider.initialLoading
          //           ? TreeView.indexTyped<TeamDownlineUser,
          //               IndexedTreeNode<TeamDownlineUser>>(
          //               tree: teamViewProvider.tree,
          //               scrollController: scrollController,
          //               expansionBehavior:
          //                   ExpansionBehavior.collapseOthersAndSnapToTop,
          //               expansionIndicator: ExpansionIndicator.PlusMinus,
          //               // showRootNode: true,
          //               // onItemTap: (tree)=>teamViewProvider.getDownLines(tree.data?.newLevel??0, 'BIZZ3800074'),
          //               onItemTap: (tree) => teamViewProvider.getDownLines(
          //                   tree.data?.newLevel ?? 0, "BIZZ3800074"),
          //               builder: (context, level, item) => Card(
          //                 color: colorMapper[
          //                     level.clamp(0, colorMapper.length - 1)]!,
          //                 child: ListTile(
          //                   title: Text(
          //                       "Level: ${item.data?.newLevel} UserName: ${item.key}"),
          //                   subtitle: Text(
          //                       '${item.data?.nameWithUsername} ${item.data?.downline}'),
          //                 ),
          //               ),
          //             )
          //           : Center(
          //               child: CircularProgressIndicator(),
          //             );
          //     },
          //   )
          ? AppView()
          : NoInternetWidget(
              btnText: 'Retry!',
              textColor: Colors.black,
              callback: () => setState(() {
                print('getting data!!!');
                sl.get<TeamViewProvider>().getDownLines(
                    1, sl.get<AuthProvider>().userData.username ?? '');
              }),
            ),
    );
  }

  Padding buildEmptyList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //TODO: teamViewLottie
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              assetLottie(Assets.teamViewLottie, width: 200),
            ],
          ),
          titleLargeText(
              'Create team & join more people to enlarge the system.', context,
              color: Colors.black, textAlign: TextAlign.center),
          height20(),
          buildTeamBuildingReferralLink(context)
        ],
      ),
    );
  }

  ListView buildListView(TeamViewProvider teamViewProvider) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Container(
          height: Get.height,
          width: Get.width + ((teamViewProvider.widthLevel / 10) * 150),
          child: ListView(
            children: [
              ...teamViewProvider.teams
                  .map((e) => buildTeamItem(teamViewProvider, e)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildContainer(TeamDownlineUser e, TeamViewProvider teamViewProvider) {
    mixColors(int i) {
      Color red = Colors.black;
      Color yellow = Colors.white;
      // Color blue = const Color(0xff00224C);

      List<Color> spicyMixerList = [
        yellow.withOpacity(0.01 * i),
        red.withOpacity(1)
      ];
      Color mix = ColorUtils.mixColors(spicyMixerList);
      return mix;

      ///
    }

    final Map<int, Color> colorMapper2 = {
      0: mixColors(e.newLevel ?? 1),
      1: mixColors(e.newLevel ?? 1),
      2: mixColors(e.newLevel ?? 1),
      3: mixColors(e.newLevel ?? 1),
      4: mixColors(e.newLevel ?? 1),
      5: mixColors(e.newLevel ?? 1),
      6: mixColors(e.newLevel ?? 1),
      7: mixColors(e.newLevel ?? 1),
      8: mixColors(e.newLevel ?? 1),
      9: mixColors(e.newLevel ?? 1),
      10: mixColors(e.newLevel ?? 1),
    };
    bool isActive = e.status == '1';
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Opacity(
                opacity: e.downline! > 0 ? 1.0 : 0.0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      e.expanded = !e.expanded;
                      teamViewProvider.widthLevel = (e.newLevel ?? 2) - 1;
                    });
                    if (e.expanded) {
                      teamViewProvider.getDownLines(
                          e.newLevel ?? 0, e.username ?? '');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: !isActive ? Colors.red : Colors.green,
                        shape: BoxShape.circle),
                    child: Icon(
                      e.expanded ? Icons.remove : Icons.add,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: colorMapper[(colorMapper.length -
                          (e.newLevel ?? 1)
                              .clamp(0.2, colorMapper.length - 2))],
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: bodyLargeText(
                                '${e.nameWithUsername ?? ' '}'.capitalize!,
                                context,
                                color: Colors.white),
                          ),
                          width20(),
                          if (e.status == '1' || e.status == '2')
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: e.status == '1'
                                      ? Colors.green
                                      : Colors.red),
                              child: capText(
                                  e.status == '1' ? 'Active' : 'Deactive',
                                  context),
                            )
                        ],
                      ),
                      if (e.activeDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // bodyMedText(
                              //     '${e.activeDate ?? ' '}'.capitalize!, context,
                              //     color: Colors.black),
                              bodyMedText(
                                  'Active date:- ${DateFormat().add_yMMMd().add_jm().format(DateTime.parse(e.activeDate!))}',
                                  context,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                              capText(
                                  'Total Members:- ${e.totalMember}', context,
                                  color: Colors.white),
                              capText(
                                  'Active Members:- ${e.activeMember}', context,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (teamViewProvider.loadingLevel == e.newLevel &&
              teamViewProvider.loadingId == e.username)
            Container(
              height: 40,
              width: 40,
              // color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          if (e.team != null &&
              e.team!.length > 0 &&
              e.expanded &&
              (teamViewProvider.loadingLevel != e.newLevel &&
                  teamViewProvider.loadingId != e.username))
            ...e.team!.map((e) => buildChild(teamViewProvider, e)),
        ],
      ),
    );
  }

  Widget buildTeamItem(TeamViewProvider teamViewProvider, TeamDownlineUser e) =>
      buildContainer(e, teamViewProvider);

  Widget buildChild(TeamViewProvider teamViewProvider, TeamDownlineUser e) =>
      buildContainer(e, teamViewProvider);
}

Widget buildTeamBuildingReferralLink(BuildContext context,
    {Color linkColor = defaultBottomSheetColor}) {
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
                          : capText(dashBoardProvider.teamBuildingUrl, context,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              color: linkColor),
                    ),
                    IconButton(
                      onPressed: () async => await Clipboard.setData(
                              ClipboardData(
                                  text: dashBoardProvider.teamBuildingUrl))
                          .then((_) => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text('Link copied  to clipboard.'),
                                  backgroundColor: appLogoColor))),
                      icon: Icon(Icons.copy, color: Colors.cyan, size: 15),
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
                    child: assetSvg(Assets.whatsappColored, fit: BoxFit.cover),
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

// class UserName {
//   final String firstName;
//   final String lastName;
//
//   UserName(this.firstName, this.lastName);
// }
//
// final simpleTree = TreeNode<UserName>.root(data: UserName("User", "Names"))
//   ..addAll([
//     TreeNode<UserName>(key: "0A", data: UserName("Sr. John", "Doe"))
//       ..add(TreeNode(key: "0A1A", data: UserName("Jr. John", "Doe"))),
//     TreeNode<UserName>(key: "0C", data: UserName("General", "Lee"))
//       ..addAll([
//         TreeNode<UserName>(key: "0C1A", data: UserName("Major", "Lee")),
//         TreeNode<UserName>(key: "0C1B", data: UserName("Happy", "Lee")),
//         TreeNode<UserName>(key: "0C1C", data: UserName("Busy", "Lee"))
//           ..addAll([
//             TreeNode<UserName>(key: "0C1C2A", data: UserName("Jr. Busy", "Lee"))
//           ]),
//       ]),
//     TreeNode<UserName>(key: "0D", data: UserName("Mr. Anderson", "Neo")),
//     TreeNode<UserName>(key: "0E", data: UserName("Mr. Smith", "Agent")),
//   ]);
//
// final indexedTree = IndexedTreeNode<UserName>.root(
//     data: UserName("User", "Names"))
//   ..addAll([
//     IndexedTreeNode<UserName>(key: "0A", data: UserName("Sr. John", "Doe"))
//       ..add(IndexedTreeNode(key: "0A1A", data: UserName("Jr. John", "Doe"))),
//     IndexedTreeNode<UserName>(key: "0C", data: UserName("General", "Lee"))
//       ..addAll([
//         IndexedTreeNode<UserName>(key: "0C1A", data: UserName("Major", "Lee")),
//         IndexedTreeNode<UserName>(key: "0C1B", data: UserName("Happy", "Lee")),
//         IndexedTreeNode<UserName>(key: "0C1C", data: UserName("Busy", "Lee"))
//           ..addAll([
//             IndexedTreeNode<UserName>(
//                 key: "0C1C2A", data: UserName("Jr. Busy", "Lee"))
//           ]),
//       ]),
//     IndexedTreeNode<UserName>(key: "0D", data: UserName("Mr. Anderson", "Neo")),
//     IndexedTreeNode<UserName>(key: "0E", data: UserName("Mr. Smith", "Agent")),
//   ]);
