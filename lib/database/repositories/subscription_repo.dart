import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class SubscriptionRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  SubscriptionRepo({required this.dioClient, required this.sharedPreferences});

  /// :Subscription History
  Future<ApiResponse> getSubscription() async {
    try {
      Response response =
          await dioClient.post(AppConstants.mySubscription, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> buySubscription(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.buySubscription,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> submitCardPayment(
      String path, Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(path, token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      getSubscription();
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> hitPaymentResponse(String url) async {
    try {
      Response response = await dioClient.get(url);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
