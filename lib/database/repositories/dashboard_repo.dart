import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class DashboardRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  DashboardRepo({required this.dioClient, required this.sharedPreferences});

  ///:getCustomerDashboard
  Future<ApiResponse> getCustomerDashboard() async {
    try {
      Response response =
          await dioClient.post(AppConstants.customerDashboard, token: true);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///:Registration
  Future<ApiResponse> getDownloadsData() async {
    try {
      Response response =
          await dioClient.post(AppConstants.downloads, token: true);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///:Registration
  Future<ApiResponse> changePlacement(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.changePlacement,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///card-details
  Future<ApiResponse> getCardDetails(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.cardDetails,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  ///card-details
  Future<ApiResponse> cardDetailsSubmit(Map<String, dynamic> data) async {
    try {
      Response response = await dioClient.post(AppConstants.cardDetailsSubmit,
          token: true, data: data);

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  String getPDFLink() => sharedPreferences.getString(SPConstants.pdfLink) ?? "";

  String getPPTLink() => sharedPreferences.getString(SPConstants.pptLink) ?? "";

  String getVideoLink() =>
      sharedPreferences.getString(SPConstants.videoLink) ?? "";

  void setPDFLink(String id) async =>
      await sharedPreferences.setString(SPConstants.pdfLink, id);

  void setPPTLink(String id) async =>
      await sharedPreferences.setString(SPConstants.pptLink, id);

  void setVideoLink(String id) async =>
      await sharedPreferences.setString(SPConstants.videoLink, id);

  Future<bool> clearSharedData() async {
    sharedPreferences.remove(SPConstants.userToken);
    sharedPreferences.remove(SPConstants.user);
    return true;
  }
}
