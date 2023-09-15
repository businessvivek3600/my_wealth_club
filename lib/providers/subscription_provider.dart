import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/subscription_history_model.dart';
import '/database/model/response/subscription_package_model.dart';
import '/database/model/response/subscription_request_history_model.dart';
import '/database/repositories/subscription_repo.dart';
import '/myapp.dart';
import '/providers/auth_provider.dart';
import '/screens/auth/login_screen.dart';
import '/screens/card_form/card_form_widget.dart';
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
  bool loadingSub = false;

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
      ApiResponse apiResponse = await subscriptionRepo.getSubscription();
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
          if (map['customer_renewal'] != null &&
              map['customer_renewal'] != '') {
            customerRenewal = map['customer_renewal'] == 1;
            notifyListeners();
          }
          if (map['joining_price_id'] != null &&
              map['joining_price_id'] != '') {
            joiningPriceId = map['joining_price_id'];
            notifyListeners();
          }
          if (map['balance_mcc_commission'] != null &&
              map['balance_mcc_commission'] != '') {
            commissionMBal = map['balance_mcc_commission'].toDouble();
            notifyListeners();
          }
          if (map['balance_ng_amgen'] != null &&
              map['balance_ng_amgen'] != '') {
            amgenBal = map['balance_ng_amgen'].toDouble();
            notifyListeners();
          }
          if (map['balance_ng_commission'] != null &&
              map['balance_ng_commission'] != '') {
            commissionNBal = map['balance_ng_commission'].toDouble();
            notifyListeners();
          }
          if (map['balance_ng_cash'] != null && map['balance_ng_cash'] != '') {
            cashNBal = map['balance_ng_cash'].toDouble();
            notifyListeners();
          }
        } catch (e) {
          print('getSubscription Error in balance $e');
        }

        try {
          if (map['buy_package'] != null && map['buy_package'].isNotEmpty) {
            map['buy_package']
                .forEach((e) => _history.add(SubscriptionHistory.fromJson(e)));
            _history.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            history.clear();
            history = _history;
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
          if (map['package_request'] != null &&
              map['package_request'].isNotEmpty) {
            map['package_request'].forEach((e) =>
                _requestHistory.add(SubscriptionRequestHistory.fromJson(e)));
            _requestHistory
                .sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            requestHistory.clear();
            requestHistory = _requestHistory;
            notifyListeners();
          }
        } catch (e) {}
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

  ///subscription selection
  TextEditingController typeController = TextEditingController();
  TextEditingController voucherController = TextEditingController();
  SubscriptionPackage? selectedPackage;
  String? selectedTypeKey;
  setSelectedTypeKey(val) {
    selectedTypeKey = val;
    notifyListeners();
  }

  Future<void> buySubscription(SubscriptionPackage package) async {
    try {
      if (isOnline) {
        showLoading();
        ApiResponse apiResponse = await subscriptionRepo.buySubscription({
          "package": '${selectedPackage?.packageId ?? ' '}',
          "payment_type": selectedTypeKey ?? '',
          "epin_code": voucherController.text
        });
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
              logOut();
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
              if (redirectUrl != null) {
                launchTheLink(redirectUrl);
                Get.back();
                // Get.back();
              }
              if (orderId != null) {
                Get.to(CardFormWidget(
                    subscriptionPackage: package, orderId: orderId));
              }
              Toasts.showSuccessNormalToast(message.split('.').first);
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

  ///TODO: Stripe Payment

  clear() {
    history = [];
    packages = [];
    requestHistory = [];
    paymentTypes = {};
    commissionMBal = 0.0;
    amgenBal = 0.0;
    commissionNBal = 0.0;
    cashNBal = 0.0;
    loadingSub = false;
    typeController = TextEditingController();
    voucherController = TextEditingController();
    selectedPackage = null;
    selectedTypeKey = null;
  }
}
