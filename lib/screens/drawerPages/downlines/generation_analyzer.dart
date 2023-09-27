import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import '/constants/assets_constants.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/team_view_provider.dart';
import '/utils/color.dart';
import '/utils/sizedbox_utils.dart';
import 'package:provider/provider.dart';
import '../../../sl_container.dart';
import '../../../utils/MyClippers.dart';
import '../../../utils/picture_utils.dart';
import '../../../utils/text.dart';

class GenerationAnalyzerPage extends StatefulWidget {
  const GenerationAnalyzerPage({super.key});

  @override
  State<GenerationAnalyzerPage> createState() => _GenerationAnalyzerPageState();
}

class _GenerationAnalyzerPageState extends State<GenerationAnalyzerPage> {
  var provider = sl.get<TeamViewProvider>();
  var authProvider = sl.get<AuthProvider>();

  // int selectedIndex = 0;
  final searchController = TextEditingController();
  bool isSearching = false;
  final ScrollController generationScoll = ScrollController();
  List<GlobalKey> generationKeys =
      List.generate(10, (index) => GlobalKey(debugLabel: 'generation_$index'));
  List<String> generationList = [
    'All',
    'Generation 1',
    'Generation 2',
    'Generation 3',
    'Generation 4',
    'Generation 5',
    'Generation 6',
    'Generation 7',
    'Generation 8',
    'Generation 9'
  ];

