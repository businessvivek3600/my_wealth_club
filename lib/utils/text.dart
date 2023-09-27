import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/color.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

Widget capText(
  String text,
  BuildContext context, {
  TextAlign? textAlign,
  int? maxLines,
  TextOverflow? overflow,
  TextStyle? style,
  Color? color,
  double? fontSize,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? lineHeight,
  TextDecoration? decoration,
  bool useGradient = false,
  double opacity = 1.0,
}) {
  Widget txt = GradientText(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines ?? 3,
    style: style ??
        Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            color: color ?? Colors.white,
            fontSize: fontSize,
            height: lineHeight,
            decoration: decoration),
    gradientType: GradientType.linear,
    radius: 1,
    colors: textGradiantColors.map((e) => e.withOpacity(opacity)).toList(),
  );
  if (useGradient) return txt;
  return Text(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines ?? 3,
    style: GoogleFonts.ubuntu(
      textStyle: style ??
          Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              color: color ?? Colors.white,
              fontSize: fontSize,
              height: lineHeight,
              decoration: decoration),
    ),
  );
}

Widget bodyMedText(
  String text,
  BuildContext context, {
  TextAlign? textAlign,
  int? maxLines,
  TextOverflow? overflow,
  TextStyle? style,
  Color? color,
  double? fontSize,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? lineHeight,
  TextDecoration? decoration,
  bool useGradient = false,
  double opacity = 1.0,
}) {
  Widget txt = GradientText(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines ?? 3,
    style: style ??
        Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            color: color ?? Colors.white,
            fontSize: fontSize,
            height: lineHeight,
            decoration: decoration),
    gradientType: GradientType.linear,
    radius: 1,
    colors: textGradiantColors.map((e) => e.withOpacity(opacity)).toList(),
  );
  if (useGradient) return txt;
  return Text(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines ?? 3,
    style: GoogleFonts.ubuntu(
      textStyle: style ??
          Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              color: color ?? Colors.white,
              fontSize: fontSize,
              height: lineHeight,
              decoration: decoration),
    ),
  );
}

Widget bodyLargeText(
  String text,
  BuildContext context, {
  TextAlign? textAlign,
  int? maxLines,
  TextOverflow? overflow,
  TextStyle? style,
  Color? color,
  double? fontSize,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? lineHeight,
  TextDecoration? decoration,
  bool useGradient = true,
  double opacity = 1.0,
}) {
  Widget txt = GradientText(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines ?? 3,
    style: style ??
        Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: fontWeight ?? FontWeight.bold,
            letterSpacing: letterSpacing,
            color: color ?? Colors.white,
            fontSize: fontSize,
            height: lineHeight,
            decoration: decoration),
    gradientType: GradientType.linear,
    gradientDirection: GradientDirection.rtl,
    textScaleFactor: 1,
    radius: 1,
    colors: textGradiantColors.map((e) => e.withOpacity(opacity)).toList(),
  );
  if (useGradient) return txt;
  return Text(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines ?? 3,
    style: GoogleFonts.ubuntu(
      textStyle: style ??
          Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: fontWeight ?? FontWeight.bold,
              letterSpacing: letterSpacing,
              color: color ?? Colors.white,
              fontSize: fontSize,
              height: lineHeight,
              decoration: decoration),
    ),
  );
}

Widget titleLargeText(
  String text,
  BuildContext context, {
  TextAlign? textAlign,
  int? maxLines,
  TextOverflow? overflow,
  TextStyle? style,
  Color? color,
  double? fontSize = 18,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? lineHeight,
  TextDecoration? decoration,
  bool useGradient = false,
  double opacity = 1.0,
}) {
  Widget txt = GradientText(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines ?? 3,
    style: style ??
        TextStyle(
            fontWeight: fontWeight ?? FontWeight.bold,
            letterSpacing: letterSpacing,
            color: color ?? Colors.white,
            fontSize: fontSize,
            height: lineHeight,
            // fontFamily: 'Sansita',
            decoration: decoration),
    gradientType: GradientType.linear,
    radius: 1,
    colors: textGradiantColors.map((e) => e.withOpacity(opacity)).toList(),
  );
  if (useGradient) return txt;
  return Text(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines ?? 3,
    style: GoogleFonts.ubuntu(
      textStyle: style ??
          TextStyle(
              fontWeight: fontWeight ?? FontWeight.bold,
              letterSpacing: letterSpacing,
              color: color ?? Colors.white,
              fontSize: fontSize,
              height: lineHeight,
              // fontFamily: 'Sansita',
              decoration: decoration),
    ),
  );
}

class ShadowText extends StatelessWidget {
  ShadowText({required this.data, this.shadowData, this.style});

  final Widget data;
  final Widget? shadowData;
  final TextStyle? style;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          // new Positioned(
          //   top: 1.0,
          //   left: 1.0,
          //   bottom: 1,
          //   child: data,
          // ),
          new BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
            child: data,
          ),
          // new BackdropFilter(
          //   filter: new ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
          //   child: data,
          // ),
        ],
      ),
    );
  }
}
