import 'package:flutter/material.dart';
import '/screens/drawerPages/team_view/settings/controller.dart';
import '/utils/color.dart';
import 'package:provider/provider.dart';

import 'settings/view.dart';
import 'examples.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});
  static const examplesViewKey = GlobalObjectKey('<ExamplesViewKey>');

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    Widget? body;
    Widget? drawer;

    if (MediaQuery.of(context).size.width > 720) {
      body = Row(
        children: const [
          SettingsView(),
          VerticalDivider(width: 1),
          Expanded(child: ExamplesView(key: examplesViewKey)),
        ],
      );
    } else {
      appBar = AppBar(
        title: const Text('TreeView Examples'),
        notificationPredicate: (_) => false,
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      );
      body = const ExamplesView(key: examplesViewKey);
      drawer = const SettingsView(isDrawer: true);
    }

    return Scaffold(
      // backgroundColor: mainColor,
      // appBar: appBar,
      body: body,
      // drawer: drawer,
    );
  }
}
