import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/utils/picture_utils.dart';

showLoading({bool? userRootNavigator}) async {
  showDialog(
    context: Get.context!,
    useRootNavigator: userRootNavigator ?? false,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(
            horizontal: Get.width * 0.2, vertical: Get.height * 0.3),
        child: Center(child: assetRive(Assets.appDefaultLoading)),
      ),
    ),
  );
}

appDefaultPlainLoading({double? height, double? width}) => Container(
    color: Colors.transparent,
    height: height ?? Get.width * 0.5,
    width: width ?? Get.height * 0.5,
    child: Center(child: assetRive(Assets.appDefaultLoading)));

appLoadingDots({double? height, double? width}) => Container(
    color: Colors.transparent,
    height: height ?? Get.width * 0.3,
    width: width ?? Get.height * 0.3,
    child: Center(child: assetRive(Assets.loadingDots)));
