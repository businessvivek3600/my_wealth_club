import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/commission_wallet_bank_detail_model.dart';
import '/database/model/response/commission_wallet_history_model.dart';
import '/database/repositories/commission_wallet_repo.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/sl_container.dart';
import '/utils/app_default_loading.dart';
import '/utils/toasts.dart';

class CommissionWalletProvider extends ChangeNotifier {
  final CommissionWalletRepo commissionWalletRepo;
  CommissionWalletProvider({required this.commissionWalletRepo});
  List<CommissionWalletHistory> history = [];
  List<CommissionWalletBankDetail> banks = [];
  Map<String, dynamic> paymentTypes = {};
  Map<String, dynamic> admin_per = {};
  double walletBalance = 0.0;
  double minimumBalance = 0.0;
  bool loadingWallet = false;
  bool btn_withdraw = false;
  bool btn_transfer = false;

  Future<void> getCommissionWallet() async {
    bool cacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.commissionWallet);
    List<CommissionWalletHistory> _history = [];
    Map? map;
    loadingWallet = true;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse =
          await commissionWalletRepo.getCommissionWallet();
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
                  key: AppConstants.commissionWallet,
                  syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getCommissionWalletHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.commissionWallet))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getCommissionWalletHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['wallet_balance'] != null && map['wallet_balance'] != '') {
            walletBalance = double.parse(map['wallet_balance'].toString());
            notifyListeners();
          }
        } catch (e) {
          print('getSubscription Error in balance $e');
        }
        try {
          if (map['userData'] != null) {
            sl.get<AuthProvider>().updateUser(map['userData']);
          }
        } catch (e) {}
        try {
          if (map['btn_withdraw'] != null) {
            btn_withdraw = map['btn_withdraw'] == 1;
            notifyListeners();
          }
          if (map['btn_transfer'] != null) {
            btn_transfer = map['btn_transfer'] == 1;
            notifyListeners();
          }
        } catch (e) {}

        try {
          if (map['wallet_history'] != null &&
              map['wallet_history'].isNotEmpty) {
            map['wallet_history'].forEach(
                (e) => _history.add(CommissionWalletHistory.fromJson(e)));
            _history.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            history.clear();
            history = _history;
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {}
    loadingWallet = false;
    notifyListeners();
  }

  ///commissionWallet selection
  TextEditingController amountController = TextEditingController();
  TextEditingController emailOtpController = TextEditingController();

  bool loadingWithdrawRequestData = false;
  Future<void> getCommissionWithdrawRequest() async {
    List<CommissionWalletBankDetail> _banks = [];
    loadingWithdrawRequestData = true;
    notifyListeners();
    try {
      if (isOnline) {
        ApiResponse apiResponse =
            await commissionWalletRepo.getCommissionWithdrawRequest();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirectUrl;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut();
            }
          } catch (e) {}

          if (status) {
            if (map != null) {
              try {
                if (map['wallet_balance'] != null &&
                    map['wallet_balance'] != '') {
                  walletBalance = double.parse(map['wallet_balance']);
                  amountController.text = walletBalance.toStringAsFixed(0);
                  notifyListeners();
                }
              } catch (e) {}
              try {
                sl.get<AuthProvider>().updateUser(map["userData"]);
              } catch (e) {}
              try {
                if (map['minimum_amt'] != null && map['minimum_amt'] != '') {
                  minimumBalance = double.parse(map['minimum_amt']);
                  notifyListeners();
                }
              } catch (e) {}
              try {
                if (map['bank'] != null) {
                  _banks.add(CommissionWalletBankDetail.fromJson(map['bank']));
                  banks.clear();
                  banks = _banks;
                  notifyListeners();
                }
              } catch (e) {
                print('bank error $e');
              }
              try {
                if (map['payment_type'] != null) {
                  paymentTypes.clear();
                  map['payment_type'].entries.toList().forEach((e) =>
                      paymentTypes.addEntries([MapEntry(e.key, e.value)]));
                  notifyListeners();
                }
              } catch (e) {
                print('payment types error === $e');
              }
              try {
                if (map['admin_per'] != null) {
                  admin_per.clear();
                  map['admin_per'].entries.toList().forEach(
                      (e) => admin_per.addEntries([MapEntry(e.key, e.value)]));
                  notifyListeners();
                }
              } catch (e) {
                print('admin_per error === $e');
              }
            }
          } else {
            Toasts.showErrorNormalToast(map["message"].split('.').first);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('buySubscription failed ${e}');
    }
    loadingWithdrawRequestData = false;
    notifyListeners();
  }

  bool loadingWithdrawSubmit = false;
  Future<void> withdrawSubmit(String walletType, String paymentType) async {
    // loadingWithdrawSubmit = true;
    // notifyListeners();
    try {
      if (isOnline) {
        showLoading(useRootNavigator: true);
        ApiResponse apiResponse =
            await commissionWalletRepo.commissionWithdrawRequestSubmit({
          'wallet_type': walletType,
          'payment_type': paymentType,
          'email_otp': emailOtpController.text,
          'amount': amountController.text,
        });
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirectUrl;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) logOut();
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}
          try {
            sl.get<AuthProvider>().updateUser(map["userData"]);
          } catch (e) {}
          if (status) {
            await getCommissionWallet();
            sl.get<DashBoardProvider>().getCustomerDashboard();
            Get.back();
          }
          // Toasts.showNormalToast(message.split('.').first, error: !status);
          status
              ? Toasts.showSuccessNormalToast(message.split('.').first)
              : Toasts.showErrorNormalToast(message.split('.').first);
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('withdrawSubmit failed ${e}');
    }
    // loadingWithdrawSubmit = false;
    // notifyListeners();
  }

  bool loadingTransferToCashWallet = false;
  Future<void> transferToCashWallet(String amount) async {
    // loadingTransferToCashWallet = true;
    // notifyListeners();
    try {
      if (isOnline) {
        showLoading();
        ApiResponse apiResponse =
            await commissionWalletRepo.transferToCashWallet({'amount': amount});
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirectUrl;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut();
            }
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}

          if (status) {
            await getCommissionWallet();
            sl.get<DashBoardProvider>().getCustomerDashboard();
            Get.back();
          }
          status
              ? Toasts.showSuccessNormalToast(message.split('.').first)
              : Toasts.showErrorNormalToast(message.split('.').first);
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('withdrawSubmit failed ${e}');
    }
    // loadingTransferToCashWallet = false;
    // notifyListeners();
  }

  //email
  Future<void> getEmailOtp() async {
    try {
      if (isOnline) {
        showLoading();
        late ApiResponse apiResponse;
        try {
          apiResponse = await commissionWalletRepo.getWithdrawEmailToken();
        } catch (e) {}
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {}
          } catch (e) {}
          try {
            message = map["message"];
          } catch (e) {}
          // Toasts.showNormalToast(message.split('.').first, error: !status);
          status
              ? Toasts.showSuccessNormalToast(message.split('.').first)
              : Toasts.showErrorNormalToast(message.split('.').first);
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('withdrawSubmit failed ${e}');
    }
  }

  clear() {
    history.clear();
    banks.clear();
    paymentTypes.clear();
    history.clear();
    amountController.clear();
    emailOtpController.clear();
    walletBalance = 0.0;
    minimumBalance = 0.0;
    loadingWallet = false;
    loadingWallet = false;
    btn_withdraw = false;
    btn_transfer = false;
  }
}
