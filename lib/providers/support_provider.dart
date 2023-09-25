import 'dart:async';
import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/SuportDepartment.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/ticket_modal.dart';
import '/database/model/response/ticket_reply.dart';
import '/database/model/response/ticket_status_model.dart';
import '/database/repositories/support_repo.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/toasts.dart';

class SupportProvider extends ChangeNotifier {
  final SupportRepo supportRepo;
  SupportProvider({required this.supportRepo});

  List<TicketModel> tickets = [];
  List<SupportDepartment> departments = [];
  List<TicketStatusModel> ticket_status_list = [];
  Map<String, dynamic> priorities = {};
  int open_ticket = 0;
  int in_progress_ticket = 0;
  int answered_ticket = 0;
  int hold_ticket = 0;
  int closed_ticket = 0;
  bool loadingTickets = false;

  //get tickets
  Future<void> getTickets([bool? loading]) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.support);
    Map? map;
    Map<String, dynamic> _priorities = {};
    loadingTickets = loading ?? true;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse = await supportRepo.getSupport();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
        } catch (e) {}
        try {
          if (map?['is_logged_in'] == 0) {
            logOut();
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.support, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
            try {
              sl.get<AuthProvider>().updateUser(map?["userData"]);
            } catch (e) {}
          }
        } catch (e) {
          print('getTickets online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.support)).syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getTickets not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          tickets.clear();
          if (map['ticket_list'] != false && map['ticket_list'].isNotEmpty) {
            map['ticket_list']
                .forEach((e) => tickets.add(TicketModel.fromJson(e)));
            tickets.sort((a, b) => (b.lastreply ?? b.date ?? '')
                .compareTo(a.lastreply ?? a.date ?? ''));
            notifyListeners();
          }
        } catch (e) {
          print('Error in get tickets  ticket_list generation $e');
        }
        try {
          departments.clear();
          if (map['department'] != false && map['department'].isNotEmpty) {
            map['department']
                .forEach((e) => departments.add(SupportDepartment.fromJson(e)));
            notifyListeners();
          }
        } catch (e) {
          print('Error in get tickets  departments generation $e');
        }
        try {
          ticket_status_list.clear();
          if (map['ticket_status'] != false &&
              map['ticket_status'].isNotEmpty) {
            map['ticket_status'].forEach(
                (e) => ticket_status_list.add(TicketStatusModel.fromJson(e)));

            notifyListeners();
          }
        } catch (e) {
          print('Error in get tickets  ticket_status generation $e');
        }
        try {
          if (map['prority'] != null) {
            map['prority'].entries.toList().forEach(
                (e) => _priorities.addEntries([MapEntry(e.key, e.value)]));
            priorities.clear();
            priorities = _priorities;
            notifyListeners();
          }
        } catch (e) {
          print('payment types error === $e');
        }
        try {
          open_ticket = map["open_ticket"] ?? 0;
          in_progress_ticket = map["in_progress_ticket"] ?? 0;
          answered_ticket = map["answered_ticket"] ?? 0;
          hold_ticket = map["hold_ticket"] ?? 0;
          closed_ticket = map["closed_ticket"] ?? 0;
        } catch (e) {
          print('Error in get tickets  tickets counts generation $e');
        }
      }
    } catch (e) {
      print('Error in get tickets ');
    }
    loadingTickets = false;
    notifyListeners();
  }

  ///TicketReply
  List<TicketReply> replies = [];
  TicketModel? currentTicket;
  bool loadingFirst = true;
  bool loadingTicketDetails = false;
  String? attachment_url;
  Future<List<TicketReply>> getTicketDetail(String ticketId) async {
    bool cacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.ticketDetail + ticketId);
    List<TicketReply> _replies = [];
    Map? map;
    loadingTicketDetails = loadingFirst;
    loadingFirst = true;

    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse =
          await supportRepo.getTicketDetails({'ticket_id': ticketId});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
        } catch (e) {}
        try {
          if (map?['is_logged_in'] == 0) {
            logOut();
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.ticketDetail + ticketId,
                  syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
            try {
              if (map?['userData'] != null) {
                sl.get<AuthProvider>().updateUser(map?['userData']);
              }
            } catch (e) {}
          }
        } catch (e) {
          print('getTickets online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData = (await APICacheManager()
              .getCacheData(AppConstants.ticketDetail + ticketId))
          .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getTickets not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          replies.clear();
          if (map['ticket_replies'] != false &&
              map['ticket_replies'].isNotEmpty) {
            map['ticket_replies']
                .forEach((e) => replies.add(TicketReply.fromJson(e)));
            notifyListeners();
            _replies = replies;

            notifyListeners();
          }
        } catch (e) {
          print('Error in getTicketDetail ticket_replies   generations $e');
        }
        try {
          attachment_url = map['attachment_url'];
          currentTicket = TicketModel.fromJson(map['ticket']);
          notifyListeners();
        } catch (e) {}
      }
    } catch (e) {
      print('Error getTicketDetail  ticket_replies ');
    }
    loadingFirst = false;
    loadingTicketDetails = false;
    if (sendingMessage) {
      sendingMessage = false;
    }
    notifyListeners();

    return _replies;
  }

  ///reply
  TextEditingController messageController = TextEditingController();
  bool sendingMessage = false;
  Future<bool> reply() async {
    sendingMessage = true;
    notifyListeners();
    // scrollController.animateTo(scrollController.position.maxScrollExtent,
    //     duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    if (isOnline) {
      ApiResponse apiResponse = await supportRepo.ticketReplySubmit({
        'ticket_id': currentTicket?.ticketid,
        'message': '${messageController.text}'
      });
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        Map map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map["status"];
          try {
            if (map['is_logged_in'] == 0) {
              logOut();
            }
          } catch (e) {}
          sendingMessage = false;
          notifyListeners();
          if (status) {
            messageController.clear();
            notifyListeners();
            try {
              if (map['userData'] != null) {
                sl.get<AuthProvider>().updateUser(map['userData']);
              }
            } catch (e) {}
          } else {
            Fluttertoast.showToast(
                msg: map["message"],
                backgroundColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.black,
                fontSize: 11);
          }
          return status;
        } catch (e) {}
        try {
          if (status) {
            try {} catch (e) {}
          }
        } catch (e) {
          print('getTickets online hit failed \n $e');
        }
      }
    } else {
      Toasts.showWarningNormalToast('You are offline');
    }
    // sendingMessage = false;
    // notifyListeners();
    return false;
  }

  bool creatingNewTicket = false;
  Future<bool> newTicketSubmit(String subject, String department,
      String priority, String message) async {
    creatingNewTicket = true;
    notifyListeners();
    try {
      primaryFocus?.unfocus();
      if (isOnline) {
        showLoading();
        ApiResponse apiResponse = await supportRepo.newTicketSubmit({
          'subject': subject,
          'department': department,
          'priority': priority,
          'message': message
        });
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map["status"];
            try {
              if (map['is_logged_in'] == 0) {
                logOut();
              }
            } catch (e) {}
            sendingMessage = false;
            notifyListeners();
            if (status) {
              await getTickets().then((value) => Get.back()).then(
                  (value) => Toasts.showSuccessNormalToast(map['message']));
            } else {
              Future.delayed(
                  Duration(milliseconds: 500),
                  () => Toasts.showErrorNormalToast(
                      map['message'].split('.').first));
              // Fluttertoast.showToast(
              //     msg: map["message"], backgroundColor: appLogoColor);
            }
            return status;
          } catch (e) {}
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Some thing went wrong! Try again', backgroundColor: Colors.red);
    }
    // creatingNewTicket = false;
    // notifyListeners();
    return false;
  }

  clear() {
    tickets = [];
    departments = [];
    ticket_status_list = [];
    priorities.clear();
    loadingTickets = false;
    replies = [];
    currentTicket = null;
    loadingFirst = true;
    loadingTicketDetails = false;
    messageController.clear();
  }
}
