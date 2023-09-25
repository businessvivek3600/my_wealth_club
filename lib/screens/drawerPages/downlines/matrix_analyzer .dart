import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphview/GraphView.dart';
import 'package:mycarclub/database/dio/exception/api_error_handler.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/assets_constants.dart';
import '../../../database/functions.dart';
import '../../../database/model/response/base/api_response.dart';
import '../../../database/model/response/team_downline_user_model.dart';
import '../../../database/repositories/team_view_repo.dart';
import '../../../utils/default_logger.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/team_view_provider.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';
import 'package:provider/provider.dart';
import '../../../sl_container.dart';
import '../../../utils/MyClippers.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/text.dart';
import 'generation_analyzer.dart';
import 'team_view/layerd_graph_team_view.dart';
import 'trem_view_page.dart';

class MatrixAnalyzerPage extends StatefulWidget {
  const MatrixAnalyzerPage({super.key});

  @override
  State<MatrixAnalyzerPage> createState() => _MatrixAnalyzerPageState();
}

class _MatrixAnalyzerPageState extends State<MatrixAnalyzerPage> {
  var provider = sl.get<TeamViewProvider>();
  var authProvider = sl.get<AuthProvider>();

  int selectedIndex = 0;

  final breadCumbScroll = ScrollController();
  void _animateToLast() {
    breadCumbScroll.animateTo(
      breadCumbScroll.position.maxScrollExtent,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.setBreadCrumbContent(
          0,
          BreadCrumbContent(
              index: 0,
              user: GenerationAnalyzerUser(
                  name: 'Root', image: Assets.appWebLogo, generation: 0)));
      provider.gUsers.clear();
      provider.gUsers.addAll(provider.generateRandomUsers(0));
      setState(() {});
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    });
  }

  @override
  void dispose() {
    provider.breadCrumbContent.clear();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamViewProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: buildAppBar(context),
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: userAppBgImageProvider(context),
                    fit: BoxFit.cover,
                    opacity: 1)),
            child: Column(children: [
              if (provider.breadCrumbContent.length > 0)
                bradcrumRow(provider, context),
              height10(),
              Expanded(
                  child: provider.loadingGUsers.name ==
                          ButtonLoadingState.loading.name
                      ? Center(
                          child: CircularProgressIndicator(color: appLogoColor))
                      : _MatrixTree(
                          username:
                              provider.breadCrumbContent.last.user.name ?? "",
                          onTap: (TeamDownlineUser user) {
                            print('user ${user.toJson()}');
                            if (!provider.breadCrumbContent.any((element) =>
                                element.user.name == user.username)) {
                              provider.setBreadCrumbContent(
                                  provider.breadCrumbContent.length,
                                  BreadCrumbContent(
                                      index: provider.breadCrumbContent.length,
                                      user: GenerationAnalyzerUser(
                                          name: user.username,
                                          generation: user.newLevel!)));
                            } else {
                              provider.setBreadCrumbContent(
                                  provider.breadCrumbContent.indexWhere(
                                      (element) =>
                                          element.user.name == user.username),
                                  BreadCrumbContent(
                                      index: provider.breadCrumbContent.length,
                                      user: GenerationAnalyzerUser(
                                          name: user.username,
                                          generation: user.newLevel!)));
                            }
                          })),
            ]),
          ),
        ),
      );
    });
  }

  Row bradcrumRow(TeamViewProvider provider, BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildBreadcrumbs(provider)),
        width5(),
        ClipPath(
          clipper: OvalLeftBorderClipper(),
          child: GestureDetector(
            onTap: () {
              if (provider.breadCrumbContent.length == 1) return;

              provider.setBreadCrumbContent(1);
              provider.setGenerationUsers(0);
              _animateToLast();
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black26)
                  ]),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Icon(Icons.arrow_back_rounded,
                  //     color: Colors.white, size: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: capText('Root', context,
                        color: Colors.white, useGradient: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  GridView buildGrid(TeamViewProvider provider) {
    return GridView.builder(
      padding: EdgeInsets.only(
          left: 10, right: 10, top: 0, bottom: kBottomNavigationBarHeight),
      itemCount: provider.gUsers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1),
      itemBuilder: (context, index) {
        GenerationAnalyzerUser user = provider.gUsers[index];
        return GestureDetector(
          onTap: () {
            provider.setBreadCrumbContent(
                provider.breadCrumbContent.length,
                BreadCrumbContent(
                    index: provider.breadCrumbContent.length,
                    user: GenerationAnalyzerUser(
                        name: user.name,
                        image: user.image,
                        generation: user.generation)));
            provider.setGenerationUsers(user.generation);
            _animateToLast();
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: bColor,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26)
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                assetImages(user.image ?? '', height: 50, width: 50),
                bodyLargeText(user.name ?? '', context,
                    textAlign: TextAlign.center, useGradient: false),
                height5(),
              ],
            ),
          ),
        );
      },
    );
  }

  Container buildBreadcrumbs(TeamViewProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 1), blurRadius: 3, color: Colors.black26)
          ]),
      padding: EdgeInsets.all(8),
      child: BreadCrumb.builder(
        itemCount: provider.breadCrumbContent.length,
        builder: (index) {
          GenerationAnalyzerUser user = provider.breadCrumbContent[index].user;
          return BreadCrumbItem(
            margin: EdgeInsets.only(
                right:
                    index == provider.breadCrumbContent.length - 1 ? 100 : 0),
            content: capText('Crumb ${user.name}', context, useGradient: true),
            onTap: () {
              provider.setBreadCrumbContent(index + 1);
              provider.setGenerationUsers(user.generation);
              _animateToLast();
              setState(() {});
            },
          );
        },
        divider: Icon(Icons.chevron_right, color: Colors.white, size: 20),
        overflow: ScrollableOverflow(
            direction: Axis.horizontal,
            reverse: false,
            keepLastDivider: false,
            controller: breadCumbScroll),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: titleLargeText('Matrix Analyzer', context, useGradient: true)),
      actions: [],
    );
  }
}

