import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/team_downline_user_model.dart';
import '/database/repositories/team_view_repo.dart';
import '/providers/auth_provider.dart';
import '/screens/drawerPages/trem_view_page.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';

import '../shared.dart' show watchAnimationDurationSetting;

class LazyLoadingTreeView extends StatefulWidget {
  const LazyLoadingTreeView({super.key});

  @override
  State<LazyLoadingTreeView> createState() => _LazyLoadingTreeViewState();
}

class _LazyLoadingTreeViewState extends State<LazyLoadingTreeView> {
  late final Random rng = Random();
  late final TreeController<TeamDownlineUser> treeController;

  Iterable<TeamDownlineUser> childrenProvider(TeamDownlineUser data) {
    return childrenMap[data.username] ?? const Iterable.empty();
  }

  final Map<String, List<TeamDownlineUser>> childrenMap = {
    sl.get<AuthProvider>().userData.username!: [],
  };

  final Set<String> loadingIds = {};
  final Set<int> levels = {};
  int curMaxLevel = 1;
  bool loading = false;
  Future<void> loadChildren(TeamDownlineUser data) async {
    final List<TeamDownlineUser>? children = childrenMap[data.username!];
    if (children != null) return;

    setState(() {
      loadingIds.add(data.username!);
    });
    //
    await Future.delayed(const Duration(milliseconds: 750));
    var users = await getDownLines(data.newLevel!, data.username!);
    childrenMap[data.username!] = users;
    if (users.isNotEmpty) {
      toggleLevel(data.newLevel!);
    }
    // print(childrenMap[data.username!]!.map((e) => e.nameWithUsername));
    loadingIds.remove(data.username!);
    if (mounted) setState(() {});
    treeController.expand(data);
  }

  Widget getLeadingFor(TeamDownlineUser data) {
    if (loadingIds.contains(data.username!)) {
      return const Center(
          child: SizedBox.square(
              dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)));
    }

    late final VoidCallback? onPressed;
    late final bool? isOpen;

    final List<TeamDownlineUser>? children = childrenMap[data.username!];
    if (children == null) {
      isOpen = false;
      onPressed = () => loadChildren(data);
    } else if (children.isEmpty) {
      isOpen = null;
      onPressed = null;
    } else {
      isOpen = treeController.getExpansionState(data);
      onPressed = () {
        treeController.toggleExpansion(data);
      };
    }

    return FolderButton(
      key: GlobalObjectKey(data.username!),
      isOpen: isOpen,
      onPressed: onPressed,
      icon: Icon(Icons.person),
      openedIcon: Icon(Icons.keyboard_arrow_up_rounded, color: Colors.red),
      closedIcon:
          Icon(Icons.keyboard_arrow_down_rounded, color: appLogoColor),
    );
  }

  init() async {
    // debugPaintSizeEnabled = true;
    // debugPaintBaselinesEnabled = true;

    setState(() {
      loading = true;
    });
    var user = sl.get<AuthProvider>().userData;
    childrenMap[user.username!] = await getDownLines(1, user.username!);
    print(childrenMap[user.username!]!.map((e) => e.nameWithUsername));
    treeController = TreeController<TeamDownlineUser>(
        roots: childrenProvider(TeamDownlineUser(username: user.username!)),
        childrenProvider: childrenProvider);
    setState(() {
      loading = false;
    });
  }

  toggleLevel(int val) {
    setState(() {
      if (levels.contains(val)) {
        // levels.remove(val);
      } else {
        levels.add(val);
      }
    });
    print('leveles $levels');
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  Future<List<TeamDownlineUser>> getDownLines(int level, String id) async {
    List<TeamDownlineUser> levelArray = [];
    if (isOnline) {
      try {
        ApiResponse apiResponse = await sl
            .get<TeamViewRepo>()
            .getDownLines({'level': level.toString(), 'sponser_username': id});
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut();
            }
            if (status) {
              try {
                map['levelArray'].forEach(
                    (e) => levelArray.add(TeamDownlineUser.fromJson(e)));
                print(levelArray.length);
              } catch (e) {
                print('could not generate the level array $e');
              }
            }
          } catch (e) {}
        }
      } catch (e) {}
    } else {
      Fluttertoast.showToast(msg: 'No internet connection');
    }
    return levelArray;
  }

  @override
  Widget build(BuildContext context) {
    int max = 1;
    if (levels.isNotEmpty) {
      max =
          levels.reduce((value, element) => value > element ? value : element);
    }
    bool noChildren =
        childrenMap[sl.get<AuthProvider>().userData.username ?? '']!.isEmpty;
    print('max is $max');
    return Column(
      children: [
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                  height: Get.height,
                  width: Get.width + ((noChildren ? 0 : max) * 40),
                  child: !loading
                      ? !noChildren
                          ? buildAnimatedTreeView(context)
                          : buildEmptyList(context)
                      : Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      ],
    );
  }

  AnimatedTreeView<TeamDownlineUser> buildAnimatedTreeView(
      BuildContext context) {
    return AnimatedTreeView<TeamDownlineUser>(
      treeController: treeController,
      nodeBuilder: (_, TreeEntry<TeamDownlineUser> entry) {
        return TreeIndentation(
          entry: entry,
          child: Row(
            children: [
              Container(
                width: 300,
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: (entry.node.downline != null &&
                          entry.node.downline! > 0) ||
                          entry.node.newLevel == 2
                          ? 40
                          : 0,
                      child: (entry.node.downline != null &&
                              entry.node.downline! > 0)
                          ? getLeadingFor(entry.node)
                          : null,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black87)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: capText(
                                      (entry.node.nameWithUsername ?? '')
                                          .capitalize!,
                                      context,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                width20(),
                                if (entry.node.status == '1' ||
                                    entry.node.status == '2')
                                  Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: entry.node.status == '1'
                                            ? Colors.green
                                            : Colors.red),
                                    child: capText(
                                        entry.node.status == '1'
                                            ? 'Active'
                                            : 'Deactive',
                                        context,
                                        color: Colors.white),
                                  )
                              ],
                            ),
                            if (entry.node.activeDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    capText(
                                        'Active date:- ${DateFormat().add_yMMMd().add_jm().format(DateTime.parse(entry.node.activeDate!))}',
                                        context,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                    capText(
                                        'Total Members:- ${entry.node.totalMember}',
                                        context,
                                        color: Colors.black87),
                                    capText(
                                        'Active Members:- ${entry.node.activeMember}',
                                        context,
                                        color: Colors.black87),
                                  ],
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
        );
      },
      padding: const EdgeInsets.all(0),
      duration: watchAnimationDurationSetting(context),
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
}
