import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '/database/functions.dart';
import '/database/model/response/base/user_model.dart';
import '/database/repositories/fcm_subscription_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../dio/dio/dio_client.dart';
import '../dio/exception/api_error_handler.dart';
import '../model/body/login_model.dart';
import '../model/body/register_model.dart';
import '../model/response/base/api_response.dart';

class SettingsRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  final FCMSubscriptionRepo fcmSubscriptionRepo;
  SettingsRepo(
      {required this.fcmSubscriptionRepo,
      required this.dioClient,
      required this.sharedPreferences});

  /// :Biometric
  void setBiometric(bool val) async {
    await sharedPreferences.setBool(SPConstants.biometric, val);
  }

  bool getBiometric() {
    return sharedPreferences.getBool(SPConstants.biometric) ?? false;
  }

  //new features notification
  Future<void> enableNewFeatures() async=>await fcmSubscriptionRepo.subscribeToTopic(SPConstants.topic_testing);
  Future<void> disableNewFeatures() async=>await fcmSubscriptionRepo.unSubscribeToTopic(SPConstants.topic_testing);
  bool get getNewFeaturesValue => fcmSubscriptionRepo.getTopicValue(SPConstants.topic_testing);
}
