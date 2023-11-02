import 'dart:convert';

import '/utils/default_logger.dart';

class CompanyInfoModel {
  String? companyId;
  String? companyName;
  String? email;
  String? address;
  String? mobile;
  String? website;
  String? businessPlan;
  String? pdf;
  String? ppt;
  String? video;
  String? username;
  String? news;
  String? btcAdminPer;
  String? cUsdttAdminPer;
  String? cUsdtbAdminPer;
  String? cBankAdminPer;
  String? cMinimumWithdraw;
  String? cMinimumTransfer;
  String? cTransactionPer;
  String? ngCMinimumTransfer;
  String? ngCTransactionPer;
  String? wCommission;
  String? tCommission;
  String? tCash;
  String? fCWCoinpayment;
  String? fCWCard;
  String? fCWNgcash;
  String? euroToUsdt;
  String? usdToEuro;
  String? popupImg;
  List<Map<String, dynamic>>? popupImage;
  String? runCronVal;
  String? runCronDeactiveClient;
  String? autoDeductAmgn;
  String? status;
  String? webIsLogin;
  String? webIsSignup;
  String? webIsSubscription;
  String? webIsCashWallet;
  String? webIsCommissionWallet;
  String? webIsVoucher;
  String? webIsEvent;
  String? webChatDisabled;
  String? mobileIsLogin;
  String? mobileIsSignup;
  String? mobileIsSubscription;
  String? mobileIsCashWallet;
  String? mobileIsCommissionWallet;
  String? mobileIsVoucher;
  String? mobileIsEvent;
  String? mobileChatDisabled;
  String? mobileAppDisabled;
  String? android_version;
  String? ios_version;
  String? test_android;
  String? test_ios;
  String? popup_url;

  CompanyInfoModel({
    this.companyId,
    this.companyName,
    this.email,
    this.address,
    this.mobile,
    this.website,
    this.businessPlan,
    this.pdf,
    this.ppt,
    this.video,
    this.username,
    this.news,
    this.btcAdminPer,
    this.cUsdttAdminPer,
    this.cUsdtbAdminPer,
    this.cBankAdminPer,
    this.cMinimumWithdraw,
    this.cMinimumTransfer,
    this.cTransactionPer,
    this.ngCMinimumTransfer,
    this.ngCTransactionPer,
    this.wCommission,
    this.tCommission,
    this.tCash,
    this.fCWCoinpayment,
    this.fCWCard,
    this.fCWNgcash,
    this.euroToUsdt,
    this.usdToEuro,
    this.popupImg,
    this.popupImage,
    this.runCronVal,
    this.runCronDeactiveClient,
    this.autoDeductAmgn,
    this.status,
    this.webIsLogin,
    this.webIsSignup,
    this.webIsSubscription,
    this.webIsCashWallet,
    this.webIsCommissionWallet,
    this.webIsVoucher,
    this.webIsEvent,
    this.webChatDisabled,
    this.mobileIsLogin,
    this.mobileIsSignup,
    this.mobileIsSubscription,
    this.mobileIsCashWallet,
    this.mobileIsCommissionWallet,
    this.mobileIsVoucher,
    this.mobileIsEvent,
    this.mobileChatDisabled,
    this.mobileAppDisabled,
    this.android_version,
    this.ios_version,
    this.test_android,
    this.test_ios,
    this.popup_url,
  });

  CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'];
    companyName = json['company_name'];
    email = json['email'];
    address = json['address'];
    mobile = json['mobile'];
    website = json['website'];
    businessPlan = json['business_plan'];
    pdf = json['pdf'];
    ppt = json['ppt'];
    video = json['video'];
    username = json['username'];
    news = json['news'];
    btcAdminPer = json['btc_admin_per'];
    cUsdttAdminPer = json['c_usdtt_admin_per'];
    cUsdtbAdminPer = json['c_usdtb_admin_per'];
    cBankAdminPer = json['c_bank_admin_per'];
    cMinimumWithdraw = json['c_minimum_withdraw'];
    cMinimumTransfer = json['c_minimum_transfer'];
    cTransactionPer = json['c_transaction_per'];
    ngCMinimumTransfer = json['ng_c_minimum_transfer'];
    ngCTransactionPer = json['ng_c_transaction_per'];
    wCommission = json['w_commission'];
    tCommission = json['t_commission'];
    tCash = json['t_cash'];
    fCWCoinpayment = json['f_c_w_coinpayment'];
    fCWCard = json['f_c_w_card'];
    fCWNgcash = json['f_c_w_ngcash'];
    euroToUsdt = json['euro_to_usdt'];
    usdToEuro = json['usd_to_euro'];
    popupImg = json['popup_img'];
    try {
      if (json['popup_image'] != null) {
        List<Map<String, dynamic>> popup = [];
        jsonDecode(json['popup_image']).forEach((e) {
          // infoLog('CompanyInfoModel.fromJson  popup-img $e');
          popup.add(e);
        });
        popupImage = popup;
      }
    } catch (e) {
      errorLog('CompanyInfoModel.fromJson $e');
    }
    runCronVal = json['run_cron_val'];
    runCronDeactiveClient = json['run_cron_deactive_client'];
    autoDeductAmgn = json['auto_deduct_amgn'];
    status = json['status'];
    webIsLogin = json['web_is_login'];
    webIsSignup = json['web_is_signup'];
    webIsSubscription = json['web_is_subscription'];
    webIsCashWallet = json['web_is_cash_wallet'];
    webIsCommissionWallet = json['web_is_commission_wallet'];
    webIsVoucher = json['web_is_voucher'];
    webIsEvent = json['web_is_event'];
    webChatDisabled = json['web_chat_disabled'];
    mobileIsLogin = json['mobile_is_login'];
    mobileIsSignup = json['mobile_is_signup'];
    mobileIsSubscription = json['mobile_is_subscription'];
    mobileIsCashWallet = json['mobile_is_cash_wallet'];
    mobileIsCommissionWallet = json['mobile_is_commission_wallet'];
    mobileIsVoucher = json['mobile_is_voucher'];
    mobileIsEvent = json['mobile_is_event'];
    mobileChatDisabled = json['mobile_chat_disabled'];
    mobileAppDisabled = json['mobile_app_disabled'];
    android_version = json['android_version'];
    ios_version = json['ios_version'];
    test_android = json['test_android'];
    test_ios = json['test_ios'];
    popup_url = json['popup_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_id'] = this.companyId;
    data['company_name'] = this.companyName;
    data['email'] = this.email;
    data['address'] = this.address;
    data['mobile'] = this.mobile;
    data['website'] = this.website;
    data['business_plan'] = this.businessPlan;
    data['pdf'] = this.pdf;
    data['ppt'] = this.ppt;
    data['video'] = this.video;
    data['username'] = this.username;
    data['news'] = this.news;
    data['btc_admin_per'] = this.btcAdminPer;
    data['c_usdtt_admin_per'] = this.cUsdttAdminPer;
    data['c_usdtb_admin_per'] = this.cUsdtbAdminPer;
    data['c_bank_admin_per'] = this.cBankAdminPer;
    data['c_minimum_withdraw'] = this.cMinimumWithdraw;
    data['c_minimum_transfer'] = this.cMinimumTransfer;
    data['c_transaction_per'] = this.cTransactionPer;
    data['ng_c_minimum_transfer'] = this.ngCMinimumTransfer;
    data['ng_c_transaction_per'] = this.ngCTransactionPer;
    data['w_commission'] = this.wCommission;
    data['t_commission'] = this.tCommission;
    data['t_cash'] = this.tCash;
    data['f_c_w_coinpayment'] = this.fCWCoinpayment;
    data['f_c_w_card'] = this.fCWCard;
    data['f_c_w_ngcash'] = this.fCWNgcash;
    data['euro_to_usdt'] = this.euroToUsdt;
    data['usd_to_euro'] = this.usdToEuro;
    data['popup_img'] = this.popupImg;
    data['popup_image'] = this.popupImage;
    data['run_cron_val'] = this.runCronVal;
    data['run_cron_deactive_client'] = this.runCronDeactiveClient;
    data['auto_deduct_amgn'] = this.autoDeductAmgn;
    data['status'] = this.status;
    data['web_is_login'] = this.webIsLogin;
    data['web_is_signup'] = this.webIsSignup;
    data['web_is_subscription'] = this.webIsSubscription;
    data['web_is_cash_wallet'] = this.webIsCashWallet;
    data['web_is_commission_wallet'] = this.webIsCommissionWallet;
    data['web_is_voucher'] = this.webIsVoucher;
    data['web_is_event'] = this.webIsEvent;
    data['web_chat_disabled'] = this.webChatDisabled;
    data['mobile_is_login'] = this.mobileIsLogin;
    data['mobile_is_signup'] = this.mobileIsSignup;
    data['mobile_is_subscription'] = this.mobileIsSubscription;
    data['mobile_is_cash_wallet'] = this.mobileIsCashWallet;
    data['mobile_is_commission_wallet'] = this.mobileIsCommissionWallet;
    data['mobile_is_voucher'] = this.mobileIsVoucher;
    data['mobile_is_event'] = this.mobileIsEvent;
    data['mobile_chat_disabled'] = this.mobileChatDisabled;
    data['mobile_app_disabled'] = this.mobileAppDisabled;
    data['android_version'] = this.android_version;
    data['ios_version'] = this.ios_version;
    data['test_android'] = this.test_android;
    data['test_ios'] = this.test_ios;
    data['popup_url'] = this.popup_url;
    return data;
  }
}
