import 'dart:convert';
import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/screens/drawerPages/downlines/generation_analyzer.dart';
import '/utils/default_logger.dart';
import '../constants/assets_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/base/user_model.dart';
import '/database/model/response/team_downline_user_model.dart';
import '/database/repositories/team_view_repo.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/widgets/MultiStageButton.dart';

import '../constants/app_constants.dart';

class TeamViewProvider extends ChangeNotifier {
  final TeamViewRepo teamViewRepo;
  TeamViewProvider({required this.teamViewRepo});
  IndexedTreeNode<TeamDownlineUser> tree = IndexedTreeNode();
  bool initialLoading = true;
  bool adding = true;
  int? loadingLevel = 0;
  int widthLevel = 1;
  String? loadingId = '';
  setLevel(int? val, String? id) {
    loadingLevel = val;
    loadingId = id;
    notifyListeners();
  }

  List<TeamDownlineUser> teams = [];
/*

  void addNodes(IndexedTreeNode<TeamDownlineUser> tree, int level, String id,
      List<TeamDownlineUser> team) {
    print('addNodes---> level: $level   key: $id');
    if (adding) {
      print(tree.children);
      try {
        if (tree.childrenAsList.any((element) => element.level + 1 != level)) {
          print(
              'element not matched  with level: ${tree.first.level + 1} ----- $level');
          tree.childrenAsList.forEach((e) {
            IndexedTreeNode<TeamDownlineUser> _tree = IndexedTreeNode();
            _tree.addAll([...e.childrenAsList]);
            addNodes(_tree, level, id, team);
            print('e---> $e');
          });
        } else {
          print('element matched  with level: $level ');
          // if (tree.firstWhere((element) => element.key == id).children.length !=
          //     0) {
          if (tree.children.any((element) => element.key == id)) {
            tree.firstWhere((element) => element.key == id).children.clear();
            tree.firstWhere((element) => element.key == id).addAll([
              ...team.map((e) => IndexedTreeNode<TeamDownlineUser>(
                  key: e.username,
                  data: TeamDownlineUser(
                      newLevel: e.newLevel,
                      username: e.username,
                      nameWithUsername: e.nameWithUsername)))
            ]);
            notifyListeners();
          } else {
            tree.addAll([
              ...team.map((e) => IndexedTreeNode<TeamDownlineUser>(
                  key: e.username,
                  data: TeamDownlineUser(
                      newLevel: e.newLevel,
                      username: e.username,
                      nameWithUsername: e.nameWithUsername)))
            ]);
            print('added new nodes');
            adding = false;
            notifyListeners();
          }
        }
        // }
      } catch (e) {
        print('addNodes---> error $e');
        throw e;
      }
    }
  }

  void addTeam(TeamDownlineUser user, List<TeamDownlineUser> tree, int level,
      String id, List<TeamDownlineUser> team) {
    // print('addNodes---> level: $level   key: $id');
    if (adding) {
      try {
        if (tree.length > 0 &&
            tree.every((element) => element.newLevel! != level)) {
          // print(
          //     'element not matched  with level: ${tree.first.newLevel! + 1} ----- $level');
          tree.forEach((e) {
            // print(e.username);
            // e.expanded = false;
            notifyListeners();
            if (e.team != null && e.team!.isNotEmpty) {
              // print('loading data for ${e.newLevel}  ${e.username}');
              addTeam(e, e.team!, level, id, team);
            }
            // print('e---> $e');
          });
        } else {
          // print('element matched  with level: $level $tree');
          print(tree.any((element) => element.username == id));
          // if (tree.firstWhere((element) => element.key == id).children.length !=
          //     0) {
          if (tree.length > 0 &&
              tree.any((element) => element.username == id)) {
            tree.firstWhere((element) => element.username == id).team = team;
            // print('element matched  adding   tree.any(');
            adding = false;
            // user.expanded = true;
            notifyListeners();
          } else {
            // print('element matched  adding   tree.addAll(');
            tree = team;
            // print('added new nodes');
            // user.expanded = true;
            adding = false;
            notifyListeners();
          }
        }
        // }
      } catch (e) {
        print('addNodes---> error $e');
        throw e;
      }
    }
  }

  Future<void> addTreeNodes(
      int level, String id, List<TeamDownlineUser> team) async {
    try {
      adding = true;
      addNodes(tree, level, id, team);
    } catch (e) {
      print('addTreeNodes--->  level: $level   key: $id  ***** error $e');
    }
    notifyListeners();
  }

  Future<void> addTeamNodes(
      int level, String id, List<TeamDownlineUser> team) async {
    try {
      adding = true;
      addTeam(TeamDownlineUser(), teams, level, id, team);
    } catch (e) {
      print('addTreeNodes--->  level: $level   key: $id  ***** error $e');
    }
    notifyListeners();
  }

  Future<void> generateTreeNode(List<TeamDownlineUser> team) async {
    tree = IndexedTreeNode<TeamDownlineUser>.root(
        data: TeamDownlineUser(
            newLevel: 1, username: 'GK123456', nameWithUsername: 'Gaurav Test'))
      ..addAll([
        ...team.map((e) => IndexedTreeNode<TeamDownlineUser>(
                key: e.username,
                data: TeamDownlineUser(
                    newLevel: e.newLevel,
                    username: e.username,
                    nameWithUsername: e.nameWithUsername))
            // ..add(IndexedTreeNode(
            //     key: "0A1A", data: UserName("Jr. John", "Doe"))),
            ),
        //   IndexedTreeNode<UserName>(key: "0A", data: UserName("Sr. John", "Doe"))
        //     ..add(
        //         IndexedTreeNode(key: "0A1A", data: UserName("Jr. John", "Doe"))),
        //   IndexedTreeNode<UserName>(key: "0C", data: UserName("General", "Lee"))
        //     ..addAll([
        //       IndexedTreeNode<UserName>(
        //           key: "0C1A", data: UserName("Major", "Lee")),
        //       IndexedTreeNode<UserName>(
        //           key: "0C1B", data: UserName("Happy", "Lee")),
        //       IndexedTreeNode<UserName>(
        //           key: "0C1C", data: UserName("Busy", "Lee"))
        //         ..addAll([
        //           IndexedTreeNode<UserName>(
        //               key: "0C1C2A", data: UserName("Jr. Busy", "Lee"))
        //         ]),
        //     ]),
        //   IndexedTreeNode<UserName>(
        //       key: "0D", data: UserName("Mr. Anderson", "Neo")),
        //   IndexedTreeNode<UserName>(
        //       key: "0E", data: UserName("Mr. Smith", "Agent")),
      ]);
    if (initialLoading) {
      initialLoading = false;
    }
    notifyListeners();
  }
*/

