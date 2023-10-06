import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mycarclub/utils/app_web_view_page.dart';
import 'package:mycarclub/utils/default_logger.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/subscription_history_model.dart';
import '/database/model/response/subscription_package_model.dart';
import '/database/model/response/subscription_request_history_model.dart';
import '/database/repositories/subscription_repo.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/toasts.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepo subscriptionRepo;
  SubscriptionProvider({required this.subscriptionRepo});
  List<SubscriptionHistory> history = [];
  List<SubscriptionPackage> packages = [];
  List<SubscriptionRequestHistory> requestHistory = [];
  Map<String, dynamic> paymentTypes = {};
  double commissionMBal = 0.0;
  double amgenBal = 0.0;
  double commissionNBal = 0.0;
  double cashNBal = 0.0;
  bool customerRenewal = false;
  String? joiningPriceId;

  ///subscription history
  bool loadingSub = false;
  int subPage = 0;
  int totalSubscriptions = 0;

  Future<void> getSubscription([bool? loading]) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.mySubscription);
    List<SubscriptionHistory> _history = [];
    List<SubscriptionPackage> _packages = [];
    List<SubscriptionRequestHistory> _requestHistory = [];
    Map<String, dynamic> _paymentTypes = {};
    Map? map;
    loadingSub = loading ?? true;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse =
          await subscriptionRepo.getSubscription({"page": subPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getSubscription');
          }
        } catch (e) {}

        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.mySubscription, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
            try {
              if (map?['userData'] != null) {
                sl.get<AuthProvider>().updateUser(map?['userData']);
              }
            } catch (e) {}
          }
        } catch (e) {
          print('getSubscriptionHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.mySubscription))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getSubscriptionHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['totalRows'] != null && map['totalRows'] != '') {
            totalSubscriptions = int.parse(map['totalRows'] ?? '0');
          }
          if (map['buy_package'] != null && map['buy_package'].isNotEmpty) {
            map['buy_package']
                .forEach((e) => _history.add(SubscriptionHistory.fromJson(e)));
            _history.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            if (subPage == 0) {
              history.clear();
              history = _history;
            } else {
              history.addAll(_history);
            }
            subPage++;
            notifyListeners();
          }
        } catch (e) {}
        try {
          if (map['packages'] != null && map['packages'].isNotEmpty) {
            map['packages']
                .forEach((e) => _packages.add(SubscriptionPackage.fromJson(e)));
            packages.clear();
            packages = _packages;
            notifyListeners();
          }
        } catch (e) {
          print('SubscriptionPackage error $e');
        }
        try {
          if (map['payment_type'] != null) {
            map['payment_type'].entries.toList().forEach(
                (e) => _paymentTypes.addEntries([MapEntry(e.key, e.value)]));
            paymentTypes.clear();
            paymentTypes = _paymentTypes;

            notifyListeners();
          }
        } catch (e) {
          print('payment types error === $e');
        }
      }
    } catch (e) {}
    loadingSub = false;
    notifyListeners();
  }

  ///subscription Request history
  bool loadingReqSub = false;
  int subReqPage = 0;
  int totalReqSubscriptions = 0;

  Future<void> getSubscriptionRequestHistory([bool? loading]) async {
    bool cacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.subscriptionRequestHistory);
    List<SubscriptionRequestHistory> _requestHistory = [];
    Map? map;
    loadingReqSub = loading ?? true;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse = await subscriptionRepo
          .subscriptionRequestHistory({"page": subReqPage.toString()});
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('subscriptionRequestHistory');
          }
        } catch (e) {}

        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.subscriptionRequestHistory,
                  syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('subscriptionRequestHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData = (await APICacheManager()
              .getCacheData(AppConstants.subscriptionRequestHistory))
          .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getSubscriptionHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['totalRows'] != null && map['totalRows'] != '') {
            totalReqSubscriptions =
                int.parse(map['total_subscriptions'] ?? '0');
          }
          if (map['package_request'] != null &&
              map['package_request'].isNotEmpty) {
            map['package_request'].forEach((e) =>
                _requestHistory.add(SubscriptionRequestHistory.fromJson(e)));
            _requestHistory
                .sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            if (subReqPage == 0) {
              requestHistory.clear();
              requestHistory = _requestHistory;
            } else {
              requestHistory.addAll(_requestHistory);
            }
            subReqPage++;
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {}
    loadingReqSub = false;
    notifyListeners();
  }

  ///subscription selection
  TextEditingController typeController = TextEditingController();
  TextEditingController voucherController = TextEditingController();
  SubscriptionPackage? selectedPackage;
  String? selectedPaymentTypeKey;
  setSelectedTypeKey(val) {
    selectedPaymentTypeKey = val;
    notifyListeners();
  }

  Future<void> buySubscription(SubscriptionPackage package) async {
    try {
      if (isOnline) {
        showLoading();
        ApiResponse apiResponse = await subscriptionRepo.buySubscription({
          "package": '${selectedPackage?.packageId ?? ' '}',
          "payment_type": selectedPaymentTypeKey ?? '',
          "epin_code": voucherController.text
        });
        infoLog('buySubscription online hit  ${apiResponse.response?.data}');
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirectUrl;
          String? orderId;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('buySubscription');
            }
          } catch (e) {}
          try {
            redirectUrl = map["redirect_url"];
          } catch (e) {}
          try {
            orderId = map["order_id"];
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}
          try {
            sl.get<AuthProvider>().updateUser(map["userData"]);
          } catch (e) {}
          try {
            if (orderId == null) {
              await getSubscription(false);
            }
            if (status) {
              Get.back();
              if (redirectUrl != '') {
                var res = await Get.to(WebViewExample(
                  url: redirectUrl,
                  allowBack: false,
                  allowCopy: false,
                  conditions: [
                    'https://mywealthclub.com/api/customer/card-subscription-request-status'
                  ],
                  onResponse: (res) {
                    print('request url matched <res> $res');
                    Get.back();
                    hitPaymentResponse(res);
                    // getVoucherList(false);
                  },
                ));
                errorLog('redirect result from webview $res');
                // launchTheLink(redirectUrl!);
              }
              //else if (orderId != null) {
              //   Get.to(CardFormWidget(
              //       subscriptionPackage: package, orderId: orderId));
              // }
              else {
                Toasts.showSuccessNormalToast(message.split('.').first);
              }
            } else {
              Toasts.showErrorNormalToast(message.split('.').first);
            }
            Toasts.showNormalToast(message.split('.').first, error: !status);
            // status==false
            //     ? Toasts.showSuccessNormalToast(message.split('.').first)
            //     : Toasts.showErrorNormalToast(message.split('.').first);
          } catch (e) {
            print('buySubscription online hit failed \n $e');
          }
        }
      } else {
        Future.delayed(Duration(seconds: 1),
            () => Toasts.showWarningNormalToast('You are offline'));
      }
    } catch (e) {
      print('buySubscription failed ${e}');
    }
    Get.back();
  }

  Future<void> hitPaymentResponse(url) async {
    try {
      if (isOnline) {
        showLoading(dismissable: true);
        ApiResponse apiResponse =
            await subscriptionRepo.hitPaymentResponse(url);
        infoLog(
            'create subscription hitPaymentResponse: ${apiResponse.response?.data}');
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('hitPaymentResponse');
            }
          } catch (e) {}
          try {
            message = map["message"] ?? '';
          } catch (e) {}

          if (status) {
            await getSubscription(false);
            Get.back();
          } else {
            Toasts.showErrorNormalToast(message);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('createVoucherSubmit failed ${e}');
    }
  }

  ///TODO: Stripe Payment

  clear() {
    history = [];
    packages = [];
    requestHistory = [];
    subPage = 0;
    totalSubscriptions = 0;
    subReqPage = 0;
    totalReqSubscriptions = 0;

    paymentTypes = {};
    commissionMBal = 0.0;
    amgenBal = 0.0;
    commissionNBal = 0.0;
    cashNBal = 0.0;
    loadingSub = false;
    typeController = TextEditingController();
    voucherController = TextEditingController();
    selectedPackage = null;
    selectedPaymentTypeKey = null;
  }
}
