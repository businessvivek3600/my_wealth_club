import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/providers/GalleryProvider.dart';
import '/screens/drawerPages/download_pages/videos/player.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'data_manager.dart';

class DrawerVideosMainPage extends StatefulWidget {
  const DrawerVideosMainPage({Key? key}) : super(key: key);

  @override
  State<DrawerVideosMainPage> createState() => _DrawerVideosMainPageState();
}

class _DrawerVideosMainPageState extends State<DrawerVideosMainPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    init();
  }

  void _onRefresh() async {
    await sl.get<GalleryProvider>().getVideos(true);
    _refreshController.refreshCompleted();
  }

  init() async {
    await sl.get<GalleryProvider>().getVideos(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          // backgroundColor: Colors.white.withOpacity(0.9),
          appBar: AppBar(
            title: titleLargeText('Master Class', context, useGradient: true),
            elevation: provider.categoryVideos.length > 0 ? null : 0,
            actions: [
              provider.loadingVideos
                  ? Center(
                      child: Container(
                          height: 20,
                          width: 20,
                          margin: EdgeInsets.only(right: 10),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 1)))
                  : provider.videoLanguages.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                              child: PopupMenuButton<String>(
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.0),
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.language,
                                          color: Colors.white, size: 15),
                                      width5(),
                                      capText(
                                          provider.currentVideoLanguage ??
                                              'English',
                                          context,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                                onSelected: (String value) {
                                  provider.setVideoLanguage(value);
                                  provider.getVideos(false);
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                offset: Offset(0, 50),
                                itemBuilder: (BuildContext context) {
                                  return provider.videoLanguages.entries
                                      .map<PopupMenuItem<String>>(
                                          (MapEntry<String, String> value) {
                                    return PopupMenuItem<String>(
                                        value: value.value,
                                        child: Text(value.value,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight:
                                                    FontWeight.normal)));
                                  }).toList();
                                },
                              ),
                            ),
                          ],
                        )
                      : Container(),
            ],
          ),
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            controller: _refreshController,
            header: MaterialClassicHeader(),
            onRefresh: _onRefresh,
            child: provider.loadingVideos
                ? Center(child: CircularProgressIndicator(color: appLogoColor))
                : provider.categoryVideos.length > 0
                    ? buildVideosListView(provider)
                    : buildNoVideos(context),
          ),
        );
      },
    );
  }

  ListView buildNoVideos(BuildContext context) {
    return ListView(
      children: [
        height100(),
        assetImages(
          Assets.dataFileImage,
        ),
        Row(
          children: [
            Expanded(
              child: titleLargeText('Videos not found.', context,
                  color: Colors.black,
                  textAlign: TextAlign.center,
                  fontSize: 22),
            ),
          ],
        ),
        height100(),
      ],
    );
  }

  ListView buildVideosListView(GalleryProvider provider) {
    return ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: provider.categoryVideos.length,
        itemBuilder: (context, index) {
          var category = provider.categoryVideos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 3,
                        )
                      ]),
                  child: Row(
                    children: [
                      Expanded(
                          child: bodyLargeText(category.header ?? '', context,
                              color: Colors.black, maxLines: 5)),
                      // GestureDetector(
                      //   onTap: () {},
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       capText('Play All', context,
                      //           color: appLogoColor,
                      //           fontWeight: FontWeight.bold),
                      //       Icon(
                      //         Icons.play_arrow_rounded,
                      //         color: appLogoColor,
                      //         size: 19,
                      //       ),
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                ),
                height10(),
                Wrap(
                  children: [
                    ...category.videoList!.map((video) {
                      var i = category.videoList!.indexOf(video);
                      return GestureDetector(
                        onTap: () {
                          provider.setCategoryModel(category);
                          provider.setCurrentVideo(video);
                          Get.to(CustomOrientationPlayer(
                              videos: category.videoList!, videoIndex: i));

                          // Get.to(VimeoPlayerWidget(
                          //     url: video.videoUrl ?? ''));
                          // Get.to(DummyPlayer(
                          //     url: video.videoUrl ?? ''));
                        },
                        child: Container(
                          // color: Colors.red,
                          padding: EdgeInsets.only(
                              right: i % 2 == 0 ? 10 : 0.0, bottom: 10),

                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    // height: (Get.width - 20-10) / 2,
                                    height: 100,
                                    width: (Get.width - 20 - 10) / 2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white70,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          spreadRadius: 5,
                                        )
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: buildCachedNetworkImage(
                                        video.videoBanner ?? '',
                                        fit: BoxFit.cover,
                                        placeholderImg: Assets.noVideoThumbnail,
                                        pw: 80,
                                        ph: 100,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white30,
                                                  blurRadius: 10,
                                                  spreadRadius: 5,
                                                )
                                              ]),
                                          child: Icon(Icons.play_arrow_rounded,
                                              color: appLogoColor),
                                        ),
                                      )),
                                  // Positioned(
                                  //     child: Container(
                                  //   width: (Get.width - 20-10) / 2,
                                  //   padding: EdgeInsets.all(3),
                                  //   decoration: BoxDecoration(
                                  //       color: Colors.white30,
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color: Colors.black12,
                                  //           blurRadius: 1,
                                  //           spreadRadius: 1,
                                  //         )
                                  //       ],
                                  //       borderRadius: BorderRadius.only(
                                  //           topLeft: Radius.circular(5),
                                  //           topRight: Radius.circular(5))),
                                  //   child: Row(
                                  //     children: [
                                  //       Expanded(
                                  //         child: capText(
                                  //             'Introduction to Trading dfh tion to Trading ',
                                  //             context),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // )),
                                ],
                              ),
                              height5(),
                              Container(
                                width: (Get.width - 20 - 10) / 2,
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: Colors.white10,
                                    boxShadow: [
                                      // BoxShadow(
                                      //   color: Colors.black.withOpacity(0.05),
                                      // blurRadius: 1,
                                      // spreadRadius: 1,
                                      // )
                                    ],
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: capText(video.title ?? "", context,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class VimeoPlayerWidget extends StatefulWidget {
  const VimeoPlayerWidget({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  _VimeoPlayerWidgetState createState() => _VimeoPlayerWidgetState();
}

class _VimeoPlayerWidgetState extends State<VimeoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: VimeoVideoPlayer(url: widget.url, autoPlay: true),
      ),
    );
  }
}
