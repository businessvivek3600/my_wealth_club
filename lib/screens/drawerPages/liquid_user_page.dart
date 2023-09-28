import 'package:flutter/material.dart';
import '/constants/assets_constants.dart';
import '/providers/team_view_provider.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../sl_container.dart';

class LiquidUserPage extends StatefulWidget {
  const LiquidUserPage({super.key});

  @override
  State<LiquidUserPage> createState() => _LiquidUserPageState();
}

class _LiquidUserPageState extends State<LiquidUserPage> {
  var provider = sl.get<TeamViewProvider>();
  @override
  void initState() {
    super.initState();
    provider.getLiquidUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamViewProvider>(builder: (context, provider, _) {
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
          child: provider.loadingLoquidUser
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : buildNoActiveWidget(context),
        ),
      );
    });
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
