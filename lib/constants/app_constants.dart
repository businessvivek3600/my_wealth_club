class AppConstants {
  static const String authorizationToken = 'BIZZCOIN@BIZZTRADEPRO@TRANSFER';
  static const String baseUrlTest = 'https://api.mycarclub.com/api/';
  static const String baseUrl = 'https://mywealthclub.com/api/';
  static const String appName = 'My Wealth Club';

  /// app settings
  static const bool testMode = false;
  static const String appID = 'com.mywealthclub';
  static const String appAppleStoreId = '6449289696';
  static const String testCanRun = 'testCanRun';
  static const String canRun = 'canRun';
  static const String testIosVersionKey = 'test_ios';
  static const String testAndroidVersionKey = 'test_android';
  static const String iosVersionKey = 'ios_version';
  static const String androidVersionKey = 'android_version';

  //user
  static const String config = 'signup';
  static const String signup = 'signup_submit';
  static const String updateProfile = 'update_profile';
  static const String LOGIN_URI = 'do_login';
  static const String USER_INFO = 'userinfo';
  static const String forgetPassword = 'forget_password';
  static const String forgetPasswordSubmit = 'forget-password-submit';
  static const String getEmailToken = 'customer/get-email-otp';

  //dashboard
  static const String customerDashboard = 'customer_dashboard';
  static const String changePlacement = 'change-placement';
  static const String cardDetails = 'customer/card-detail';
  static const String cardDetailsSubmit = 'customer/card-detail-submit';
  static const String downloads = 'downloads';

  //subscription
  static const String myInbox = 'inbox';

  //subscription
  static const String mySubscription = 'customer/my-subscription';
  static const String buySubscription = 'customer/buy-subscription';
  static const String submitCardInvoice =
      'customer/stripe-payment-subscription-submit';

  // team
  static const String myTeam = 'customer/my-team';
  static const String getDownLines = 'customer/get-customer-downline';
  static const String customerTeam = 'customer/team-view';
  static const String sendInboxMessageToUser = 'send-inbox-message-to-user';

  //voucher
  static const String voucherList = 'customer/voucher-list';
  static const String createVoucher = 'customer/create-voucher';
  static const String createVoucherSubmit = 'customer/create-voucher-submit';
  //event-tickets
  static const String myEventTickets = 'customer/my-event-tickets';
  static const String buyEventTickets = 'customer/buy-event-ticket';
  static const String buyEventTicketsSubmit =
      'customer/buy-event-ticket-submit';

  ///commission wallet
  static const String commissionWallet = 'myWallet/commission-wallet';
  static const String getCommissionWithdrawRequest =
      'myWallet/add-commission-withdraw-request';
  static const String getWithdrawEmailToken = 'myWallet/get-withdraw-email-otp';
  static const String commissionWithdrawRequestSubmit =
      'myWallet/commission-withdraw-request-submit';
  static const String commissionTransferToCashWallet =
      'myWallet/commission-to-cash-transfer-submit';

  ///cash wallet
  static const String cashWallet = 'myWallet/cash-wallet';
  static const String getCoinPaymentFundRequest =
      'myWallet/coinpayment-fund-request';
  static const String coinPaymentSubmit =
      'myWallet/add-coinpayment-fund-request';
    static const String transferCashToOther =
      'myWallet/transfer-cash-to-other-submit';
  static const String getCardPaymentFundRequest = 'myWallet/card-fund-request';
  static const String cashWalletCardPaymentFundRequestSubmit =
      'myWallet/card-fund-request-submit';
  static const String cashWalletCardPaymentFundSubmit =
      'myWallet/stripe-payment-fund-submit';
  //TODO: cash wallet Card payment submit
  static const String getNGCashWalletFundRequest =
      'myWallet/add-fund-from-ng-cash-wallet';
  static const String addFundFromNGCashWalletFundSubmit =
      'myWallet/add-fund-from-ng-cash-wallet-submit';

  /// TODO: gallery
  static const String gallery = 'gallery';
  static const String galleryDetail = 'gallery_detail';
  static const String galleryVideos = 'get-videos';

  /// TODO: Support
  static const String support = 'support';
  static const String newTicket = 'new-ticket';
  static const String newTicketSubmit = 'new-ticket-submit';
  static const String ticketDetail = 'ticket-detail';
  static const String ticketReplySubmit = 'ticket-reply-submit';

  //profile
  static const String commissionWithdrawal = 'commission_withdrawal';
  static const String getOtpCommissionWithdrawal =
      'otp-for-commission-withdrawal';

  //random
  static const String getStates = 'get-states';

  //stripe
  static const String stripeTestSecretKey =
      'sk_test_51MqBeRBej8fUvbAN37mhGwyiELD9E5sGXZMoW9AAxicZj0g2njej551vpApANG2zVotKtzMbmrp4Z1s8mq7HqcCQ00tiFFWh45';

  static const String stripeSecretKey =
      'sk_test_51MqBeRBej8fUvbAN37mhGwyiELD9E5sGXZMoW9AAxicZj0g2njej551vpApANG2zVotKtzMbmrp4Z1s8mq7HqcCQ00tiFFWh45';

  static const String fcmWebKey =
      'AAAA1zQKpYE:APA91bHID4fhyPM-OQ9FLbjh00jT9M9IMeO9PPkaYIPlfKwv0ttgZiiMcYPQFGJpjlMtZUR_g8FCc2rmNmxmbXXwyxSDaGgSi4eM7AYpDKC9OLTkebXdCdV7dZALR-xdxFad3u5sPC7G';

  //local database name
  static const String notificationLocalDBName = 'trial7';
}

class SPConstants {
  static const String appBadge = 'appBadge';
  static const String canUpdate = 'can_update';
  static const String canRunApp = 'can_run_app';
  static const String userToken = 'user_token';
  static const String defaultReferralId = 'default_referral_id';
  static const String customerDashboard = 'customer_dashboard';
  static const String user = 'user';

  static const String pdfLink = 'pdfLink';
  static const String pptLink = 'pptLink';
  static const String videoLink = 'videoLink';

  static const String ratingScheduleDate = 'RatingScheduleDate';

  //settings
  static const String biometric = 'biometric';

  //fcm Subscription topics
  static const String topic_all = 'subscribe_to_all';
  static const String topic_event = 'subscribe_to_event';
  static const String topic_testing = 'subscribe_to_testing';

  static const String fcmWebKey =
      'AAAA1zQKpYE:APA91bHID4fhyPM-OQ9FLbjh00jT9M9IMeO9PPkaYIPlfKwv0ttgZiiMcYPQFGJpjlMtZUR_g8FCc2rmNmxmbXXwyxSDaGgSi4eM7AYpDKC9OLTkebXdCdV7dZALR-xdxFad3u5sPC7G';
  static const String whatsAppText =
      r"Welcome to Touchwood Technologies, your one-stop-shop for innovative and efficient software solutions! Our team of experienced developers and designers work tirelessly to create custom software solutions that are designed with your business in mind. Our products are intuitive and easy to use, making technology work for you, not against you.  We take pride in being a customer-centric company and our mission is to provide you with the best possible experience. Whether you're a small business or a large corporation, we have the tools and expertise to help you succeed in today's fast-paced digital world. Don't just take our word for it - our satisfied clients speak for themselves! Join our growing list of happy customers by reaching out to us today. Our support team is always available to answer any questions you may have and provide you with the support you need to succeed. So why wait? Contact us now to learn more about our software solutions and take your business to the next level!";
}
