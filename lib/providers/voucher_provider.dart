import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../utils/app_web_view_page.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/voucher_model.dart';
import '/database/model/response/voucher_package_model.dart';
import '/database/model/response/voucher_package_type.dart';
import '/database/repositories/voucher_repo.dart';
import '/utils/app_default_loading.dart';
import '/utils/default_logger.dart';
import '/utils/toasts.dart';

class VoucherProvider extends ChangeNotifier {
  final VoucherRepo voucherRepo;
  VoucherProvider({required this.voucherRepo});
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  CarouselController carouselController = CarouselController();

  int currentIndex = 0;
  VoucherPackageModel? currentPackage;
  void setCurrentIndex(int page) {
    currentIndex = page;
    currentPackage = packages[page];
    notifyListeners();
  }

  void jumpToPage(dynamic page) {
    controller.jumpTo(page);
    notifyListeners();
  }

  List<VoucherModel> history = [];
  List<VoucherPackageModel> packages = [];
  Map<String, dynamic> paymentTypes = {};

  List<VoucherPackageTypeModel> package1 = [];
  List<VoucherPackageTypeModel> package2 = [];
  Map<String, dynamic> packageTypes = {};
  Map<String, dynamic> admin_per = {};
  double walletBalance = 0.0;

  bool loadingVoucher = false;