  final breadCumbScroll = ScrollController();
  void _animateToLast() {
    breadCumbScroll.animateTo(
      breadCumbScroll.position.maxScrollExtent,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.setBreadCrumbContent(
          0,
          BreadCrumbContent(
              index: 0,
              user: GenerationAnalyzerUser(
                  name: 'Root',
                  referralId: '',
                  image: Assets.appWebLogo,
                  generation: 0)));
      provider.setGenerationUsers('Root');
      setState(() {});
    });
  }

  @override
  void dispose() {
    provider.breadCrumbContent.clear();
    generationScoll.dispose();
    breadCumbScroll.dispose();
    searchController.dispose();
    provider.selectedGeneration = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamViewProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: buildAppBar(context),
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: userAppBgImageProvider(context),
                    fit: BoxFit.cover,
                    opacity: 1)),
            child: Column(children: [
              chipsTile(provider),
              if (provider.breadCrumbContent.length > 1)
                bradcrumRow(provider, context),
              height10(),
              Expanded(
                  child: provider.loadingGUsers.name ==
                          ButtonLoadingState.loading.name
                      ? Center(
                          child: CircularProgressIndicator(color: appLogoColor))
                      : buildGrid(provider)),
            ]),
          ),
        ),
      );
    });
  }

  Row bradcrumRow(TeamViewProvider provider, BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildBreadcrumbs(provider)),
        width5(),
        ClipPath(
          clipper: OvalLeftBorderClipper(),
          child: GestureDetector(
            onTap: () {
              if (provider.breadCrumbContent.length == 1) return;
              provider.setSelectedGeneration(0);
              Scrollable.ensureVisible(
                  generationKeys[provider.selectedGeneration].currentContext!,
                  duration: Duration(milliseconds: 700),
                  curve: Curves.fastOutSlowIn);
              provider.setBreadCrumbContent(1);
              provider.setGenerationUsers('Root');
              _animateToLast();
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black26)
                  ]),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Icon(Icons.arrow_back_rounded,
                  //     color: Colors.white, size: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: capText('Root', context,
                        color: Colors.white, useGradient: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  GridView buildGrid(TeamViewProvider provider) {
    return GridView.builder(
      padding: EdgeInsets.only(
          left: 10, right: 10, top: 0, bottom: kBottomNavigationBarHeight),
      itemCount: provider.gUsers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        GenerationAnalyzerUser user = provider.gUsers[index];
        return GestureDetector(
          onTap: () {
            provider.setSelectedGeneration(0);
            Scrollable.ensureVisible(
                generationKeys[provider.selectedGeneration].currentContext!,
                duration: Duration(milliseconds: 700));
            provider.setBreadCrumbContent(
                provider.breadCrumbContent.length,
                BreadCrumbContent(
                    index: provider.breadCrumbContent.length,
                    user: GenerationAnalyzerUser(
                        name: user.name,
                        image: user.image,
                        referralId: user.referralId,
                        generation: user.generation)));
            provider.setGenerationUsers('${user.name}');
            _animateToLast();
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: bColor,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26)
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                assetImages(user.image ?? '', height: 50, width: 50),
                bodyLargeText(user.name ?? '', context,
                    textAlign: TextAlign.center, useGradient: false),
                height5(),
                capText('Generation ${user.generation}', context,
                    useGradient: false),
                height5(),
                capText('Referral ID: ${user.referralId}', context),
              ],
            ),
          ),
        );
      },
    );
  }

  Container buildBreadcrumbs(TeamViewProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 1), blurRadius: 3, color: Colors.black26)
          ]),
      padding: EdgeInsets.all(8),
      child: BreadCrumb.builder(
        itemCount: provider.breadCrumbContent.length,
        builder: (index) {
          GenerationAnalyzerUser user =
              provider.breadCrumbContent[index].user as GenerationAnalyzerUser;
          return BreadCrumbItem(
            margin: EdgeInsets.only(
                right:
                    index == provider.breadCrumbContent.length - 1 ? 100 : 0),
            content: capText('${user.name}', context, useGradient: true),
            onTap: () {
              provider.setSelectedGeneration(0);
              Scrollable.ensureVisible(
                  generationKeys[provider.selectedGeneration].currentContext!,
                  duration: Duration(milliseconds: 700),
                  curve: Curves.fastOutSlowIn);
              provider.setBreadCrumbContent(index + 1);
              provider.setGenerationUsers('${user.name}');
              _animateToLast();
            },
          );
        },
        divider: Icon(Icons.chevron_right, color: Colors.white, size: 20),
        overflow: ScrollableOverflow(
            direction: Axis.horizontal,
            reverse: false,
            keepLastDivider: false,
            controller: breadCumbScroll),
      ),
    );
  }

  ConstrainedBox chipsTile(TeamViewProvider provider) {
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 50),
        child: ListView(
          controller: generationScoll,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: [
            ...generationList.map((gen) => Builder(builder: (context) {
                  int index = generationList.indexOf(gen);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GenerationChip(
                        widgetKey: generationKeys[index],
                        title: gen,
                        selected: provider.selectedGeneration == index,
                        index: index,
                        onCancel: (index) {
                          provider.setSelectedGeneration(0);
                          Scrollable.ensureVisible(
                              generationKeys[provider.selectedGeneration]
                                  .currentContext!,
                              duration: Duration(milliseconds: 700),
                              curve: Curves.fastOutSlowIn);
                          provider.setGenerationUsers('Root');
                        },
                        onSelect: (index) {
                          provider.setSelectedGeneration(index);
                          Scrollable.ensureVisible(
                              generationKeys[provider.selectedGeneration]
                                  .currentContext!,
                              duration: Duration(milliseconds: 700),
                              curve: Curves.fastOutSlowIn);
                          provider.setGenerationUsers(index == 0
                              ? 'Root'
                              : '${(provider.breadCrumbContent.last.user as GenerationAnalyzerUser).name}');
                        },
                      ),
                    ],
                  );
                }))
          ],
        ));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: isSearching
                ? SizedBox(
                    height: 40,
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      cursorColor: Colors.white,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        isDense: true,
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: fadeTextColor),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              // isSearching = !isSearching;
                            });
                          },
                          icon: Icon(CupertinoIcons.clear_circled_solid,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : titleLargeText('Generation Analyzer', context,
                    useGradient: true)),
        actions: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: !isSearching
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                      });
                    },
                    icon: Icon(Icons.search))
                : Transform.rotate(
                    angle: pi / 2,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            isSearching = !isSearching;
                          });
                        },
                        icon: Icon(Icons.u_turn_left)),
                  ),
          ),
        ]);
  }
}

class _GenerationChip extends StatelessWidget {
  const _GenerationChip({
    required this.widgetKey,
    this.selected = false,
    required this.index,
    required this.onCancel,
    required this.onSelect,
    required this.title,
  });
  final GlobalKey widgetKey;
  final bool selected;
  final int index;
  final Function(int) onSelect;
  final Function(int) onCancel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widgetKey,
      onTap: () => onSelect(index),
      child: Container(
        // width: 100,
        constraints: BoxConstraints(maxHeight: 30),
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: fadeTextColor, width: 1),
          gradient: selected
              ? LinearGradient(
                  colors: [Color.fromARGB(138, 186, 243, 105), appLogoColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
                child: capText(
              title,
              context,
              color: selected ? Colors.white : fadeTextColor,
            )),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () => onCancel(index),
                  child: Icon(CupertinoIcons.clear_circled_solid,
                      color: Colors.white, size: 15),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class BreadCrumbContent {
  final int index;
  final BreadCrumbData user;
  BreadCrumbContent({required this.index, required this.user});
}

abstract class BreadCrumbData {}

class GenerationAnalyzerUser extends BreadCrumbData {
  String? name;
  String referralId;
  int generation;
  String? image;
  GenerationAnalyzerUser(
      {this.name,
      required this.generation,
      this.image,
      required this.referralId});
}