  Future<void> generateTeams(List<TeamDownlineUser> team) async {
    teams = team;
    if (initialLoading) {
      initialLoading = false;
    }
    notifyListeners();
  }

  Future<void> getDownLines(int level, String id) async {
    // print('TeamViewProvider getDownLines');
    if (isOnline) {
      try {
        setLevel(level, id);
        ApiResponse apiResponse = await teamViewRepo.getDownLines({
          'level': level.toString(),
          'sponser_username': id,
        });
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          List<TeamDownlineUser> levelArray = [];
          try {
            status = map["status"];
            try {
              if (map['is_logged_in'] == 0) {
                logOut();
              }
            } catch (e) {}
            if (status) {
              try {
                map['levelArray'].forEach(
                    (e) => levelArray.add(TeamDownlineUser.fromJson(e)));
                print(levelArray.length);
              } catch (e) {
                print('could not generate the level array $e');
              }
              try {
                if (map['userData'] != null) {
                  sl.get<AuthProvider>().updateUser(map['userData']);
                }
              } catch (e) {}
              try {
                // if (levelArray.isNotEmpty) {
                if (initialLoading) {
                  // print('running... generateTreeNode');
                  // await generateTreeNode(levelArray);

                  //original
                  // await generateTeams(levelArray);
                } else {
                  // print('running... addTreeNodes');
                  // await addTreeNodes(level, id, levelArray);

                  //original
                  // await addTeamNodes(level, id, levelArray);
                  // }
                }
              } catch (e) {
                print('could not generate the generateTreeNode $e');
              }
            }
          } catch (e) {}
        }
      } catch (e) {}
    } else {
      Fluttertoast.showToast(msg: 'No internet connection');
    }
    setLevel(null, null);
  }

  bool loadingTeamMembers = false;
  List<UserData> customerTeam = [];
  Future<void> getCustomerTeam() async {
    loadingTeamMembers = true;
    notifyListeners();
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.myTeam);
    Map? map;
    if (isOnline) {
      ApiResponse apiResponse = await teamViewRepo.getTeamMember();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] == 0) {
            logOut();
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.myTeam, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getCustomerTeam online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.myTeam)).syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getCustomerTeam not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          sl.get<AuthProvider>().updateUser(map["userData"]);
        } catch (e) {}

        try {
          if (map['my_team'] != null && map['my_team'].isNotEmpty) {
            customerTeam.clear();
            map['my_team']
                .forEach((e) => customerTeam.add(UserData.fromJson(e)));
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {
      print('getCustomerTeam failed ${e}');
    }
    loadingTeamMembers = false;
    notifyListeners();
  }

  ButtonLoadingState sendingStatus = ButtonLoadingState.idle;
  String? errorText;
  Future<bool> sendMessage({
    VoidCallback? onError,
    VoidCallback? onSuccess,
    required String userId,
    required String title,
    required String subject,
  }) async {
    bool status = false;

    Map? map;
    Map<String, dynamic> data = {
      "user_id": userId,
      'title': title,
      'subject': subject
    };
    try {
      if (isOnline) {
        sendingStatus = ButtonLoadingState.loading;
        errorText = '';
        notifyListeners();
        ApiResponse apiResponse =
            await teamViewRepo.sendInboxMessageToUser(data);
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          map = apiResponse.response!.data;
          try {
            status = map?["status"] ?? false;
            if (map?['is_logged_in'] == 0) {
              logOut();
            }
            if (status) {
              try {
                sendingStatus = ButtonLoadingState.completed;
                errorText = map?['message'];
                status = true;
                if (onSuccess != null) onSuccess();
                notifyListeners();
              } catch (e) {}
            } else {
              sendingStatus = ButtonLoadingState.failed;
              errorText = map?['message'];
              if (onError != null) onError();
              notifyListeners();
            }
          } catch (e) {}
        }
      } else {
        sendingStatus = ButtonLoadingState.failed;
        errorText = 'failed message';
        if (onError != null) onError();
        notifyListeners();
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 3));
      sendingStatus = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      if (onError != null) onError();
      notifyListeners();
    }
    await Future.delayed(const Duration(seconds: 3));
    sendingStatus = ButtonLoadingState.idle;
    errorText = null;
    notifyListeners();
    return status;
  }

  ///generationAnalyzer
  ///
  List<BreadCrumbContent> breadCrumbContent = [];
  setBreadCrumbContent(int index, [BreadCrumbContent? content]) async {
    loadingGUsers = ButtonLoadingState.loading;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    errorLog(
        'setBreadCrumbContent  ${index} ${breadCrumbContent.length - 1}  replace: ${breadCrumbContent.length - 1 <= index}',
        'index out of range');
    if (content != null) {
      if (breadCrumbContent.isEmpty) {
        breadCrumbContent.insert(index, content);
      } else if (breadCrumbContent.length > index) {
        breadCrumbContent[index] = content;
        breadCrumbContent.removeRange(index + 1, breadCrumbContent.length);
      } else {
        breadCrumbContent.add(content);
      }
    } else {
      breadCrumbContent.removeRange(index, breadCrumbContent.length);
    }

    loadingGUsers = ButtonLoadingState.completed;
    notifyListeners();
  }

  List<GenerationAnalyzerUser> gUsers = [];

  ButtonLoadingState loadingGUsers = ButtonLoadingState.idle;
  setGenerationUsers(int generationId) async {
    loadingGUsers = ButtonLoadingState.loading;
    notifyListeners();
    gUsers.clear();
    gUsers.addAll(generateRandomUsers(generationId));
    await Future.delayed(const Duration(seconds: 1))
        .then((value) => loadingGUsers = ButtonLoadingState.completed);
    notifyListeners();
  }

  generateRandomUsers(int generaionID) {
    List<GenerationAnalyzerUser> users = [];
    for (var i = 0; i < Random().nextInt(50); i++) {
      users.add(GenerationAnalyzerUser(
          name: 'User $i',
          generation: generaionID + 1,
          image: Assets.appLogo_S,
          referralId: Random().nextInt(999999999).toString()));
    }
    return users;
  }
  // Future<void> getGenerationAnalyzer(String username) async {
  //   if (isOnline) {
  //     try {
  //       ApiResponse apiResponse =
  //           await teamViewRepo.getGenerationAnalyzer(username);
  //       if (apiResponse.response != null &&
  //           apiResponse.response!.statusCode == 200) {
  //         Map map = apiResponse.response!.data;
  //         bool status = false;
  //         try {
  //           status = map["status"];
  //           if (map['is_logged_in'] == 0) {
  //             logOut();
  //           }
  //         } catch (e) {}
  //         if (status) {
  //           try {
  //             if (map['userData'] != null) {
  //               sl.get<AuthProvider>().updateUser(map['userData']);
  //             }
  //           } catch (e) {}
  //           try {
  //             if (map['user'] != null) {
  //               gUser.clear();
  //               map['user'].forEach((e) {
  //                 gUser.add(GenerationAnalyzerUser.fromJson(e));
  //               });
  //               notifyListeners();
  //             }
  //           } catch (e) {}
  //         }
  //       }
  //     } catch (e) {}
  //   } else {
  //     Fluttertoast.showToast(msg: 'No internet connection');
  //   }
  // }

  clear() {
    tree = IndexedTreeNode();
    initialLoading = true;
    adding = true;
    loadingLevel = 0;
    widthLevel = 1;
    loadingId = '';
    teams.clear();
    customerTeam.clear();
  }
}