  Future<void> getVoucherList(bool loading) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.voucherList);
    List<VoucherModel> _history = [];
    List<VoucherPackageModel> _packages = [];
    Map? map;
    loadingVoucher = loading;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse = await voucherRepo.getVoucherList();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        successLog(map.toString());
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] != 1) {
            logOut('getVoucherList');
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.voucherList, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getCommissionWalletHistory online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.voucherList))
              .syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getCommissionWalletHistory not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          if (map['voucher_list'] != null &&
              map['voucher_list'] != false &&
              map['voucher_list'].isNotEmpty) {
            map['voucher_list']
                .forEach((e) => _history.add(VoucherModel.fromJson(e)));
            _history.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            history.clear();
            history = _history;
            notifyListeners();
          }
        } catch (e) {
          print('voucher_list error $e');
        }

        try {
          if (map['packages'] != null &&
              map['packages'] != false &&
              map['packages'].isNotEmpty) {
            map['packages']
                .forEach((e) => _packages.add(VoucherPackageModel.fromJson(e)));
            packages.clear();
            packages = _packages;
            notifyListeners();
          }
        } catch (e) {
          print('voucher packages error $e');
        }
        try {
          if (map['payment_type'] != null && map['payment_type'].isNotEmpty) {
            paymentTypes.clear();
            map['payment_type'].entries
              ..forEach(
                  (e) => paymentTypes.addEntries([MapEntry(e.key, e.value)]));
            notifyListeners();
          }
        } catch (e) {
          print('voucher payment_type error $e');
        }
      }
    } catch (e) {}
    loadingVoucher = false;
    notifyListeners();
  }

  bool loadingCreateVoucherSubmit = false;
  Future<void> createVoucherSubmit(
      {required String payment_type,
      String package_id = '',
      String sale_type = ''}) async {
    try {
      if (isOnline) {
        showLoading(useRootNavigator: true);
        ApiResponse apiResponse = await voucherRepo.createVoucherSubmit({
          'payment_type': payment_type,
          'package_id': package_id,
          'sale_type': sale_type
        });
        infoLog('create voucher submit ${apiResponse.response?.data}');
        Get.back();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          Map map = apiResponse.response!.data;
          bool status = false;
          String message = '';
          String? redirect_url;
          try {
            status = map["status"];
            if (map['is_logged_in'] == 0) {
              logOut('createVoucherSubmit');
            }
          } catch (e) {}
          try {
            message = map["message"] ?? '';
            redirect_url = map["redirect_url"] ?? '';
          } catch (e) {}

          if (status) {
            await getVoucherList(false);
            Get.back();
            if (redirect_url != '') {
              var res = await Get.to(WebViewExample(
                url: redirect_url,
                allowBack: false,
                allowCopy: false,
                conditions: [
                  'https://mywealthclub.com/api/customer/card-voucher-request-status'
                ],
                onResponse: (res) {
                  print('request url matched <res> $res');
                  Get.back();
                  hitPaymentResponse(res);
                  // getVoucherList(false);
                },
              ));
              errorLog('redirect result from webview $res');
              // launchTheLink(redirect_url!);
            } else {
              Toasts.showSuccessNormalToast(message.split('.').first);
            }
          } else {
            Toasts.showErrorNormalToast(message.split('.').first);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('createVoucherSubmit failed ${e}');
    }
  }

  Future<void> hitPaymentResponse(url) async {
    try {
      if (isOnline) {
        showLoading(useRootNavigator: true);
        ApiResponse apiResponse = await voucherRepo.hitPaymentResponse(url);
        infoLog(
            'create voucher hitPaymentResponse: ${apiResponse.response?.data}');
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
            await getVoucherList(false);
            Get.back();
          } else {
            Toasts.showErrorNormalToast(message.split('.').first);
          }
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('createVoucherSubmit failed ${e}');
    }
  }

/*
  ///voucherList selection
  TextEditingController amountController = TextEditingController();

  bool loadingVoucherPackages = false;
  Future<void> getPackageType() async {
    List<VoucherPackageTypeModel> _package1 = [];
    List<VoucherPackageTypeModel> _package2 = [];
    Map? map;
    loadingVoucherPackages = true;
    notifyListeners();
    bool cacheExist =
    await APICacheManager().isAPICacheKeyExist(AppConstants.createVoucher);
    try {
      if (isOnline) {
        ApiResponse apiResponse = await voucherRepo.getPackageType();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map?["status"];
            if (map?['is_logged_in'] != 1) {
              logOut();
            }
          } catch (e) {}
          try {
            if (status && map != null) {
              try {
                var cacheModel = APICacheDBModel(
                    key: AppConstants.createVoucher, syncData: jsonEncode(map));
                await APICacheManager().addCacheData(cacheModel);
              } catch (e) {}
            }
          } catch (e) {
            print('getPackageType online hit failed \n $e');
          }
        } else if (!isOnline && cacheExist) {
          var cacheData =
              (await APICacheManager().getCacheData(AppConstants.createVoucher))
                  .syncData;
          map = jsonDecode(cacheData);
        } else {
          print('getPackageType not online not cache exist ');
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('getPackageType failed ${e}');
    }
    if (map != null) {
      try {
        if (map['wallet_balance'] != null && map['wallet_balance'] != '') {
          walletBalance = double.parse(map['wallet_balance']);
          notifyListeners();
        }
      } catch (e) {}
      try {
        if (map['package_1'] != null && map['package_1'].isNotEmpty) {
          map['package_1'].forEach(
                  (e) => _package1.add(VoucherPackageTypeModel.fromJson(e)));
          package1.clear();
          package1 = _package1;
          notifyListeners();
        }
      } catch (e) {
        print('package_1 error $e');
      }
      try {
        if (map['package_2'] != null && map['package_2'].isNotEmpty) {
          map['package_2'].forEach(
                  (e) => _package2.add(VoucherPackageTypeModel.fromJson(e)));
          package2.clear();
          package2 = _package2;
          notifyListeners();
        }
      } catch (e) {
        print('package_2 error $e');
      }
      try {
        if (map['package_type'] != null) {
          packageTypes.clear();
          map['package_type'].entries.toList().forEach(
                  (e) => packageTypes.addEntries([MapEntry(e.key, e.value)]));
          print('package_type types ${packageTypes} ');
          notifyListeners();
        }
      } catch (e) {
        print('package_type error === $e');
      }
    }
    loadingVoucherPackages = false;
    notifyListeners();
    print('types ${packageTypes}, package 1 ${package1}  package2 ${package2}');
  }
*/

  clear() {
    history.clear();
    package1.clear();
    package2.clear();
    packageTypes.clear();
    walletBalance = 0.0;
    loadingVoucher = false;
  }
}
