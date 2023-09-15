import 'package:flutter/material.dart';

showCustomDialog(
  BuildContext context, {
  required Widget child,
  double? height,
  double? width,
  double? borderRadius,
  Color? color,
}) async {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: height ?? MediaQuery.of(context).size.height * 0.3,
          vertical: width ?? MediaQuery.of(context).size.width * 0.1,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
            color: color ?? Colors.transparent),
        child: child,
      );
    },
  );
}
