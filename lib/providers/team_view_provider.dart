import 'dart:convert';
import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../database/model/response/abstract_user_model.dart';
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
  setGenerationUsers(String username) async {
    loadingGUsers = ButtonLoadingState.loading;
    notifyListeners();
    gUsers.clear();
    gUsers.addAll(generateRandomUsers(username, selectedGeneration));
    await getGenerationAnalyzer(username);
    await Future.delayed(const Duration(seconds: 1))
        .then((value) => loadingGUsers = ButtonLoadingState.completed);
    notifyListeners();
  }

  generateRandomUsers(String username, int generaionID) {
    List<GenerationAnalyzerUser> users = [];
    for (var i = 0; i < Random().nextInt(50); i++) {
      users.add(GenerationAnalyzerUser(
        name: 'User $i',
        generation: generaionID + 1,
        image: Assets.appLogo_S,
        referralId: username,
      ));
    }
    return users;
  }

  int selectedGeneration = 0;
  setSelectedGeneration(int val) {
    selectedGeneration = val;
    notifyListeners();
  }

  Future<List<GenerationAnalyzerUser>> getGenerationAnalyzer(
      String username) async {
    List<GenerationAnalyzerUser> gUsers = [];
    if (isOnline) {
      try {
        var data = {
          'username': username,
          'generation': selectedGeneration,
        };
        print('getGenerationAnalyzer post data: $data');
        ApiResponse apiResponse =
            await teamViewRepo.getGenerationAnalyzer(data);
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut();
            }
          } catch (e) {}
          if (status) {
            try {
              if (map['user'] != null) {
                // gUser.clear();
                // map['user'].forEach((e) {
                //   gUser.add(GenerationAnalyzerUser.fromJson(e));
                // });
                // notifyListeners();
              }
            } catch (e) {}
          }
        }
      } catch (e) {}
    } else {
      Fluttertoast.showToast(msg: 'No internet connection');
    }
    return gUsers;
  }

//Liquid user

  bool loadingLoquidUser = false;
  List<UserData> liquidUsers = [];
  Future<void> getLiquidUsers() async {
    loadingLoquidUser = true;
    notifyListeners();
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.liquidUser);
    Map? map;
    if (isOnline) {
      ApiResponse apiResponse = await teamViewRepo.liquidUser({});
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
                  key: AppConstants.liquidUser, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('liquidUser online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.liquidUser))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('liquidUser not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['direct_child'] != null && map['direct_child'].isNotEmpty) {
            liquidUsers.clear();
            map['direct_child']
                .forEach((e) => liquidUsers.add(UserData.fromJson(e)));
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {
      print('liquidUser failed ${e}');
    }
    loadingLoquidUser = false;
    notifyListeners();
  }

// get matrix user api

  Future<List<MatrixUser>> getMatrixUsers(Map<String, dynamic> data) async {
    List<MatrixUser> matrixUsers = [];

    Map? map;
    if (isOnline) {
      ApiResponse apiResponse = await teamViewRepo.matrixAnalyzer(data);
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
      }
    } else {
      print('getMatrixUsers not online not cache exist ');
    }
    print('getMatrixUsers online hit success data: $map');

    try {
      if (map != null) {
        try {
          if (map['client_tree'] != null && map['client_tree'].isNotEmpty) {
            matrixUsers.clear();
            map['client_tree']
                .forEach((e) => matrixUsers.add(MatrixUser.fromJson(e)));
            notifyListeners();
          }
        } catch (e) {
          print('getMatrixUsers failed ${e}');
        }
      }
    } catch (e) {
      print('getMatrixUsers failed ${e}');
    }
    print('getMatrixUsers return matrixUsers: $matrixUsers');
    return matrixUsers;
  }

  clear() {
    tree = IndexedTreeNode();
    initialLoading = true;
    adding = true;
    loadingLevel = 0;
    widthLevel = 1;
    loadingId = '';
    customerTeam.clear();

    sendingStatus = ButtonLoadingState.idle;
    errorText = null;
    breadCrumbContent.clear();
    gUsers.clear();
    loadingGUsers = ButtonLoadingState.idle;
    liquidUsers.clear();
    loadingLoquidUser = false;
    selectedGeneration = 0;
  }
}
