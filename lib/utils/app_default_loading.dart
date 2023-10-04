import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/utils/picture_utils.dart';

showLoading(
    {BuildContext? context,
    bool? useRootNavigator,
    bool dismissable = false}) async {
  showDialog(
    context: context ?? Get.context!,
    useRootNavigator: useRootNavigator ?? true,
    barrierDismissible: dismissable,
    builder: (context) => Container(
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(
          horizontal: Get.width * 0.2, vertical: Get.height * 0.3),
      child: Center(child: assetRive(Assets.appDefaultLoading)),
    ),
  );
}

hideLoading({required BuildContext context}) {
  Navigator.of(context).pop();
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
