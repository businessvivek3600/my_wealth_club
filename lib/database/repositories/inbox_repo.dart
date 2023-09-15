import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '/database/functions.dart';
import '/database/model/response/base/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/body/login_model.dart';
import '../model/body/register_model.dart';
import '../model/response/base/api_response.dart';

class InboxRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  InboxRepo({required this.dioClient, required this.sharedPreferences});

  /// :Subscription History
  Future<ApiResponse> getMyInbox(Map<String,dynamic> data) async {
    try {
      Response response =
          await dioClient.post(AppConstants.myInbox, token: true,data: data);
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


}
