import 'package:flutter/material.dart';
import 'package:mycarclub/constants/assets_constants.dart';
import 'package:mycarclub/utils/picture_utils.dart';
import 'package:mycarclub/utils/sizedbox_utils.dart';
import 'package:mycarclub/utils/text.dart';

class LiquidUserPage extends StatefulWidget {
  const LiquidUserPage({super.key});

  @override
  State<LiquidUserPage> createState() => _LiquidUserPageState();
}

class _LiquidUserPageState extends State<LiquidUserPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liquid User Page'),
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: userAppBgImageProvider(context), fit: BoxFit.cover),
        ),
        child: buildNoActiveWidget(context),
      ),
    );
  }

  Padding buildNoActiveWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          assetImages(Assets.mlm),
          height20(),
          bodyMedText(
              'You are not placed in matrix, request your upline or wait for 24 hours for autoplacment.',
              context,
              textAlign: TextAlign.center,
              lineHeight: 1.5,
              maxLines: 5),
        ],
      ),
    );
  }
}