class _MatrixTree extends StatefulWidget {
  _MatrixTree({super.key, required this.username, required this.onTap});
  final String username;
  final Function(TeamDownlineUser user) onTap;
  @override
  _MatrixTreeState createState() => _MatrixTreeState();
}

class _MatrixTreeState extends State<_MatrixTree> {
  double s = 5;
  var provider = sl.get<TeamViewProvider>();

  @override
  void initState() {
    super.initState();

    init();
    builder
      // ..nodeSeparation = (5)
      ..siblingSeparation = (25).toInt()
      ..levelSeparation = (25).toInt()
      ..subtreeSeparation = (25).toInt()
      ..orientation = SugiyamaConfiguration.DEFAULT_ORIENTATION;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamViewProvider>(builder: (context, provider, _) {
      return !loadingInitial
          ? childrenMap.entries.isNotEmpty
              ? LayoutBuilder(builder: (context, b) {
                  print('b ${b.maxHeight} ${b.maxWidth}');
                  return OrientationBuilder(builder: (context, orientation) {
                    double margin =
                        orientation == Orientation.landscape ? 50 : 0;
                    return InteractiveViewer(
                      constrained: false,
                      boundaryMargin: EdgeInsets.only(
                          left: margin, right: margin, bottom: margin),
                      minScale: 0.01,
                      maxScale: 10.6,
                      scaleFactor: 100,
                      onInteractionEnd: (details) {
                        print('details ${details}');
                      },
                      panAxis: PanAxis.free,
                      child: GraphView(
                        graph: graph,
                        algorithm: BuchheimWalkerAlgorithm(
                            builder, TreeEdgeRenderer(builder)),
                        paint: Paint()
                          ..color = Colors.red
                          ..strokeWidth = 0.5
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          // I can decide what widget should be shown here based on the id
                          var a = node.key!.value as int?;
                          TeamDownlineUser source = TeamDownlineUser();
                          return LayoutBuilder(builder: (context, c) {
                            print('c ${c.maxHeight} ${c.maxWidth}');
                            return rectangleWidget(a, source);
                          });
                        },
                      ),
                    );
                  });
                })
              : buildEmptyList(context)
          : Center(child: CircularProgressIndicator(color: appLogoColor));
    });
  }

  Random r = Random();

  Widget rectangleWidget(int? a, TeamDownlineUser source) {
    TeamDownlineUser user = a == 1 ? rooTUser! : TeamDownlineUser();
    childrenMap.entries.forEach((element) {
      if (element.value.any((element) => element.nodeVal == a)) {
        user = element.value.firstWhere((element) => element.nodeVal == a);
      }
    });
    return GestureDetector(
      // onTap: (user.downline ?? 0) > 0 ? () => loadChildren(user) : null,
      onTap: () => widget.onTap(user),
      child: TeamViewUserIconWidget(
        rootUser: a == 1,
        user: user,
        loadingNodeId: loadingNodeId,
        context: context,
        // callBack: (user.downline ?? 0) > 0 ? () => loadChildren(user) : null,
        showMessage: false,
      ),
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  int nodeVal = 1;
  int loadingNodeId = 1;
  bool loadingInitial = false;
  bool loadingChildren = false;

  Future<void> loadChildren(TeamDownlineUser data) async {
    setState(() {
      loadingNodeId = data.nodeVal!;
      loadingChildren = true;
    });
    await Future.delayed(const Duration(milliseconds: 750));
    var users = await getDownLines(data.newLevel!, data.username!);
    final mSource = Node.Id(data.nodeVal);
    data.expanded = true;
    print('users.length   ${users.length}');
    print('source   ${data.nodeVal}  ${data.toJson()}');
    users.forEach((element) {
      var mUser = element;

      if (!childrenMap.entries.any((entry) => entry.key == data.nodeVal!)) {
        childrenMap.addEntries([MapEntry(data.nodeVal!, <TeamDownlineUser>[])]);
      }
      print('m childrenMap  ${childrenMap.entries.length}');
      var nodeArray = childrenMap.entries
          .firstWhere((element) => element.key == data.nodeVal!)
          .value;

      print('m nodeArray  ${nodeArray.map((e) => e.toJson())}');
      if (!nodeArray.any((ele) => ele.username == mUser.username)) {
        childrenMap.entries
            .firstWhere((element) => element.key == data.nodeVal!)
            .value
            .add(mUser);
        final destination = Node.Id(mUser.nodeVal);

        print('m destination  ${destination.key}');
        graph.addEdge(mSource, destination);

        var dUsers = mUser.team ?? [];
        print('d users.length   ${dUsers.length}');
        final dSource = Node.Id(mUser.nodeVal);
        dUsers.forEach((element) {
          var dUser = element;
          print(
              'd childrenMap  ${childrenMap.entries.any((element) => element.key == mUser.nodeVal!)}');

          if (!childrenMap.entries
              .any((entry) => entry.key == mUser.nodeVal!)) {
            childrenMap
                .addEntries([MapEntry(mUser.nodeVal!, <TeamDownlineUser>[])]);
          }
          var nodeArray = childrenMap.entries
              .firstWhere((element) => element.key == mUser.nodeVal!)
              .value;

          print('d nodeArray  ${nodeArray.length}');
          if (!nodeArray.any((ele) => ele.username == dUser.username)) {
            childrenMap.entries
                .firstWhere((element) => element.key == mUser.nodeVal!)
                .value
                .add(dUser);
            final destination = Node.Id(dUser.nodeVal);
            graph.addEdge(dSource, destination);
          } else {
            print('duser already contains');
          }
        });
      } else {
        print('user already contains');
      }
      print('children map is not empty ${childrenMap.entries.length}');
    });
    setState(() {
      loadingNodeId = 0;
      loadingChildren = false;
    });
  }

  // Future<ApiResponse> getDownLiness(Map<String, dynamic> data) async {
  //   try {
  //     Dio dio = Dio();
  //     //add base url
  //     dio.options.baseUrl = 'https://mycarclub.com/api/';
  //     dio.options.headers['Authorization'] =
  //         'Bearer ${'0400937c365c59f47d9b9066cb18f241'}';
  //     dio.options.headers['x-api-key'] = 'BIZZCOIN@BIZZTRADEPRO@TRANSFER';
  //     FormData formData = new FormData();
  //     blackLog('post dio client data: ${data}');
  //     formData.fields
  //         .addAll((data).entries.toList().map((e) => MapEntry(e.key, e.value)));
  //     formData.fields
  //         .add(MapEntry('login_token', '0400937c365c59f47d9b9066cb18f241'));
  //     print(formData.fields);
  //     Response response =
  //         await dio.post(AppConstants.getDownLines, data: formData);
  //     return ApiResponse.withSuccess(response);
  //   } catch (e) {
  //     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
  //   }
  // }

  Future<List<TeamDownlineUser>> getDownLines(int level, String id) async {
    List<TeamDownlineUser> levelArray = [];
    for (int i = 0; i < 3; i++) {
      nodeVal++;
      TeamDownlineUser mUser = TeamDownlineUser(
          username: 'user $nodeVal', nodeVal: nodeVal, newLevel: level + 1);
      for (int i = 0; i < 3; i++) {
        nodeVal++;
        TeamDownlineUser dUser = TeamDownlineUser(
            username: 'user $nodeVal', nodeVal: nodeVal, newLevel: level + 2);
        if (mUser.team == null) mUser.team = [];
        mUser.team?.add(dUser);
      }
      levelArray.add(mUser);
    }
    return levelArray;
    // if (isOnline) {
    //   try {
    //     ApiResponse apiResponse = await getDownLiness(
    //         {'level': level.toString(), 'sponser_username': id});
    //     print('apiResponse ${apiResponse.response!.data}');
    //     if (apiResponse.response != null &&
    //         apiResponse.response!.statusCode == 200) {
    //       Map map = apiResponse.response!.data;
    //       bool status = false;
    //       try {
    //         status = map["status"];
    //         if (map['is_logged_in'] == 0) {
    //           logOut();
    //         }
    //         if (status) {
    //           try {
    //             map['levelArray'].forEach(
    //                 (e) => levelArray.add(TeamDownlineUser.fromJson(e)));
    //             print(levelArray.length);
    //           } catch (e) {
    //             print('could not generate the level array $e');
    //           }
    //         }
    //       } catch (e) {}
    //     }
    //   } catch (e) {}
    // } else {
    //   Fluttertoast.showToast(msg: 'No internet connection');
    // }
    // return levelArray;
  }

  final Map<int, List<TeamDownlineUser>> childrenMap = {};
  TeamDownlineUser? rooTUser;
  void init() async {
    setState(() {
      loadingInitial = true;
    });
    try {
      rooTUser = TeamDownlineUser(
          username: widget.username, nodeVal: nodeVal, newLevel: 1);
      print('------- user ${rooTUser!.toJson()} ----------- ux');
      await loadChildren(rooTUser!);
    } catch (e) {
      print('-------e $e ----------- e');
    }
    setState(() {
      loadingInitial = false;
    });
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
              color: Colors.white, textAlign: TextAlign.center),
          height20(),
          buildTeamBuildingReferralLink(context, linkColor: Colors.white)
        ],
      ),
    );
  }

  Widget buildUser(TeamDownlineUser user) {
    return Container(
      height: 20,
      width: 20,
      color: bColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [titleLargeText(user.username ?? '', context, fontSize: s)],
      ),
    );
  }
}
